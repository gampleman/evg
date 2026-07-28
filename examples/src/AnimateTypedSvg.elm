module AnimateTypedSvg exposing (main)

{-| Pulse rect animation from the README — typed-svg version.
-}

import Color
import Html exposing (Html)
import TypedSvg
import TypedSvg.Attributes
import TypedSvg.Core
import TypedSvg.Types


main : Html msg
main =
    TypedSvg.svg
        [ TypedSvg.Attributes.viewBox 0 0 120 120
        , TypedSvg.Attributes.width (TypedSvg.Types.px 120)
        , TypedSvg.Attributes.height (TypedSvg.Types.px 120)
        ]
        [ TypedSvg.rect
            [ TypedSvg.Attributes.rx (TypedSvg.Types.px 30)
            , TypedSvg.Attributes.fill (TypedSvg.Types.Paint (Color.rgb255 0 0 128))
            , TypedSvg.Attributes.x (TypedSvg.Types.px 10)
            , TypedSvg.Attributes.y (TypedSvg.Types.px 10)
            , TypedSvg.Attributes.width (TypedSvg.Types.px 100)
            , TypedSvg.Attributes.height (TypedSvg.Types.px 100)
            ]
            [ TypedSvg.animate
                [ TypedSvg.Attributes.attributeName "rx"
                , TypedSvg.Core.attribute "values" "30; 50; 20; 30"
                , TypedSvg.Core.attribute "begin" "0s"
                , TypedSvg.Core.attribute "dur" "3s"
                , TypedSvg.Attributes.keyTimes [ 0, 0.2, 0.6, 1 ]
                , TypedSvg.Attributes.calcMode TypedSvg.Types.CalcModeSpline
                , TypedSvg.Attributes.repeatCount TypedSvg.Types.RepeatIndefinite
                , TypedSvg.Attributes.keySplines
                    [ { x1 = 0, y1 = 0, x2 = 1, y2 = 1 }
                    , { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 }
                    , { x1 = 0, y1 = 0, x2 = 1, y2 = 1 }
                    ]
                ]
                []
            ]
        ]
