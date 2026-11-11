module SortableEvg exposing (Model, Msg, init, subscriptions, update, view)

{-| A reorderable list with `Evg.Drag`.

Dragging a row offers every possible reordering of the list
(`Drag.closest`), and `withFloating` lets the grabbed row follow the pointer
while the others slide aside to show where it would land. The view never
mentions dragging beyond that: no drop indicator maths, no offsets, no
animation code. Rows glide because each one has a key, so the library knows
it is the same row in every state.

-}

import Evg exposing (Evg)
import Evg.Drag as Drag
import Evg.Transform as Transform
import Html exposing (Html)


type alias State =
    { tasks : List String }


type alias Model =
    Drag.Model State


type Msg
    = DragMsg (Drag.Msg State)


init : Model
init =
    Drag.init { tasks = [ "Write the paper", "Port it to Elm", "Draw examples", "Fix the bugs", "Ship it" ] }


update : Msg -> Model -> Model
update (DragMsg dragMsg) model =
    Drag.update sortable dragMsg model


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map DragMsg (Drag.subscriptions model)


view : Model -> Html Msg
view model =
    Evg.svg [] { width = 300, height = 250 } [ Drag.view DragMsg sortable model ]


sortable : Drag.View State Msg
sortable ctx state =
    Evg.group [ Transform.translate 40 10 ]
        (List.indexedMap (row ctx state) state.tasks)


row : Drag.Context State Msg -> State -> Int -> String -> Evg Msg
row ctx state index task =
    let
        everyPlacement =
            List.range 0 (List.length state.tasks - 1)
                |> List.map (\slot -> { tasks = moveItem index slot state.tasks })

        lifted =
            Drag.dragged ctx == Just task
    in
    Evg.group
        [ Drag.onDrag ctx task (\() -> Drag.closest everyPlacement |> Drag.withFloating)
        , Transform.translate 0 (toFloat index * 46)
        ]
        [ Evg.rect
            [ Evg.cornerRadius 6
            , Evg.fillStr "white"
            , Evg.strokeStr
                (if lifted then
                    "#1c7ed6"

                 else
                    "#ced4da"
                )
            , Evg.strokeWidth
                (if lifted then
                    2

                 else
                    1
                )
            ]
            { x = 0, y = 0, width = 220, height = 38 }
        , Evg.text [ Evg.fontSize 15 ] { x = 14, y = 24, anchor = Evg.Start } task
        ]


moveItem : Int -> Int -> List a -> List a
moveItem from to list =
    case List.drop from list of
        item :: _ ->
            let
                without =
                    List.take from list ++ List.drop (from + 1) list
            in
            List.take to without ++ item :: List.drop to without

        [] ->
            list
