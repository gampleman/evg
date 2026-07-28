module InteractiveEvg exposing (Model, Msg, init, subscriptions, update, view)

{-| A single interactive scene that exercises everything the events module can
do:

  - **Drag** the coloured nodes. Works with mouse, touch, and pen. Mouse drags
    keep following the cursor even when it leaves the node — or the whole
    drawing — because we track them on the window with `Events.whileDragging`,
    converting each position back into scene coordinates through a `Frame`
    captured when the drag began.
  - **Zoom** with the mouse wheel or a trackpad pinch. The point under the
    cursor stays put while everything scales around it, using the wheel
    position reported in scene coordinates.
  - **Local coordinates under a transform.** The whole scene lives inside a
    `group` that is panned and zoomed, yet each node reports where it was
    grabbed in its _own_ coordinate space — the library inverts the group's
    transform for us, so the drag maths never has to know about the zoom.

-}

import Evg exposing (Evg)
import Evg.Events as Events exposing (Pointer, Wheel)
import Evg.Transform as Transform
import Html exposing (Html)



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


{-| While a node is being dragged we remember which one, the offset between the
grab point and the node's centre (so it doesn't jump under the cursor), the
input device (mouse drags need window tracking; touch/pen don't), and the
`Frame` that converts window coordinates back to scene space.
-}
type alias Drag =
    { nodeId : Int
    , pointerId : Int
    , grabOffset : ( Float, Float )
    , pointerType : Events.PointerType
    , frame : Events.Frame
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
    | DragMovedScene ( Float, Float )
    | DragMovedLocal Int ( Float, Float )
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
                        ( gx, gy ) =
                            pointer.local

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
                                , frame = pointer.frame
                                }
                    }

                Nothing ->
                    model

        DragMovedLocal pointerId localPoint ->
            -- Fired by the element's own pointermove (used for touch/pen, which
            -- keep firing on the element). Ignore moves from a different
            -- pointer than the one that started the drag.
            case model.drag of
                Just drag ->
                    if drag.pointerId == pointerId && drag.pointerType /= Events.Mouse then
                        moveDragged drag localPoint model

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
        ( _, dy ) =
            wheel.delta

        factor =
            2 ^ (-dy * 0.002)

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
            if drag.pointerType == Events.Mouse then
                Events.whileDragging drag.frame
                    { onMove = DragMovedScene
                    , onEnd = \_ -> DragEnded
                    }

            else
                Sub.none

        Nothing ->
            Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    Html.div []
        [ Evg.svg
            [ Events.onWheel Zoomed
            , Events.onPointerMoveWith (HoverMoved << .scene)
            , Events.touchAction Events.None
            ]
            { width = 300, height = 300 }
            [ Evg.rect [ Evg.fillStr "#f8f9fa" ] { x = 0, y = 0, width = 300, height = 300 }
            , grid
            , Evg.group
                [ Transform.translate (Tuple.first model.camera.translate) (Tuple.second model.camera.translate)
                , Transform.scaleUniform model.camera.scale
                ]
                (List.map (viewNode model.drag) model.nodes)
            , viewReadout model
            ]
        ]


grid : Evg msg
grid =
    let
        stroke =
            [ Evg.strokeStr "#dee2e6", Evg.strokeWidth 1 ]
    in
    Evg.group []
        (List.concatMap
            (\i ->
                let
                    p =
                        toFloat i * 30
                in
                [ Evg.line stroke ( p, 0 ) ( p, 300 )
                , Evg.line stroke ( 0, p ) ( 300, p )
                ]
            )
            (List.range 0 10)
        )


viewNode : Maybe Drag -> Node -> Evg Msg
viewNode drag node =
    let
        dragging =
            case drag of
                Just d ->
                    d.nodeId == node.id

                Nothing ->
                    False
    in
    Evg.group
        [ Events.onPointerDownWith (DragStarted node.id)
        , Events.onPointerMoveWith (\p -> DragMovedLocal p.pointerId p.local)
        , Events.onPointerUpWith (\_ -> DragEnded)
        , Events.cursor
            (if dragging then
                Events.Grabbing

             else
                Events.Grab
            )
        ]
        [ Evg.circle
            [ Evg.fillStr node.color
            , Evg.strokeStr "white"
            , Evg.strokeWidth 3
            , Evg.opacity
                (if dragging then
                    1

                 else
                    0.85
                )
            ]
            { r = 26, center = node.center }
        , Evg.text
            [ Evg.fillStr "white"
            , Evg.fontSize 18
            , Evg.fontFamily "sans-serif"
            ]
            { x = Tuple.first node.center
            , y = Tuple.second node.center + 6
            , anchor = Evg.Middle
            }
            node.label
        ]


viewReadout : Model -> Evg Msg
viewReadout model =
    let
        label =
            case model.lastPointer of
                Just ( x, y ) ->
                    "scene: " ++ round1 x ++ ", " ++ round1 y ++ "   zoom: " ++ round1 model.camera.scale ++ "×"

                Nothing ->
                    "move the pointer over the canvas"
    in
    Evg.text
        [ Evg.fillStr "#868e96", Evg.fontSize 11, Evg.fontFamily "monospace" ]
        { x = 8, y = 292, anchor = Evg.Start }
        label


round1 : Float -> String
round1 x =
    String.fromFloat (toFloat (round (x * 10)) / 10)
