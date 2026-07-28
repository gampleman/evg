module KeyframesDefsTypedSvg exposing (main)

{-| Animating between different defs — typed-svg version, hand-written SMIL.
Mirrors KeyframesDefsEvg: gradient stops, filter blur, patterns, and a clip
path all animate. Where evg regenerates defs from keyframes, raw SMIL has to
animate the defs' internals directly (or crossfade, for patterns).
-}

import Html exposing (Html)
import TypedSvg
import TypedSvg.Attributes
import TypedSvg.Core exposing (Svg)
import TypedSvg.Filters
import TypedSvg.Filters.Attributes
import TypedSvg.Types


main : Html msg
main =
    TypedSvg.svg
        [ TypedSvg.Attributes.viewBox 0 0 500 300
        , TypedSvg.Attributes.width (TypedSvg.Types.px 500)
        , TypedSvg.Attributes.height (TypedSvg.Types.px 300)
        ]
        [ TypedSvg.defs []
            [ -- Animated gradient (sunset <-> ocean)
              TypedSvg.linearGradient
                [ TypedSvg.Attributes.id "kfdt-gradient"
                , TypedSvg.Attributes.x1 (TypedSvg.Types.px 0)
                , TypedSvg.Attributes.y1 (TypedSvg.Types.px 0)
                , TypedSvg.Attributes.x2 (TypedSvg.Types.px 0)
                , TypedSvg.Attributes.y2 (TypedSvg.Types.px 1)
                ]
                [ TypedSvg.stop [ TypedSvg.Attributes.offset "0", TypedSvg.Attributes.stopColor "rgb(255,100,0)" ]
                    [ TypedSvg.animate
                        [ TypedSvg.Attributes.attributeName "stop-color"
                        , TypedSvg.Core.attribute "values" "rgb(255,100,0);rgb(0,100,200);rgb(255,100,0)"
                        , TypedSvg.Attributes.keyTimes [ 0, 0.5, 1 ]
                        , TypedSvg.Attributes.calcMode TypedSvg.Types.CalcModeSpline
                        , TypedSvg.Attributes.keySplines [ { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 }, { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 } ]
                        , TypedSvg.Core.attribute "dur" "4s"
                        , TypedSvg.Attributes.repeatCount TypedSvg.Types.RepeatIndefinite
                        ]
                        []
                    ]
                , TypedSvg.stop [ TypedSvg.Attributes.offset "0.01", TypedSvg.Attributes.stopColor "rgb(255,100,0)" ]
                    [ TypedSvg.animate
                        [ TypedSvg.Attributes.attributeName "stop-color"
                        , TypedSvg.Core.attribute "values" "rgb(255,100,0);rgb(200,100,100);rgb(255,100,0)"
                        , TypedSvg.Attributes.keyTimes [ 0, 0.5, 1 ]
                        , TypedSvg.Attributes.calcMode TypedSvg.Types.CalcModeSpline
                        , TypedSvg.Attributes.keySplines [ { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 }, { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 } ]
                        , TypedSvg.Core.attribute "dur" "4s"
                        , TypedSvg.Attributes.repeatCount TypedSvg.Types.RepeatIndefinite
                        ]
                        []
                    , TypedSvg.animate
                        [ TypedSvg.Attributes.attributeName "offset"
                        , TypedSvg.Core.attribute "values" "0.01;0.5;0.01"
                        , TypedSvg.Attributes.keyTimes [ 0, 0.5, 1 ]
                        , TypedSvg.Attributes.calcMode TypedSvg.Types.CalcModeSpline
                        , TypedSvg.Attributes.keySplines [ { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 }, { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 } ]
                        , TypedSvg.Core.attribute "dur" "4s"
                        , TypedSvg.Attributes.repeatCount TypedSvg.Types.RepeatIndefinite
                        ]
                        []
                    ]
                , TypedSvg.stop [ TypedSvg.Attributes.offset "1", TypedSvg.Attributes.stopColor "rgb(255,200,50)" ]
                    [ TypedSvg.animate
                        [ TypedSvg.Attributes.attributeName "stop-color"
                        , TypedSvg.Core.attribute "values" "rgb(255,200,50);rgb(0,200,150);rgb(255,200,50)"
                        , TypedSvg.Attributes.keyTimes [ 0, 0.5, 1 ]
                        , TypedSvg.Attributes.calcMode TypedSvg.Types.CalcModeSpline
                        , TypedSvg.Attributes.keySplines [ { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 }, { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 } ]
                        , TypedSvg.Core.attribute "dur" "4s"
                        , TypedSvg.Attributes.repeatCount TypedSvg.Types.RepeatIndefinite
                        ]
                        []
                    ]
                ]

            -- Animated blur filter
            , TypedSvg.filter
                [ TypedSvg.Attributes.id "kfdt-blur"
                , TypedSvg.Core.attribute "color-interpolation-filters" "sRGB"
                ]
                [ TypedSvg.Filters.gaussianBlur
                    [ TypedSvg.Filters.Attributes.in_ TypedSvg.Types.InSourceGraphic
                    , TypedSvg.Core.attribute "stdDeviation" "0"
                    ]
                    [ TypedSvg.animate
                        [ TypedSvg.Attributes.attributeName "stdDeviation"
                        , TypedSvg.Core.attribute "values" "0;5;0"
                        , TypedSvg.Attributes.keyTimes [ 0, 0.5, 1 ]
                        , TypedSvg.Attributes.calcMode TypedSvg.Types.CalcModeSpline
                        , TypedSvg.Attributes.keySplines [ { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 }, { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 } ]
                        , TypedSvg.Core.attribute "dur" "4s"
                        , TypedSvg.Attributes.repeatCount TypedSvg.Types.RepeatIndefinite
                        ]
                        []
                    ]
                ]

            -- Two static patterns (crossfaded in the scene below)
            , TypedSvg.pattern
                [ TypedSvg.Attributes.id "kfdt-checkers"
                , TypedSvg.Core.attribute "width" "0.25"
                , TypedSvg.Core.attribute "height" "0.25"
                , TypedSvg.Attributes.patternContentUnits TypedSvg.Types.CoordinateSystemObjectBoundingBox
                ]
                [ TypedSvg.rect [ TypedSvg.Core.attribute "width" "0.25", TypedSvg.Core.attribute "height" "0.25", TypedSvg.Core.attribute "fill" "white" ] []
                , TypedSvg.rect [ TypedSvg.Core.attribute "width" "0.125", TypedSvg.Core.attribute "height" "0.125", TypedSvg.Core.attribute "fill" "royalblue" ] []
                , TypedSvg.rect [ TypedSvg.Core.attribute "x" "0.125", TypedSvg.Core.attribute "y" "0.125", TypedSvg.Core.attribute "width" "0.125", TypedSvg.Core.attribute "height" "0.125", TypedSvg.Core.attribute "fill" "royalblue" ] []
                ]
            , TypedSvg.pattern
                [ TypedSvg.Attributes.id "kfdt-stripes"
                , TypedSvg.Core.attribute "width" "0.1"
                , TypedSvg.Core.attribute "height" "1"
                , TypedSvg.Attributes.patternContentUnits TypedSvg.Types.CoordinateSystemObjectBoundingBox
                ]
                [ TypedSvg.rect [ TypedSvg.Core.attribute "width" "0.1", TypedSvg.Core.attribute "height" "1", TypedSvg.Core.attribute "fill" "white" ] []
                , TypedSvg.rect [ TypedSvg.Core.attribute "width" "0.05", TypedSvg.Core.attribute "height" "1", TypedSvg.Core.attribute "fill" "coral" ] []
                ]

            -- Animated clip path
            , TypedSvg.clipPath [ TypedSvg.Attributes.id "kfdt-clip" ]
                [ TypedSvg.circle
                    [ TypedSvg.Attributes.cx (TypedSvg.Types.px 410)
                    , TypedSvg.Attributes.cy (TypedSvg.Types.px 50)
                    , TypedSvg.Attributes.r (TypedSvg.Types.px 10)
                    ]
                    [ TypedSvg.animate
                        [ TypedSvg.Attributes.attributeName "r"
                        , TypedSvg.Core.attribute "values" "10;40;10"
                        , TypedSvg.Attributes.keyTimes [ 0, 0.5, 1 ]
                        , TypedSvg.Attributes.calcMode TypedSvg.Types.CalcModeSpline
                        , TypedSvg.Attributes.keySplines [ { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 }, { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 } ]
                        , TypedSvg.Core.attribute "dur" "4s"
                        , TypedSvg.Attributes.repeatCount TypedSvg.Types.RepeatIndefinite
                        ]
                        []
                    ]
                ]
            ]

        -- Gradient animation
        , TypedSvg.rect
            [ TypedSvg.Attributes.x (TypedSvg.Types.px 10)
            , TypedSvg.Attributes.y (TypedSvg.Types.px 10)
            , TypedSvg.Attributes.width (TypedSvg.Types.px 100)
            , TypedSvg.Attributes.height (TypedSvg.Types.px 100)
            , TypedSvg.Attributes.fill (TypedSvg.Types.Reference "kfdt-gradient")
            ]
            []

        -- Filter animation
        , TypedSvg.circle
            [ TypedSvg.Attributes.cx (TypedSvg.Types.px 190)
            , TypedSvg.Attributes.cy (TypedSvg.Types.px 60)
            , TypedSvg.Attributes.r (TypedSvg.Types.px 45)
            , TypedSvg.Core.attribute "fill" "tomato"
            , TypedSvg.Attributes.filter (TypedSvg.Types.Filter "url(#kfdt-blur)")
            ]
            []

        -- Pattern animation (crossfade between two pattern fills)
        , TypedSvg.rect
            [ TypedSvg.Attributes.x (TypedSvg.Types.px 260)
            , TypedSvg.Attributes.y (TypedSvg.Types.px 10)
            , TypedSvg.Attributes.width (TypedSvg.Types.px 100)
            , TypedSvg.Attributes.height (TypedSvg.Types.px 100)
            , TypedSvg.Attributes.fill (TypedSvg.Types.Reference "kfdt-checkers")
            ]
            []
        , TypedSvg.rect
            [ TypedSvg.Attributes.x (TypedSvg.Types.px 260)
            , TypedSvg.Attributes.y (TypedSvg.Types.px 10)
            , TypedSvg.Attributes.width (TypedSvg.Types.px 100)
            , TypedSvg.Attributes.height (TypedSvg.Types.px 100)
            , TypedSvg.Attributes.fill (TypedSvg.Types.Reference "kfdt-stripes")
            , TypedSvg.Attributes.opacity (TypedSvg.Types.Opacity 0)
            ]
            [ TypedSvg.animate
                [ TypedSvg.Attributes.attributeName "opacity"
                , TypedSvg.Core.attribute "values" "0;1;0"
                , TypedSvg.Attributes.keyTimes [ 0, 0.5, 1 ]
                , TypedSvg.Attributes.calcMode TypedSvg.Types.CalcModeSpline
                , TypedSvg.Attributes.keySplines [ { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 }, { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 } ]
                , TypedSvg.Core.attribute "dur" "4s"
                , TypedSvg.Attributes.repeatCount TypedSvg.Types.RepeatIndefinite
                ]
                []
            ]

        -- Clip animation
        , TypedSvg.rect
            [ TypedSvg.Attributes.x (TypedSvg.Types.px 380)
            , TypedSvg.Attributes.y (TypedSvg.Types.px 10)
            , TypedSvg.Attributes.width (TypedSvg.Types.px 100)
            , TypedSvg.Attributes.height (TypedSvg.Types.px 100)
            , TypedSvg.Core.attribute "fill" "mediumseagreen"
            , TypedSvg.Attributes.clipPath (TypedSvg.Types.ClipPathFunc "url(#kfdt-clip)")
            ]
            []
        ]
