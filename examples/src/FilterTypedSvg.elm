module FilterTypedSvg exposing (main)

{-| Splash text filter example from the README — typed-svg version.
-}

import Color
import Html exposing (Html)
import TypedSvg
import TypedSvg.Attributes
import TypedSvg.Core
import TypedSvg.Filters
import TypedSvg.Filters.Attributes
import TypedSvg.Types


main : Html msg
main =
    TypedSvg.svg
        [ TypedSvg.Attributes.viewBox 0 0 640 300
        , TypedSvg.Attributes.width (TypedSvg.Types.px 640)
        , TypedSvg.Attributes.height (TypedSvg.Types.px 300)
        ]
        [ TypedSvg.defs []
            [ splashFilter
            ]
        , TypedSvg.text_
            [ TypedSvg.Attributes.fontSize (TypedSvg.Types.px 160)
            , TypedSvg.Attributes.x (TypedSvg.Types.px 320)
            , TypedSvg.Attributes.y (TypedSvg.Types.px 170)
            , TypedSvg.Attributes.textAnchor TypedSvg.Types.AnchorMiddle
            , TypedSvg.Attributes.fill (TypedSvg.Types.Paint (Color.rgb255 22 181 255))
            , TypedSvg.Attributes.filter (TypedSvg.Types.Filter "url(#my-filter)")
            , TypedSvg.Attributes.fontFamily [ "'Racing Sans One'", "cursive" ]
            ]
            [ TypedSvg.Core.text "Evg" ]
        ]


splashFilter : TypedSvg.Core.Svg msg
splashFilter =
    TypedSvg.filter
        [ TypedSvg.Attributes.id "my-filter"
        , TypedSvg.Core.attribute "width" "150%"
        , TypedSvg.Core.attribute "height" "160%"
        , TypedSvg.Core.attribute "x" "-25%"
        , TypedSvg.Core.attribute "y" "-25%"
        ]
        [ TypedSvg.Filters.flood [ TypedSvg.Core.attribute "flood-color" "#16B5FF", TypedSvg.Filters.Attributes.result "COLOR-blue" ] []
        , TypedSvg.Filters.flood [ TypedSvg.Core.attribute "flood-color" "#9800FF", TypedSvg.Filters.Attributes.result "COLOR-violet" ] []
        , TypedSvg.Filters.flood [ TypedSvg.Core.attribute "flood-color" "#A64DFF", TypedSvg.Filters.Attributes.result "COLOR-violet-light" ] []

        -- BOTTOM SPLASH
        , TypedSvg.Filters.turbulence
            [ TypedSvg.Filters.Attributes.baseFrequency 0.05 0.05
            , TypedSvg.Filters.Attributes.turbulenceType TypedSvg.Types.TurbulenceTypeFractalNoise
            , TypedSvg.Filters.Attributes.numOctaves 1
            , TypedSvg.Filters.Attributes.seed 1
            , TypedSvg.Filters.Attributes.result "BOTTOM-SPLASH_10"
            ]
            []
        , TypedSvg.Filters.gaussianBlur
            [ TypedSvg.Core.attribute "stdDeviation" "6.5"
            , TypedSvg.Filters.Attributes.in_ TypedSvg.Types.InSourceAlpha
            , TypedSvg.Filters.Attributes.result "BOTTOM-SPLASH_20"
            ]
            []
        , TypedSvg.Filters.displacementMap
            [ TypedSvg.Filters.Attributes.scale 420
            , TypedSvg.Filters.Attributes.in_ (TypedSvg.Types.InReference "BOTTOM-SPLASH_20")
            , TypedSvg.Filters.Attributes.in2 (TypedSvg.Types.InReference "BOTTOM-SPLASH_10")
            , TypedSvg.Filters.Attributes.result "BOTTOM-SPLASH_30"
            ]
            []
        , TypedSvg.Filters.composite
            [ TypedSvg.Filters.Attributes.compositeOperator TypedSvg.Types.CompositeOperatorIn
            , TypedSvg.Filters.Attributes.in_ (TypedSvg.Types.InReference "COLOR-blue")
            , TypedSvg.Filters.Attributes.in2 (TypedSvg.Types.InReference "BOTTOM-SPLASH_30")
            , TypedSvg.Filters.Attributes.result "BOTTOM-SPLASH_40"
            ]
            []

        -- MIDDLE SPLASH
        , TypedSvg.Filters.turbulence
            [ TypedSvg.Filters.Attributes.baseFrequency 0.1 0.1
            , TypedSvg.Filters.Attributes.turbulenceType TypedSvg.Types.TurbulenceTypeFractalNoise
            , TypedSvg.Filters.Attributes.numOctaves 1
            , TypedSvg.Filters.Attributes.seed 1
            , TypedSvg.Filters.Attributes.result "MIDDLE-SPLASH_10"
            ]
            []
        , TypedSvg.Filters.gaussianBlur
            [ TypedSvg.Filters.Attributes.in_ TypedSvg.Types.InSourceAlpha
            , TypedSvg.Core.attribute "stdDeviation" "0.1"
            , TypedSvg.Filters.Attributes.result "MIDDLE-SPLASH_20"
            ]
            []
        , TypedSvg.Filters.displacementMap
            [ TypedSvg.Filters.Attributes.in_ (TypedSvg.Types.InReference "MIDDLE-SPLASH_20")
            , TypedSvg.Filters.Attributes.in2 (TypedSvg.Types.InReference "MIDDLE-SPLASH_10")
            , TypedSvg.Filters.Attributes.scale 25
            , TypedSvg.Filters.Attributes.result "MIDDLE-SPLASH_30"
            ]
            []
        , TypedSvg.Filters.composite
            [ TypedSvg.Filters.Attributes.in_ (TypedSvg.Types.InReference "COLOR-violet-light")
            , TypedSvg.Filters.Attributes.in2 (TypedSvg.Types.InReference "MIDDLE-SPLASH_30")
            , TypedSvg.Filters.Attributes.compositeOperator TypedSvg.Types.CompositeOperatorIn
            , TypedSvg.Filters.Attributes.result "MIDDLE-SPLASH_40"
            ]
            []

        -- TOP SPLASH
        , TypedSvg.Filters.turbulence
            [ TypedSvg.Filters.Attributes.baseFrequency 0.07 0.07
            , TypedSvg.Filters.Attributes.turbulenceType TypedSvg.Types.TurbulenceTypeFractalNoise
            , TypedSvg.Filters.Attributes.numOctaves 1
            , TypedSvg.Filters.Attributes.seed 1
            , TypedSvg.Filters.Attributes.result "TOP-SPLASH_10"
            ]
            []
        , TypedSvg.Filters.gaussianBlur
            [ TypedSvg.Core.attribute "stdDeviation" "3.5"
            , TypedSvg.Filters.Attributes.in_ TypedSvg.Types.InSourceAlpha
            , TypedSvg.Filters.Attributes.result "TOP-SPLASH_20"
            ]
            []
        , TypedSvg.Filters.displacementMap
            [ TypedSvg.Filters.Attributes.scale 220
            , TypedSvg.Filters.Attributes.in_ (TypedSvg.Types.InReference "TOP-SPLASH_20")
            , TypedSvg.Filters.Attributes.in2 (TypedSvg.Types.InReference "TOP-SPLASH_10")
            , TypedSvg.Filters.Attributes.result "TOP-SPLASH_30"
            ]
            []
        , TypedSvg.Filters.composite
            [ TypedSvg.Filters.Attributes.compositeOperator TypedSvg.Types.CompositeOperatorIn
            , TypedSvg.Filters.Attributes.in_ (TypedSvg.Types.InReference "COLOR-violet")
            , TypedSvg.Filters.Attributes.in2 (TypedSvg.Types.InReference "TOP-SPLASH_30")
            , TypedSvg.Filters.Attributes.result "TOP-SPLASH_40"
            ]
            []

        -- MERGE
        , TypedSvg.Filters.merge [ TypedSvg.Filters.Attributes.result "LIGHT-EFFECTS_10" ]
            [ TypedSvg.Filters.mergeNode [ TypedSvg.Filters.Attributes.in_ (TypedSvg.Types.InReference "BOTTOM-SPLASH_40") ] []
            , TypedSvg.Filters.mergeNode [ TypedSvg.Filters.Attributes.in_ (TypedSvg.Types.InReference "MIDDLE-SPLASH_40") ] []
            , TypedSvg.Filters.mergeNode [ TypedSvg.Filters.Attributes.in_ (TypedSvg.Types.InReference "TOP-SPLASH_40") ] []
            ]
        ]
