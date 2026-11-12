module ArmEvg exposing (Model, Msg, init, subscriptions, update, view)

{-| A robot arm with `Evg.Drag`.

The arm is drawn the natural way, as nested rotations: the forearm sits inside
the upper arm's group, so it turns along with it. To drag the hand we just say
"vary the two joint angles" and keep the elbow within its range. The library
finds the angles that put the hand under the pointer by trying them out,
which is _inverse kinematics_ without writing any. Dragging the elbow varies
only the shoulder.

When the pointer is out of reach, the arm stretches towards it as far as it
can; when the elbow hits its limit, the hand slides along the edge of what it
can reach.

-}

import Evg exposing (Evg)
import Evg.Drag as Drag
import Evg.Transform as Transform
import Html exposing (Html)


type alias State =
    { shoulder : Float
    , elbow : Float
    }


type alias Model =
    Drag.Model State


type Msg
    = DragMsg (Drag.Msg State)


init : Model
init =
    Drag.init { shoulder = -60, elbow = 70 }


update : Msg -> Model -> Model
update (DragMsg dragMsg) model =
    Drag.update arm dragMsg model


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map DragMsg (Drag.subscriptions model)


view : Model -> Html Msg
view model =
    Evg.svg [] { width = 300, height = 260 } [ Drag.view DragMsg arm model ]


arm : Drag.View State Msg
arm ctx state =
    let
        moveHand () =
            Drag.vary2 ( state.shoulder, state.elbow ) (\shoulder elbow -> { shoulder = shoulder, elbow = elbow })
                |> Drag.constrain (\s -> Drag.inOrder [ 0, s.elbow, 150 ])

        moveElbow () =
            Drag.vary state.shoulder (\shoulder -> { state | shoulder = shoulder })
    in
    Evg.group [ Transform.translate 150 150 ]
        [ Evg.rect [ Evg.fillStr "#495057", Evg.cornerRadius 4 ] { x = -30, y = 0, width = 60, height = 16 }
        , Evg.group [ Transform.rotate state.shoulder ]
            [ segment 80
            , Evg.group [ Transform.translate 80 0, Transform.rotate state.elbow ]
                [ segment 70
                , Evg.circle [ Evg.fillStr "#f08c00", Drag.onDrag ctx "hand" moveHand ] { r = 12, center = ( 70, 0 ) }
                ]
            , Evg.circle [ Evg.fillStr "#1c7ed6", Drag.onDrag ctx "elbow" moveElbow ] { r = 9, center = ( 80, 0 ) }
            ]
        , Evg.circle [ Evg.fillStr "#343a40" ] { r = 9, center = ( 0, 0 ) }
        ]


segment : Float -> Evg msg
segment length =
    Evg.line [ Evg.strokeStr "#adb5bd", Evg.strokeWidth 14, Evg.linecapRound ] ( 0, 0 ) ( length, 0 )
