module KanbanElmSvg exposing (Model, Msg, init, subscriptions, update, view)

{-| The same kanban board, by hand with `elm/svg`.

What we have to do ourselves:

  - track the held card, its grab offset and the pointer (mouse only, on the
    window; touch would need separate handling);
  - map the pointer to a column from its x, and to a slot from its y,
    clamping both;
  - draw the board as it _would_ be with the card dropped there, minus the
    held card, plus the held card at the pointer, so the other cards make
    room;
  - keep every card's DOM node alive across columns so CSS can animate it:
    cards can't live inside their column's `<g>` (moving to another column
    would recreate the node), so all cards are drawn in one keyed layer with
    absolute positions computed from their column and slot;
  - switch the transition off for the held card;
  - recompute the column counts from the previewed board.

-}

import Browser.Events
import Html exposing (Html)
import Json.Decode as Decode exposing (Decoder)
import Svg exposing (Svg)
import Svg.Attributes as SA
import Svg.Events
import Svg.Keyed


type alias Column =
    { name : String
    , cards : List String
    }


type alias Model =
    { columns : List Column
    , drag : Maybe Drag
    }


{-| `grab` is the pointer's offset from the card's corner; `svgOrigin`
converts client pixels to drawing coordinates.
-}
type alias Drag =
    { card : String
    , grab : ( Float, Float )
    , svgOrigin : ( Float, Float )
    , pointer : ( Float, Float )
    }


type Msg
    = Pressed String ( Float, Float ) ( Float, Float )
    | Moved ( Float, Float )
    | Released


init : Model
init =
    { columns =
        [ { name = "To do", cards = [ "Groceries", "Taxes", "Call mum" ] }
        , { name = "Doing", cards = [ "Laundry" ] }
        , { name = "Done", cards = [ "Dishes", "Gym" ] }
        ]
    , drag = Nothing
    }


columnX : Int -> Float
columnX i =
    8 + toFloat i * 106


cardY : Int -> Float
cardY slot =
    8 + 32 + toFloat slot * 40


update : Msg -> Model -> Model
update msg model =
    case msg of
        Pressed name ( ox, oy ) ( cx, cy ) ->
            case findCard name model.columns of
                Just ( col, slot ) ->
                    { model
                        | drag =
                            Just
                                { card = name
                                , grab = ( ox - (columnX col + 6), oy - cardY slot )
                                , svgOrigin = ( cx - ox, cy - oy )
                                , pointer = ( ox, oy )
                                }
                    }

                Nothing ->
                    model

        Moved ( cx, cy ) ->
            case model.drag of
                Just drag ->
                    { model | drag = Just { drag | pointer = ( cx - Tuple.first drag.svgOrigin, cy - Tuple.second drag.svgOrigin ) } }

                Nothing ->
                    model

        Released ->
            case model.drag of
                Just drag ->
                    { columns = previewColumns model.columns drag, drag = Nothing }

                Nothing ->
                    model


findCard : String -> List Column -> Maybe ( Int, Int )
findCard name columns =
    columns
        |> List.indexedMap
            (\c col ->
                col.cards
                    |> List.indexedMap Tuple.pair
                    |> List.filter (\( _, n ) -> n == name)
                    |> List.head
                    |> Maybe.map (\( slot, _ ) -> ( c, slot ))
            )
        |> List.filterMap identity
        |> List.head


{-| The board with the held card moved to where the pointer is.
-}
previewColumns : List Column -> Drag -> List Column
previewColumns columns drag =
    let
        ( px, py ) =
            drag.pointer

        -- Where the card's corner would be.
        cornerX =
            px - Tuple.first drag.grab

        cornerY =
            py - Tuple.second drag.grab

        without =
            List.map (\col -> { col | cards = List.filter ((/=) drag.card) col.cards }) columns

        target =
            clamp 0 (List.length columns - 1) (round ((cornerX - 14) / 106))

        slotsIn =
            without |> List.drop target |> List.head |> Maybe.map (.cards >> List.length) |> Maybe.withDefault 0

        slot =
            clamp 0 slotsIn (round ((cornerY - cardY 0) / 40))
    in
    List.indexedMap
        (\i col ->
            if i == target then
                { col | cards = List.take slot col.cards ++ drag.card :: List.drop slot col.cards }

            else
                col
        )
        without


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.drag of
        Just _ ->
            Sub.batch
                [ Browser.Events.onMouseMove (Decode.map Moved (pair "clientX" "clientY"))
                , Browser.Events.onMouseUp (Decode.succeed Released)
                ]

        Nothing ->
            Sub.none


pair : String -> String -> Decoder ( Float, Float )
pair kx ky =
    Decode.map2 Tuple.pair (Decode.field kx Decode.float) (Decode.field ky Decode.float)


view : Model -> Html Msg
view model =
    let
        columns =
            case model.drag of
                Just drag ->
                    previewColumns model.columns drag

                Nothing ->
                    model.columns

        placed =
            columns
                |> List.indexedMap
                    (\c col ->
                        List.indexedMap (\slot name -> ( name, ( columnX c + 6, cardY slot ) )) col.cards
                    )
                |> List.concat

        -- The held card follows the pointer and is drawn last, on top.
        cards =
            List.map
                (\( name, pos ) ->
                    case model.drag of
                        Just drag ->
                            if drag.card == name then
                                ( name, viewCard name ( Tuple.first drag.pointer - Tuple.first drag.grab, Tuple.second drag.pointer - Tuple.second drag.grab ) True )

                            else
                                ( name, viewCard name pos False )

                        Nothing ->
                            ( name, viewCard name pos False )
                )
                placed
                |> List.sortBy
                    (\( name, _ ) ->
                        if Maybe.map .card model.drag == Just name then
                            1

                        else
                            0
                    )
    in
    Svg.svg [ SA.width "330", SA.height "260", SA.viewBox "0 0 330 260" ]
        [ Svg.g [] (List.indexedMap viewColumn columns)
        , Svg.Keyed.node "g" [] cards
        ]


viewColumn : Int -> Column -> Svg Msg
viewColumn index col =
    Svg.g [ SA.transform ("translate(" ++ String.fromFloat (columnX index) ++ " 8)") ]
        [ Svg.rect [ SA.width "98", SA.height "240", SA.rx "8", SA.fill "#f1f3f5" ] []
        , Svg.text_ [ SA.x "10", SA.y "20", SA.fontSize "12", SA.fill "#495057" ]
            [ Svg.text (col.name ++ " (" ++ String.fromInt (List.length col.cards) ++ ")") ]
        ]


viewCard : String -> ( Float, Float ) -> Bool -> Svg Msg
viewCard name ( x, y ) held =
    Svg.g
        [ SA.style
            ("transform: translate("
                ++ String.fromFloat x
                ++ "px, "
                ++ String.fromFloat y
                ++ "px); transition: "
                ++ (if held then
                        "none"

                    else
                        "transform 0.2s ease-out"
                   )
            )
        , SA.cursor "grab"
        , Svg.Events.on "pointerdown" (Decode.map2 (Pressed name) (pair "offsetX" "offsetY") (pair "clientX" "clientY"))
        ]
        [ Svg.rect [ SA.width "86", SA.height "34", SA.rx "4", SA.fill "white", SA.stroke "#ced4da" ] []
        , Svg.text_ [ SA.x "8", SA.y "21", SA.fontSize "12" ] [ Svg.text name ]
        ]
