module ToggleEvg exposing (Model, Msg, init, subscriptions, update, view)

{-| A toggle switch with `Evg.Drag`.

The whole interaction is one line: the knob can be dragged `between` the off
and on states. Everything else follows from drawing those two states:

  - mid-drag the knob slides along the track, and the track's colour blends
    from grey to green, because the library blends the _whole drawing_
    between the two states;
  - on release it settles into whichever state is nearer, overshooting a
    little (the same easing curves as `Evg.Animate`);
  - it works with mouse, touch and pen, and keeps following the pointer when
    it leaves the drawing.

-}

import Evg exposing (Evg)
import Evg.Animate as Animate
import Evg.Drag as Drag
import Evg.Transform as Transform
import Html exposing (Html)


type alias State =
    { on : Bool }


type alias Model =
    Drag.Model State


type Msg
    = DragMsg (Drag.Msg State)


init : Model
init =
    Drag.init { on = False }


update : Msg -> Model -> Model
update (DragMsg dragMsg) model =
    Drag.update toggle dragMsg model


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map DragMsg (Drag.subscriptions model)


view : Model -> Html Msg
view model =
    Evg.svg [] { width = 300, height = 120 } [ Drag.view DragMsg toggle model ]


toggle : Drag.View State Msg
toggle ctx state =
    Evg.group [ Transform.translate 90 30 ]
        [ Evg.rect
            [ Evg.cornerRadius 30
            , Evg.fillStr
                (if state.on then
                    "#40c057"

                 else
                    "#ced4da"
                )
            ]
            { x = 0, y = 0, width = 120, height = 60 }
        , Evg.circle
            [ Evg.fillStr "white"
            , Evg.strokeStr "#868e96"
            , Drag.onDrag ctx
                "knob"
                (\() ->
                    Drag.between [ { on = False }, { on = True } ]
                        |> Drag.withDropTransition 0.5 (Animate.cubicBezier 0.34 1.56 0.64 1)
                )
            ]
            { r = 26
            , center =
                if state.on then
                    ( 90, 30 )

                else
                    ( 30, 30 )
            }
        ]
