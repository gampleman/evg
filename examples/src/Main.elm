module Main exposing (main)

import AnimateElmSvg
import AnimateEvg
import AnimateTypedSvg
import BadgeElmSvg
import BadgeEvg
import BadgeTypedSvg
import Browser
import ChartElmSvg
import ChartEvg
import ChartTypedSvg
import Dict exposing (Dict)
import FilterElmSvg
import FilterEvg
import FilterTypedSvg
import GaugeElmSvg
import GaugeEvg
import GaugeTypedSvg
import GridElmSvg
import GridEvg
import GridTypedSvg
import Html exposing (Html, a, button, code, div, h1, h2, h3, p, pre, section, text)
import Html.Attributes exposing (class, href, style, target)
import Html.Events exposing (onClick)
import Html.Keyed as Keyed
import InteractiveElmSvg
import InteractiveEvg
import InteractiveTypedSvg
import Json.Decode as Decode
import KeyframesDefsElmSvg
import KeyframesDefsEvg
import KeyframesDefsTypedSvg
import KeyframesElmSvg
import KeyframesEvg
import KeyframesTypedSvg
import PatternElmSvg
import PatternEvg
import PatternTypedSvg
import PulseElmSvg
import PulseEvg
import PulseTypedSvg
import SunsetElmSvg
import SunsetEvg
import SunsetTypedSvg
import TextElmSvg
import TextEvg
import TextTypedSvg


main : Program Decode.Value Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { sources : Dict String String
    , leftLib : Library
    , rightLib : Library
    , interactiveEvg : InteractiveEvg.Model
    , interactiveElmSvg : InteractiveElmSvg.Model
    , interactiveTypedSvg : InteractiveTypedSvg.Model
    }


type Library
    = ElmSvg
    | TypedSvg
    | Evg


type Msg
    = SetLeft Library
    | SetRight Library
    | InteractiveEvgMsg InteractiveEvg.Msg
    | InteractiveElmSvgMsg InteractiveElmSvg.Msg
    | InteractiveTypedSvgMsg InteractiveTypedSvg.Msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map InteractiveEvgMsg (InteractiveEvg.subscriptions model.interactiveEvg)
        , Sub.map InteractiveElmSvgMsg (InteractiveElmSvg.subscriptions model.interactiveElmSvg)
        , Sub.map InteractiveTypedSvgMsg (InteractiveTypedSvg.subscriptions model.interactiveTypedSvg)
        ]


init : Decode.Value -> ( Model, Cmd Msg )
init flags =
    let
        sources =
            flags
                |> Decode.decodeValue (Decode.dict Decode.string)
                |> Result.withDefault Dict.empty
    in
    ( { sources = sources
      , leftLib = ElmSvg
      , rightLib = Evg
      , interactiveEvg = InteractiveEvg.init
      , interactiveElmSvg = InteractiveElmSvg.init
      , interactiveTypedSvg = InteractiveTypedSvg.init
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetLeft lib ->
            ( { model | leftLib = lib }, Cmd.none )

        SetRight lib ->
            ( { model | rightLib = lib }, Cmd.none )

        InteractiveEvgMsg subMsg ->
            ( { model | interactiveEvg = InteractiveEvg.update subMsg model.interactiveEvg }, Cmd.none )

        InteractiveElmSvgMsg subMsg ->
            ( { model | interactiveElmSvg = InteractiveElmSvg.update subMsg model.interactiveElmSvg }, Cmd.none )

        InteractiveTypedSvgMsg subMsg ->
            ( { model | interactiveTypedSvg = InteractiveTypedSvg.update subMsg model.interactiveTypedSvg }, Cmd.none )


view : Model -> Html Msg
view model =
    div [ style "font-family" "-apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif", style "margin" "0", style "padding" "20px", style "background" "#f5f5f5" ]
        [ h1 [ style "text-align" "center", style "color" "#333" ] [ text "Evg Examples" ]
        , p [ style "text-align" "center", style "color" "#666", style "margin-bottom" "20px" ]
            [ text "Side-by-side comparison of SVG libraries for Elm. "
            , a [ href "https://github.com/gampleman/evg/pulls", target "_blank" ] [ text "Submit a PR" ]
            , text " to add another library."
            ]
        , viewControls model
        , viewExamples model
        ]


viewControls : Model -> Html Msg
viewControls model =
    div [ style "display" "flex", style "justify-content" "center", style "gap" "40px", style "margin-bottom" "30px", style "flex-wrap" "wrap" ]
        [ div []
            [ h3 [ style "margin" "0 0 8px", style "font-size" "12px", style "color" "#888", style "text-transform" "uppercase" ] [ text "Left panel" ]
            , libSelector model.leftLib SetLeft
            ]
        , div []
            [ h3 [ style "margin" "0 0 8px", style "font-size" "12px", style "color" "#888", style "text-transform" "uppercase" ] [ text "Right panel" ]
            , libSelector model.rightLib SetRight
            ]
        ]


libSelector : Library -> (Library -> Msg) -> Html Msg
libSelector selected toMsg =
    div [ style "display" "flex", style "gap" "4px" ]
        [ libButton ElmSvg "elm/svg" selected toMsg
        , libButton TypedSvg "typed-svg" selected toMsg
        , libButton Evg "evg" selected toMsg
        ]


libButton : Library -> String -> Library -> (Library -> Msg) -> Html Msg
libButton lib label selected toMsg =
    button
        [ onClick (toMsg lib)
        , style "padding" "6px 12px"
        , style "border" "1px solid #ccc"
        , style "border-radius" "4px"
        , style "cursor" "pointer"
        , style "font-size" "13px"
        , style "background"
            (if lib == selected then
                "#333"

             else
                "white"
            )
        , style "color"
            (if lib == selected then
                "white"

             else
                "#333"
            )
        ]
        [ text label ]


viewExamples : Model -> Html Msg
viewExamples model =
    div []
        (List.map (viewExample model) (examples model))


type alias Example =
    { name : String
    , elmSvg : Maybe (Html Msg)
    , typedSvg : Maybe (Html Msg)
    , evg : Html Msg
    , elmSvgSource : String
    , typedSvgSource : String
    , evgSource : String
    }


examples : Model -> List Example
examples model =
    [ { name = "Grid"
      , elmSvg = Just GridElmSvg.main
      , typedSvg = Just GridTypedSvg.main
      , evg = GridEvg.main
      , elmSvgSource = "GridElmSvg"
      , typedSvgSource = "GridTypedSvg"
      , evgSource = "GridEvg"
      }
    , { name = "Sunset"
      , elmSvg = Just SunsetElmSvg.main
      , typedSvg = Just SunsetTypedSvg.main
      , evg = SunsetEvg.main
      , elmSvgSource = "SunsetElmSvg"
      , typedSvgSource = "SunsetTypedSvg"
      , evgSource = "SunsetEvg"
      }
    , { name = "Gauge"
      , elmSvg = Just GaugeElmSvg.main
      , typedSvg = Just GaugeTypedSvg.main
      , evg = GaugeEvg.main
      , elmSvgSource = "GaugeElmSvg"
      , typedSvgSource = "GaugeTypedSvg"
      , evgSource = "GaugeEvg"
      }
    , { name = "Badge"
      , elmSvg = Just BadgeElmSvg.main
      , typedSvg = Just BadgeTypedSvg.main
      , evg = BadgeEvg.main
      , elmSvgSource = "BadgeElmSvg"
      , typedSvgSource = "BadgeTypedSvg"
      , evgSource = "BadgeEvg"
      }
    , { name = "Chart"
      , elmSvg = Just ChartElmSvg.main
      , typedSvg = Just ChartTypedSvg.main
      , evg = ChartEvg.main
      , elmSvgSource = "ChartElmSvg"
      , typedSvgSource = "ChartTypedSvg"
      , evgSource = "ChartEvg"
      }
    , { name = "Filter"
      , elmSvg = Just FilterElmSvg.main
      , typedSvg = Just FilterTypedSvg.main
      , evg = FilterEvg.main
      , elmSvgSource = "FilterElmSvg"
      , typedSvgSource = "FilterTypedSvg"
      , evgSource = "FilterEvg"
      }
    , { name = "Text"
      , elmSvg = Just TextElmSvg.main
      , typedSvg = Just TextTypedSvg.main
      , evg = TextEvg.main
      , elmSvgSource = "TextElmSvg"
      , typedSvgSource = "TextTypedSvg"
      , evgSource = "TextEvg"
      }
    , { name = "Pattern"
      , elmSvg = Just PatternElmSvg.main
      , typedSvg = Just PatternTypedSvg.main
      , evg = PatternEvg.main
      , elmSvgSource = "PatternElmSvg"
      , typedSvgSource = "PatternTypedSvg"
      , evgSource = "PatternEvg"
      }
    , { name = "Animation"
      , elmSvg = Just AnimateElmSvg.main
      , typedSvg = Just AnimateTypedSvg.main
      , evg = AnimateEvg.main
      , elmSvgSource = "AnimateElmSvg"
      , typedSvgSource = "AnimateTypedSvg"
      , evgSource = "AnimateEvg"
      }
    , { name = "Pulse"
      , elmSvg = Just PulseElmSvg.main
      , typedSvg = Just PulseTypedSvg.main
      , evg = PulseEvg.main
      , elmSvgSource = "PulseElmSvg"
      , typedSvgSource = "PulseTypedSvg"
      , evgSource = "PulseEvg"
      }
    , { name = "Keyframes"
      , elmSvg = Just KeyframesElmSvg.main
      , typedSvg = Just KeyframesTypedSvg.main
      , evg = KeyframesEvg.main
      , elmSvgSource = "KeyframesElmSvg"
      , typedSvgSource = "KeyframesTypedSvg"
      , evgSource = "KeyframesEvg"
      }
    , { name = "Animated Defs"
      , elmSvg = Just KeyframesDefsElmSvg.main
      , typedSvg = Just KeyframesDefsTypedSvg.main
      , evg = KeyframesDefsEvg.main
      , elmSvgSource = "KeyframesDefsElmSvg"
      , typedSvgSource = "KeyframesDefsTypedSvg"
      , evgSource = "KeyframesDefsEvg"
      }
    , { name = "Interactive (drag + zoom)"
      , elmSvg = Just (Html.map InteractiveElmSvgMsg (InteractiveElmSvg.view model.interactiveElmSvg))
      , typedSvg = Just (Html.map InteractiveTypedSvgMsg (InteractiveTypedSvg.view model.interactiveTypedSvg))
      , evg = Html.map InteractiveEvgMsg (InteractiveEvg.view model.interactiveEvg)
      , elmSvgSource = "InteractiveElmSvg"
      , typedSvgSource = "InteractiveTypedSvg"
      , evgSource = "InteractiveEvg"
      }
    ]


viewExample : Model -> Example -> Html Msg
viewExample model ex =
    section
        [ style "background" "white"
        , style "border-radius" "8px"
        , style "padding" "20px"
        , style "margin" "20px 0"
        , style "box-shadow" "0 2px 4px rgba(0,0,0,0.1)"
        ]
        [ h2 [ style "margin-top" "0", style "color" "#555", style "border-bottom" "1px solid #eee", style "padding-bottom" "10px" ] [ text ex.name ]
        , Keyed.node "div"
            [ style "display" "flex", style "gap" "20px", style "flex-wrap" "wrap" ]
            [ ( ex.name ++ "-left-" ++ libToString model.leftLib, viewPanel model.sources model.leftLib ex )
            , ( ex.name ++ "-right-" ++ libToString model.rightLib, viewPanel model.sources model.rightLib ex )
            ]
        ]


viewPanel : Dict String String -> Library -> Example -> Html Msg
viewPanel sources lib ex =
    let
        ( label, rendered, sourceKey ) =
            case lib of
                ElmSvg ->
                    ( "elm/svg", ex.elmSvg, ex.elmSvgSource )

                TypedSvg ->
                    ( "elm-community/typed-svg", ex.typedSvg, ex.typedSvgSource )

                Evg ->
                    ( "gampleman/evg", Just ex.evg, ex.evgSource )

        sourceCode =
            Dict.get sourceKey sources
    in
    div [ style "flex" "1", style "min-width" "300px" ]
        [ h3 [ style "margin" "0 0 10px", style "font-size" "14px", style "color" "#888", style "text-transform" "uppercase", style "letter-spacing" "0.5px" ] [ text label ]
        , div [ style "border" "1px solid #e0e0e0", style "border-radius" "4px", style "padding" "10px", style "background" "white", style "min-height" "80px" ]
            [ case rendered of
                Just html ->
                    html

                Nothing ->
                    div [ style "color" "#aaa", style "font-style" "italic", style "padding" "20px" ]
                        [ text ("No " ++ label ++ " version yet — ")
                        , a [ href "https://github.com/gampleman/evg/pulls", target "_blank" ] [ text "contribute one!" ]
                        ]
            ]
        , case sourceCode of
            Just src ->
                pre [ style "margin" "8px 0 0", style "overflow-x" "auto" ]
                    [ code [ class "language-elm" ] [ text src ] ]

            Nothing ->
                text ""
        ]


libToString : Library -> String
libToString lib =
    case lib of
        ElmSvg ->
            "elm/svg"

        TypedSvg ->
            "elm-community/typed-svg"

        Evg ->
            "gampleman/evg"
