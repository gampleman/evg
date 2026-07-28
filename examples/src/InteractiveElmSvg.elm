module InteractiveElmSvg exposing (Model, Msg, init, subscriptions, update, view)

{-| The same interactive scene as `InteractiveEvg`, written with plain
`elm/svg`. Everything the library did for us has to be hand-rolled here:

  - **JSON decoders** for pointer events (`pointerdown`, `pointermove`,
    `pointerup`, `pointercancel`) reading `offsetX`/`offsetY`, `pointerId`
    and `pointerType`, plus a `wheel` decoder for `deltaY`.
  - **Coordinate conversion.** The svg is `width=300 height=300` with
    `viewBox "0 0 300 300"`, so offset pixels equal scene units 1:1 and we
    lean on that everywhere. (This shortcut breaks as soon as CSS resizes
    the element — a proper solution would divide by the rendered size.)
  - **Window-level mouse tracking.** `offsetX` is meaningless on window
    events, so on `pointerdown` we also decode `clientX`/`clientY` and store
    the difference `client − offset`; subtracting it from later window
    coordinates recovers scene coordinates. Touch and pen don't need this:
    pointer events give them implicit capture, so the element's own
    `pointermove`/`pointerup` keep firing.
  - **The camera maths.** Undoing the pan/zoom transform to get local
    coordinates, and the zoom-about-cursor invariant.

-}

import Browser.Events
import Html exposing (Html)
import Html.Events
import Json.Decode as Decode exposing (Decoder)
import Svg exposing (Svg)
import Svg.Attributes as SA
import Svg.Events



-- MODEL


type alias Node =
    { id : Int
    , center : ( Float, Float )
    , color : String
    , label : String
    }


type alias Camera =
    { scale : Float
    , translate : ( Float, Float )
    }


{-| What we decode out of a `pointerdown` event. `scene` is the offset
position (= scene coordinates, thanks to the 1:1 mapping); `offsetOrigin` is
`client − offset`, captured so window mouse coordinates can be converted back
to scene coordinates during the drag.
-}
type alias Pointer =
    { pointerId : Int
    , pointerType : String
    , scene : ( Float, Float )
    , offsetOrigin : ( Float, Float )
    }


type alias Wheel =
    { deltaY : Float
    , scene : ( Float, Float )
    }


{-| While a node is being dragged we remember which one, the offset between
the grab point and the node's centre (so it doesn't jump under the cursor),
the input device (mouse drags need window tracking; touch/pen don't), and the
offset origin that converts window coordinates back to scene space.
-}
type alias Drag =
    { nodeId : Int
    , pointerId : Int
    , grabOffset : ( Float, Float )
    , pointerType : String
    , offsetOrigin : ( Float, Float )
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
        [ Node 0 ( 90, 90 ) "#e8590c" "A"
        , Node 1 ( 210, 130 ) "#1971c2" "B"
        , Node 2 ( 140, 220 ) "#2f9e44" "C"
        ]
    , camera = { scale = 1, translate = ( 0, 0 ) }
    , drag = Nothing
    , lastPointer = Nothing
    }



-- UPDATE


type Msg
    = DragStarted Int Pointer
    | DragMovedWindow ( Float, Float )
    | DragMovedElement Int ( Float, Float )
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
                        -- Undo the camera transform by hand to learn where the
                        -- node was grabbed in its own coordinate space.
                        ( gx, gy ) =
                            sceneToLocal model.camera pointer.scene

                        ( cx, cy ) =
                            node.center
                    in
                    { model
                        | drag =
                            Just
                                { nodeId = nodeId
                                , pointerId = pointer.pointerId
                                , grabOffset = ( cx - gx, cy - gy )
                                , pointerType = pointer.pointerType
                                , offsetOrigin = pointer.offsetOrigin
                                }
                    }

                Nothing ->
                    model

        DragMovedElement pointerId scenePoint ->
            -- Fired by the element's own pointermove (used for touch/pen,
            -- which keep firing on the element thanks to implicit pointer
            -- capture). Ignore moves from a different pointer than the one
            -- that started the drag.
            case model.drag of
                Just drag ->
                    if drag.pointerId == pointerId && drag.pointerType /= "mouse" then
                        moveDragged drag (sceneToLocal model.camera scenePoint) model

                    else
                        model

                Nothing ->
                    model

        DragMovedWindow clientPoint ->
            -- Fired by the window subscription for mouse drags. Window events
            -- only give client coordinates, so subtract the offset origin
            -- captured at drag start to get back to scene space, then undo
            -- the camera transform.
            case model.drag of
                Just drag ->
                    let
                        ( clientX, clientY ) =
                            clientPoint

                        ( originX, originY ) =
                            drag.offsetOrigin

                        scenePoint =
                            ( clientX - originX, clientY - originY )
                    in
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
zoom invariant: find the world point under the pointer, scale, then translate
so that world point lands back under the pointer.
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
            -- Only mouse drags need window tracking. Touch and pen keep
            -- firing pointermove on the element itself (implicit pointer
            -- capture), so subscribing here would double-count them.
            if drag.pointerType == "mouse" then
                Sub.batch
                    [ Browser.Events.onMouseMove (Decode.map DragMovedWindow clientPosition)
                    , Browser.Events.onMouseUp (Decode.succeed DragEnded)
                    ]

            else
                Sub.none

        Nothing ->
            Sub.none



-- DECODERS


{-| `offsetX`/`offsetY` are relative to the svg element. Because the svg is
rendered at exactly its viewBox size (300×300), offset pixels are scene units
1:1 — this breaks if CSS ever resizes the element.
-}
offsetPosition : Decoder ( Float, Float )
offsetPosition =
    Decode.map2 Tuple.pair
        (Decode.field "offsetX" Decode.float)
        (Decode.field "offsetY" Decode.float)


clientPosition : Decoder ( Float, Float )
clientPosition =
    Decode.map2 Tuple.pair
        (Decode.field "clientX" Decode.float)
        (Decode.field "clientY" Decode.float)


pointerDown : Decoder Pointer
pointerDown =
    Decode.map4
        (\pointerId pointerType ( ox, oy ) ( cx, cy ) ->
            { pointerId = pointerId
            , pointerType = pointerType
            , scene = ( ox, oy )
            , offsetOrigin = ( cx - ox, cy - oy )
            }
        )
        (Decode.field "pointerId" Decode.int)
        (Decode.field "pointerType" Decode.string)
        offsetPosition
        clientPosition


pointerMove : Decoder Msg
pointerMove =
    Decode.map2 DragMovedElement
        (Decode.field "pointerId" Decode.int)
        offsetPosition


wheelEvent : Decoder Wheel
wheelEvent =
    Decode.map2 Wheel
        (Decode.field "deltaY" Decode.float)
        offsetPosition



-- VIEW


view : Model -> Html Msg
view model =
    Html.div []
        [ Svg.svg
            [ SA.width "300"
            , SA.height "300"
            , SA.viewBox "0 0 300 300"
            , SA.style "touch-action: none"
            , Html.Events.preventDefaultOn "wheel" (Decode.map (\w -> ( Zoomed w, True )) wheelEvent)
            , Svg.Events.on "pointermove" (Decode.map HoverMoved offsetPosition)
            ]
            [ Svg.rect
                [ SA.x "0", SA.y "0", SA.width "300", SA.height "300", SA.fill "#f8f9fa" ]
                []
            , grid
            , Svg.g
                [ SA.transform (cameraTransform model.camera) ]
                (List.map (viewNode model.drag) model.nodes)
            , viewReadout model
            ]
        ]


cameraTransform : Camera -> String
cameraTransform camera =
    let
        ( tx, ty ) =
            camera.translate
    in
    "translate("
        ++ String.fromFloat tx
        ++ " "
        ++ String.fromFloat ty
        ++ ") scale("
        ++ String.fromFloat camera.scale
        ++ ")"


grid : Svg msg
grid =
    Svg.g []
        (List.concatMap
            (\i ->
                let
                    p =
                        String.fromFloat (toFloat i * 30)
                in
                [ gridLine p "0" p "300"
                , gridLine "0" p "300" p
                ]
            )
            (List.range 0 10)
        )


gridLine : String -> String -> String -> String -> Svg msg
gridLine x1 y1 x2 y2 =
    Svg.line
        [ SA.x1 x1
        , SA.y1 y1
        , SA.x2 x2
        , SA.y2 y2
        , SA.stroke "#dee2e6"
        , SA.strokeWidth "1"
        ]
        []


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
    Svg.g
        [ Svg.Events.on "pointerdown" (Decode.map (DragStarted node.id) pointerDown)
        , Svg.Events.on "pointermove" pointerMove
        , Svg.Events.on "pointerup" (Decode.succeed DragEnded)
        , Svg.Events.on "pointercancel" (Decode.succeed DragEnded)
        , SA.style
            ("cursor: "
                ++ (if dragging then
                        "grabbing"

                    else
                        "grab"
                   )
            )
        ]
        [ Svg.circle
            [ SA.cx (String.fromFloat cx)
            , SA.cy (String.fromFloat cy)
            , SA.r "26"
            , SA.fill node.color
            , SA.stroke "white"
            , SA.strokeWidth "3"
            , SA.opacity
                (if dragging then
                    "1"

                 else
                    "0.85"
                )
            ]
            []
        , Svg.text_
            [ SA.x (String.fromFloat cx)
            , SA.y (String.fromFloat (cy + 6))
            , SA.textAnchor "middle"
            , SA.fill "white"
            , SA.fontSize "18"
            , SA.fontFamily "sans-serif"
            ]
            [ Svg.text node.label ]
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
    Svg.text_
        [ SA.x "8"
        , SA.y "292"
        , SA.fill "#868e96"
        , SA.fontSize "11"
        , SA.fontFamily "monospace"
        ]
        [ Svg.text label ]


round1 : Float -> String
round1 x =
    String.fromFloat (toFloat (round (x * 10)) / 10)
