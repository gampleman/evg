module InteractiveTypedSvg exposing (Model, Msg, init, subscriptions, update, view)

{-| The same interactive scene as `InteractiveEvg`, built with
elm-community/typed-svg. Everything the Evg events module did for us is
hand-rolled here:

  - **Drag** the coloured nodes. Works with mouse, touch, and pen. Mouse drags
    keep following the cursor even when it leaves the node — or the whole
    drawing — because we subscribe to `Browser.Events.onMouseMove`/`onMouseUp`
    while a mouse drag is in progress, converting window client pixels back to
    scene coordinates via an origin captured when the drag began. Touch and pen
    rely on the browser's implicit pointer capture, so the element's own
    `pointermove`/`pointerup` keep firing for them.
  - **Zoom** with the mouse wheel or a trackpad pinch. The point under the
    cursor stays put while everything scales around it.
  - **Local coordinates under a transform.** The scene lives inside a `g` that
    is panned and zoomed, so every pointer position has to be converted from
    scene space into the group's local space by undoing the camera transform
    by hand.

The `<svg>` is 300×300 CSS pixels with `viewBox "0 0 300 300"`, so `offsetX`/
`offsetY` pixels equal scene units 1:1. We rely on that below; if the svg were
resized with CSS the decoders would need to rescale.

-}

import Browser.Events
import Color exposing (Color)
import Html exposing (Html)
import Html.Events
import Json.Decode as Decode exposing (Decoder)
import TypedSvg
import TypedSvg.Attributes
import TypedSvg.Attributes.InPx as InPx
import TypedSvg.Core exposing (Svg)
import TypedSvg.Types exposing (AnchorAlignment(..), Cursor(..), Opacity(..), Paint(..), Transform(..), px)



-- MODEL


type alias Node =
    { id : Int
    , center : ( Float, Float )
    , color : Color
    , label : String
    }


type alias Camera =
    { scale : Float
    , translate : ( Float, Float )
    }


{-| While a node is being dragged we remember which one, the offset between the
grab point and the node's centre (so it doesn't jump under the cursor), the
input device (mouse drags need window tracking; touch/pen don't), and the
client position of the svg's top-left corner — captured at pointerdown as
`client - offset` — which converts window client pixels back to scene space.
-}
type alias Drag =
    { nodeId : Int
    , pointerId : Int
    , grabOffset : ( Float, Float )
    , pointerType : PointerType
    , svgOrigin : ( Float, Float )
    }


type PointerType
    = Mouse
    | Touch
    | Pen


{-| What we decode off a pointer event: the position in scene coordinates
(`offsetX`/`offsetY`, which are 1:1 with scene units here), the raw client
position, and which pointer/device produced it.
-}
type alias Pointer =
    { scene : ( Float, Float )
    , client : ( Float, Float )
    , pointerId : Int
    , pointerType : PointerType
    }


{-| A wheel event: where the pointer was (scene coordinates), how far it
scrolled (normalised to pixels), and whether this is a trackpad pinch
(browsers report pinches as a scroll with `ctrlKey` implicitly held).
-}
type alias Wheel =
    { scene : ( Float, Float )
    , deltaY : Float
    , pinch : Bool
    }


type alias Model =
    { nodes : List Node
    , camera : Camera
    , drag : Maybe Drag
    , lastPointer : Maybe ( Float, Float )
    }


init : Model
init =
    { nodes =
        [ Node 0 ( 90, 90 ) (Color.rgb255 232 89 12) "A"
        , Node 1 ( 210, 130 ) (Color.rgb255 25 113 194) "B"
        , Node 2 ( 140, 220 ) (Color.rgb255 47 158 68) "C"
        ]
    , camera = { scale = 1, translate = ( 0, 0 ) }
    , drag = Nothing
    , lastPointer = Nothing
    }



-- UPDATE


type Msg
    = DragStarted Int Pointer
    | DragMovedScene ( Float, Float )
    | DragMovedElement Pointer
    | DragEnded
    | Zoomed Wheel
    | HoverMoved ( Float, Float )


update : Msg -> Model -> Model
update msg model =
    case msg of
        DragStarted nodeId pointer ->
            case findNode nodeId model.nodes of
                Just node ->
                    let
                        -- Where the grab happened in the camera group's local
                        -- space (the space the node centres live in).
                        ( gx, gy ) =
                            sceneToLocal model.camera pointer.scene

                        ( cx, cy ) =
                            node.center

                        ( clientX, clientY ) =
                            pointer.client

                        ( sceneX, sceneY ) =
                            pointer.scene
                    in
                    { model
                        | drag =
                            Just
                                { nodeId = nodeId
                                , pointerId = pointer.pointerId
                                , grabOffset = ( cx - gx, cy - gy )
                                , pointerType = pointer.pointerType

                                -- offset = client - svg origin, and offset
                                -- pixels are scene units, so the origin is
                                -- client - scene.
                                , svgOrigin = ( clientX - sceneX, clientY - sceneY )
                                }
                    }

                Nothing ->
                    model

        DragMovedElement pointer ->
            -- Fired by the element's own pointermove (used for touch/pen, which
            -- keep firing on the element thanks to implicit pointer capture).
            -- Ignore moves from a different pointer than the one that started
            -- the drag.
            case model.drag of
                Just drag ->
                    if drag.pointerId == pointer.pointerId && drag.pointerType /= Mouse then
                        moveDragged drag (sceneToLocal model.camera pointer.scene) model

                    else
                        model

                Nothing ->
                    model

        DragMovedScene scenePoint ->
            -- Fired by the window subscription for mouse drags. The point is in
            -- scene space; convert it into the dragged group's local space by
            -- undoing the camera transform.
            case model.drag of
                Just drag ->
                    moveDragged drag (sceneToLocal model.camera scenePoint) model

                Nothing ->
                    model

        DragEnded ->
            { model | drag = Nothing }

        Zoomed wheel ->
            { model | camera = zoomAround wheel model.camera }

        HoverMoved scenePoint ->
            { model | lastPointer = Just scenePoint }


moveDragged : Drag -> ( Float, Float ) -> Model -> Model
moveDragged drag ( lx, ly ) model =
    let
        ( ox, oy ) =
            drag.grabOffset

        newCenter =
            ( lx + ox, ly + oy )
    in
    { model
        | nodes =
            List.map
                (\n ->
                    if n.id == drag.nodeId then
                        { n | center = newCenter }

                    else
                        n
                )
                model.nodes
    }


{-| Zoom so the scene point under the cursor stays fixed. This is the standard
zoom invariant: find the world point under the pointer, scale, then translate so
that world point lands back under the pointer.
-}
zoomAround : Wheel -> Camera -> Camera
zoomAround wheel camera =
    let
        factor =
            2 ^ (-wheel.deltaY * 0.002)

        newScale =
            clamp 0.3 5 (camera.scale * factor)

        -- The scene point under the cursor, in the group's local space.
        ( lx, ly ) =
            sceneToLocal camera wheel.scene

        ( sx, sy ) =
            wheel.scene
    in
    { scale = newScale
    , translate = ( sx - lx * newScale, sy - ly * newScale )
    }


sceneToLocal : Camera -> ( Float, Float ) -> ( Float, Float )
sceneToLocal camera ( sx, sy ) =
    let
        ( tx, ty ) =
            camera.translate
    in
    ( (sx - tx) / camera.scale, (sy - ty) / camera.scale )


findNode : Int -> List Node -> Maybe Node
findNode id nodes =
    List.filter (\n -> n.id == id) nodes |> List.head



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.drag of
        Just drag ->
            -- Only mouse drags need window tracking. Touch and pen keep firing
            -- pointermove on the element itself (implicit pointer capture), so
            -- subscribing here would double-count them.
            if drag.pointerType == Mouse then
                Sub.batch
                    [ Browser.Events.onMouseMove
                        (Decode.map (DragMovedScene << clientToScene drag.svgOrigin) clientDecoder)
                    , Browser.Events.onMouseUp (Decode.succeed DragEnded)
                    ]

            else
                Sub.none

        Nothing ->
            Sub.none


clientToScene : ( Float, Float ) -> ( Float, Float ) -> ( Float, Float )
clientToScene ( originX, originY ) ( cx, cy ) =
    ( cx - originX, cy - originY )



-- VIEW


view : Model -> Html Msg
view model =
    let
        ( tx, ty ) =
            model.camera.translate
    in
    Html.div []
        [ TypedSvg.svg
            [ TypedSvg.Attributes.width (px 300)
            , TypedSvg.Attributes.height (px 300)
            , TypedSvg.Attributes.viewBox 0 0 300 300
            , Html.Events.preventDefaultOn "wheel"
                (Decode.map (\w -> ( Zoomed w, True )) wheelDecoder)
            , Html.Events.on "pointermove" (Decode.map (HoverMoved << .scene) pointerDecoder)
            , TypedSvg.Core.attribute "touch-action" "none"
            ]
            [ TypedSvg.rect
                [ InPx.x 0
                , InPx.y 0
                , InPx.width 300
                , InPx.height 300
                , TypedSvg.Attributes.fill (Paint (Color.rgb255 248 249 250))
                ]
                []
            , grid
            , TypedSvg.g
                [ TypedSvg.Attributes.transform
                    [ Translate tx ty
                    , Scale model.camera.scale model.camera.scale
                    ]
                ]
                (List.map (viewNode model.drag) model.nodes)
            , viewReadout model
            ]
        ]


grid : Svg msg
grid =
    let
        stroke =
            [ TypedSvg.Attributes.stroke (Paint (Color.rgb255 222 226 230))
            , InPx.strokeWidth 1
            ]
    in
    TypedSvg.g []
        (List.concatMap
            (\i ->
                let
                    p =
                        toFloat i * 30
                in
                [ TypedSvg.line (stroke ++ [ InPx.x1 p, InPx.y1 0, InPx.x2 p, InPx.y2 300 ]) []
                , TypedSvg.line (stroke ++ [ InPx.x1 0, InPx.y1 p, InPx.x2 300, InPx.y2 p ]) []
                ]
            )
            (List.range 0 10)
        )


viewNode : Maybe Drag -> Node -> Svg Msg
viewNode drag node =
    let
        dragging =
            case drag of
                Just d ->
                    d.nodeId == node.id

                Nothing ->
                    False

        ( cx, cy ) =
            node.center
    in
    TypedSvg.g
        [ Html.Events.on "pointerdown" (Decode.map (DragStarted node.id) pointerDecoder)
        , Html.Events.on "pointermove" (Decode.map DragMovedElement pointerDecoder)
        , Html.Events.on "pointerup" (Decode.succeed DragEnded)
        , TypedSvg.Attributes.cursor
            (if dragging then
                Cursor "grabbing"

             else
                Cursor "grab"
            )
        ]
        [ TypedSvg.circle
            [ InPx.cx cx
            , InPx.cy cy
            , InPx.r 26
            , TypedSvg.Attributes.fill (Paint node.color)
            , TypedSvg.Attributes.stroke (Paint Color.white)
            , InPx.strokeWidth 3
            , TypedSvg.Attributes.opacity
                (Opacity
                    (if dragging then
                        1

                     else
                        0.85
                    )
                )
            ]
            []
        , TypedSvg.text_
            [ InPx.x cx
            , InPx.y (cy + 6)
            , TypedSvg.Attributes.textAnchor AnchorMiddle
            , TypedSvg.Attributes.fill (Paint Color.white)
            , InPx.fontSize 18
            , TypedSvg.Attributes.fontFamily [ "sans-serif" ]
            ]
            [ TypedSvg.Core.text node.label ]
        ]


viewReadout : Model -> Svg Msg
viewReadout model =
    let
        label =
            case model.lastPointer of
                Just ( x, y ) ->
                    "scene: " ++ round1 x ++ ", " ++ round1 y ++ "   zoom: " ++ round1 model.camera.scale ++ "×"

                Nothing ->
                    "move the pointer over the canvas"
    in
    TypedSvg.text_
        [ InPx.x 8
        , InPx.y 292
        , TypedSvg.Attributes.textAnchor AnchorStart
        , TypedSvg.Attributes.fill (Paint (Color.rgb255 134 142 150))
        , InPx.fontSize 11
        , TypedSvg.Attributes.fontFamily [ "monospace" ]
        ]
        [ TypedSvg.Core.text label ]


round1 : Float -> String
round1 x =
    String.fromFloat (toFloat (round (x * 10)) / 10)



-- DECODERS


{-| Decode a pointer event. `offsetX`/`offsetY` are relative to the root svg,
and because the svg is rendered at its viewBox size they are scene coordinates
directly.
-}
pointerDecoder : Decoder Pointer
pointerDecoder =
    Decode.map4 Pointer
        offsetDecoder
        clientDecoder
        (Decode.oneOf [ Decode.field "pointerId" Decode.int, Decode.succeed 0 ])
        pointerTypeDecoder


offsetDecoder : Decoder ( Float, Float )
offsetDecoder =
    Decode.map2 Tuple.pair
        (Decode.field "offsetX" Decode.float)
        (Decode.field "offsetY" Decode.float)


clientDecoder : Decoder ( Float, Float )
clientDecoder =
    Decode.map2 Tuple.pair
        (Decode.field "clientX" Decode.float)
        (Decode.field "clientY" Decode.float)


pointerTypeDecoder : Decoder PointerType
pointerTypeDecoder =
    Decode.oneOf
        [ Decode.field "pointerType" Decode.string
            |> Decode.map
                (\s ->
                    case s of
                        "touch" ->
                            Touch

                        "pen" ->
                            Pen

                        _ ->
                            Mouse
                )
        , Decode.succeed Mouse
        ]


wheelDecoder : Decoder Wheel
wheelDecoder =
    Decode.map3 Wheel
        offsetDecoder
        deltaYDecoder
        (Decode.field "ctrlKey" Decode.bool)


{-| `deltaY`, normalised to pixels (deltaMode: 0 = pixels, 1 = lines,
2 = pages).
-}
deltaYDecoder : Decoder Float
deltaYDecoder =
    Decode.map2
        (\dy mode ->
            case mode of
                1 ->
                    dy * 16

                2 ->
                    dy * 800

                _ ->
                    dy
        )
        (Decode.field "deltaY" Decode.float)
        (Decode.oneOf [ Decode.field "deltaMode" Decode.int, Decode.succeed 0 ])
