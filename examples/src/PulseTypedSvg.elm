module PulseTypedSvg exposing (main)

{-| An animated pulsing shape demonstrating SMIL animation.
Implemented with elm-community/typed-svg.
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
        [ TypedSvg.Attributes.viewBox 0 0 200 200
        , TypedSvg.Attributes.width (TypedSvg.Types.px 200)
        , TypedSvg.Attributes.height (TypedSvg.Types.px 200)
        ]
        [ TypedSvg.circle
            [ TypedSvg.Attributes.cx (TypedSvg.Types.px 100)
            , TypedSvg.Attributes.cy (TypedSvg.Types.px 100)
            , TypedSvg.Attributes.r (TypedSvg.Types.px 30)
            , TypedSvg.Attributes.fill (TypedSvg.Types.Paint (Color.rgb255 255 99 71))
            ]
            [ TypedSvg.animate
                [ TypedSvg.Attributes.attributeName "r"
                , TypedSvg.Core.attribute "values" "30;60;30"
                , TypedSvg.Core.attribute "dur" "2s"
                , TypedSvg.Attributes.keyTimes [ 0, 0.5, 1 ]
                , TypedSvg.Attributes.calcMode TypedSvg.Types.CalcModeSpline
                , TypedSvg.Attributes.keySplines [ { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 }, { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 } ]
                , TypedSvg.Attributes.repeatCount TypedSvg.Types.RepeatIndefinite
                ]
                []
            , TypedSvg.animate
                [ TypedSvg.Attributes.attributeName "opacity"
                , TypedSvg.Core.attribute "values" "1;0.5;1"
                , TypedSvg.Core.attribute "dur" "2s"
                , TypedSvg.Attributes.keyTimes [ 0, 0.5, 1 ]
                , TypedSvg.Attributes.calcMode TypedSvg.Types.CalcModeSpline
                , TypedSvg.Attributes.keySplines [ { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 }, { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 } ]
                , TypedSvg.Attributes.repeatCount TypedSvg.Types.RepeatIndefinite
                ]
                []
            ]
        ]
