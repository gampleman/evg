module KanbanEvg exposing (Model, Msg, init, subscriptions, update, view)

{-| A kanban board with `Evg.Drag`.

A card can go anywhere: any column, any position. So that is exactly what
its drag spec lists, every board you could get by moving that card. The
library previews the one nearest the pointer while the card floats, and
because cards have keys it can follow a card from one column's group into
another's, so cards slide across instead of vanishing and reappearing.

The column counts update live mid-drag too, for free: they are part of the
previewed state.

-}

import Evg exposing (Evg)
import Evg.Drag as Drag
import Evg.Transform as Transform
import Html exposing (Html)


type alias Column =
    { name : String
    , cards : List String
    }


type alias State =
    { columns : List Column }


type alias Model =
    Drag.Model State


type Msg
    = DragMsg (Drag.Msg State)


init : Model
init =
    Drag.init
        { columns =
            [ { name = "To do", cards = [ "Groceries", "Taxes", "Call mum" ] }
            , { name = "Doing", cards = [ "Laundry" ] }
            , { name = "Done", cards = [ "Dishes", "Gym" ] }
            ]
        }


update : Msg -> Model -> Model
update (DragMsg dragMsg) model =
    Drag.update board dragMsg model


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map DragMsg (Drag.subscriptions model)


view : Model -> Html Msg
view model =
    Evg.svg [] { width = 330, height = 260 } [ Drag.view DragMsg board model ]


board : Drag.View State Msg
board ctx state =
    Evg.group [ Transform.translate 8 8 ]
        (List.indexedMap (column ctx state) state.columns)


column : Drag.Context State Msg -> State -> Int -> Column -> Evg Msg
column ctx state index col =
    Evg.group [ Transform.translate (toFloat index * 106) 0 ]
        (Evg.rect [ Evg.fillStr "#f1f3f5", Evg.cornerRadius 8 ] { x = 0, y = 0, width = 98, height = 240 }
            :: Evg.text [ Evg.fontSize 12, Evg.fillStr "#495057" ]
                { x = 10, y = 20, anchor = Evg.Start }
                (col.name ++ " (" ++ String.fromInt (List.length col.cards) ++ ")")
            :: List.indexedMap (card ctx state) col.cards
        )


card : Drag.Context State Msg -> State -> Int -> String -> Evg Msg
card ctx state index name =
    Evg.group
        [ Drag.onDrag ctx name (\() -> Drag.closest (everyMove name state) |> Drag.withFloating)
        , Transform.translate 6 (32 + toFloat index * 40)
        ]
        [ Evg.rect [ Evg.fillStr "white", Evg.strokeStr "#ced4da", Evg.cornerRadius 4 ] { x = 0, y = 0, width = 86, height = 34 }
        , Evg.text [ Evg.fontSize 12 ] { x = 8, y = 21, anchor = Evg.Start } name
        ]


{-| Every board you can get by taking `name` out and putting it back
somewhere.
-}
everyMove : String -> State -> List State
everyMove name state =
    let
        without =
            List.map (\col -> { col | cards = List.filter ((/=) name) col.cards }) state.columns
    in
    List.indexedMap
        (\target col ->
            List.range 0 (List.length col.cards)
                |> List.map
                    (\slot ->
                        { columns =
                            List.indexedMap
                                (\i c ->
                                    if i == target then
                                        { c | cards = List.take slot c.cards ++ name :: List.drop slot c.cards }

                                    else
                                        c
                                )
                                without
                        }
                    )
        )
        without
        |> List.concat
