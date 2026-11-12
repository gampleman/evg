module SortableElmSvg exposing (Model, Msg, init, subscriptions, update, view)

{-| The same reorderable list, by hand with `elm/svg`.

What we have to do ourselves:

  - remember which row is held, where it was grabbed, and where the pointer is
    now (in client pixels, tracked on the window; touch would need separate
    handling, see `InteractiveElmSvg`);
  - turn the pointer's height into a target slot, rounding and clamping;
  - work out, for every _other_ row, whether it has to shift up or down to make
    room, which depends on whether the held row moves up or down the list;
  - draw the held row last so it stays on top, at the pointer;
  - animate rows sliding with CSS transitions, keyed rows so the DOM nodes
    survive reordering, and switch the transition off for the held row;
  - commit the new order on release.

-}

import Browser.Events
import Html exposing (Html)
import Json.Decode as Decode exposing (Decoder)
import Svg exposing (Svg)
import Svg.Attributes as SA
import Svg.Events
import Svg.Keyed


type alias Model =
    { tasks : List String
    , drag : Maybe Drag
    }


type alias Drag =
    { index : Int
    , startY : Float
    , currentY : Float
    }


type Msg
    = Pressed Int Float
    | Moved Float
    | Released


rowHeight : Float
rowHeight =
    46


init : Model
init =
    { tasks = [ "Write the paper", "Port it to Elm", "Draw examples", "Fix the bugs", "Ship it" ]
    , drag = Nothing
    }


update : Msg -> Model -> Model
update msg model =
    case msg of
        Pressed index y ->
            { model | drag = Just { index = index, startY = y, currentY = y } }

        Moved y ->
            case model.drag of
                Just drag ->
                    { model | drag = Just { drag | currentY = y } }

                Nothing ->
                    model

        Released ->
            case model.drag of
                Just drag ->
                    { tasks = moveItem drag.index (targetSlot model drag) model.tasks
                    , drag = Nothing
                    }

                Nothing ->
                    model


{-| The slot the held row would land in: its own slot shifted by however many
rows the pointer has travelled, rounded to the nearest row.
-}
targetSlot : Model -> Drag -> Int
targetSlot model drag =
    clamp 0
        (List.length model.tasks - 1)
        (drag.index + round ((drag.currentY - drag.startY) / rowHeight))


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.drag of
        Just _ ->
            Sub.batch
                [ Browser.Events.onMouseMove (Decode.map Moved clientY)
                , Browser.Events.onMouseUp (Decode.succeed Released)
                ]

        Nothing ->
            Sub.none


clientY : Decoder Float
clientY =
    Decode.field "clientY" Decode.float


view : Model -> Html Msg
view model =
    let
        rows =
            List.indexedMap (\i task -> ( task, viewRow model i task )) model.tasks

        -- The held row goes last so it is drawn above the others.
        ( held, others ) =
            List.partition (\( task, _ ) -> Maybe.map .index model.drag |> Maybe.andThen (\i -> List.head (List.drop i model.tasks)) |> (==) (Just task)) rows
    in
    Svg.svg [ SA.width "300", SA.height "250", SA.viewBox "0 0 300 250" ]
        [ Svg.Keyed.node "g" [ SA.transform "translate(40 10)" ] (others ++ held) ]


viewRow : Model -> Int -> String -> Svg Msg
viewRow model index task =
    let
        ( y, isHeld ) =
            case model.drag of
                Just drag ->
                    if drag.index == index then
                        ( toFloat index * rowHeight + drag.currentY - drag.startY, True )

                    else
                        let
                            slot =
                                targetSlot model drag

                            -- Rows between the held row's old and new slot
                            -- shift by one to make room.
                            shift =
                                if drag.index < index && index <= slot then
                                    -1

                                else if slot <= index && index < drag.index then
                                    1

                                else
                                    0
                        in
                        ( toFloat (index + shift) * rowHeight, False )

                Nothing ->
                    ( toFloat index * rowHeight, False )
    in
    Svg.g
        [ SA.style
            ("transform: translate(0px, "
                ++ String.fromFloat y
                ++ "px); transition: "
                ++ (if isHeld then
                        "none"

                    else
                        "transform 0.2s ease-out"
                   )
            )
        , SA.cursor "grab"
        , Svg.Events.on "pointerdown" (Decode.map (Pressed index) clientY)
        ]
        [ Svg.rect
            [ SA.width "220"
            , SA.height "38"
            , SA.rx "6"
            , SA.fill "white"
            , SA.stroke
                (if isHeld then
                    "#1c7ed6"

                 else
                    "#ced4da"
                )
            , SA.strokeWidth
                (if isHeld then
                    "2"

                 else
                    "1"
                )
            ]
            []
        , Svg.text_ [ SA.x "14", SA.y "24", SA.fontSize "15" ] [ Svg.text task ]
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
