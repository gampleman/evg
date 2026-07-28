module FilterElmSvg exposing (main)

{-| Splash text filter example from the README — elm/svg version.
-}

import Html exposing (Html)
import Svg exposing (Svg)
import Svg.Attributes


main : Html msg
main =
    Svg.svg [ Svg.Attributes.viewBox "0 0 640 300", Svg.Attributes.width "640", Svg.Attributes.height "300" ]
        [ Svg.defs []
            [ splashFilter
            ]
        , Svg.text_
            [ Svg.Attributes.fontSize "160px"
            , Svg.Attributes.x "320"
            , Svg.Attributes.y "170"
            , Svg.Attributes.textAnchor "middle"
            , Svg.Attributes.fill "#16B5FF"
            , Svg.Attributes.filter "url(#my-filter)"
            , Svg.Attributes.fontFamily "'Racing Sans One', cursive"
            ]
            [ Svg.text "Evg" ]
        ]


splashFilter : Svg msg
splashFilter =
    Svg.filter
        [ Svg.Attributes.id "my-filter" -- better hope that's unique
        , Svg.Attributes.width "150%"
        , Svg.Attributes.height "160%"
        , Svg.Attributes.x "-25%"
        , Svg.Attributes.y "-25%"
        ]
        [ -- colors
          Svg.feFlood [ Svg.Attributes.floodColor "#16B5FF", Svg.Attributes.result "COLOR-blue" ] []
        , Svg.feFlood [ Svg.Attributes.floodColor "#9800FF", Svg.Attributes.result "COLOR-violet" ] []
        , Svg.feFlood [ Svg.Attributes.floodColor "#A64DFF", Svg.Attributes.result "COLOR-violet-light" ]
            []

        -- BOTTOM SPLASH
        , Svg.feTurbulence
            [ Svg.Attributes.baseFrequency "0.05"
            , Svg.Attributes.type_ "fractalNoise"
            , Svg.Attributes.numOctaves "1"
            , Svg.Attributes.seed "1"
            , Svg.Attributes.result "BOTTOM-SPLASH_10"
            ]
            []
        , Svg.feGaussianBlur
            [ Svg.Attributes.stdDeviation "6.5"
            , Svg.Attributes.in_ "SourceAlpha"
            , Svg.Attributes.result "BOTTOM-SPLASH_20"
            ]
            []
        , Svg.feDisplacementMap
            [ Svg.Attributes.scale "420"
            , Svg.Attributes.in_ "BOTTOM-SPLASH_20"
            , Svg.Attributes.in2 "BOTTOM-SPLASH_10"
            , Svg.Attributes.result "BOTTOM-SPLASH_30"
            ]
            []
        , Svg.feComposite
            [ Svg.Attributes.operator "in"
            , Svg.Attributes.in_ "COLOR-blue"
            , Svg.Attributes.in2 "BOTTOM-SPLASH_30"
            , Svg.Attributes.result "BOTTOM-SPLASH_40"
            ]
            []
        , -- MIDDLE SPLASH
          Svg.feTurbulence
            [ Svg.Attributes.baseFrequency "0.1"
            , Svg.Attributes.type_ "fractalNoise"
            , Svg.Attributes.numOctaves "1"
            , Svg.Attributes.seed "1"
            , Svg.Attributes.result "MIDDLE-SPLASH_10"
            ]
            []
        , Svg.feGaussianBlur
            [ Svg.Attributes.in_ "SourceAlpha"
            , Svg.Attributes.stdDeviation "0.1"
            , Svg.Attributes.result "MIDDLE-SPLASH_20"
            ]
            []
        , Svg.feDisplacementMap
            [ Svg.Attributes.in_ "MIDDLE-SPLASH_20"
            , Svg.Attributes.in2 "MIDDLE-SPLASH_10"
            , Svg.Attributes.scale "25"
            , Svg.Attributes.result "MIDDLE-SPLASH_30"
            ]
            []
        , Svg.feComposite
            [ Svg.Attributes.in_ "COLOR-violet-light"
            , Svg.Attributes.in2 "MIDDLE-SPLASH_30"
            , Svg.Attributes.operator "in"
            , Svg.Attributes.result "MIDDLE-SPLASH_40"
            ]
            []
        , -- TOP SPLASH
          Svg.feTurbulence
            [ Svg.Attributes.baseFrequency "0.07"
            , Svg.Attributes.type_ "fractalNoise"
            , Svg.Attributes.numOctaves "1"
            , Svg.Attributes.seed "1"
            , Svg.Attributes.result "TOP-SPLASH_10"
            ]
            []
        , Svg.feGaussianBlur
            [ Svg.Attributes.stdDeviation "3.5"
            , Svg.Attributes.in_ "SourceAlpha"
            , Svg.Attributes.result "TOP-SPLASH_20"
            ]
            []
        , Svg.feDisplacementMap
            [ Svg.Attributes.scale "220"
            , Svg.Attributes.in_ "TOP-SPLASH_20"
            , Svg.Attributes.in2 "TOP-SPLASH_10"
            , Svg.Attributes.result "TOP-SPLASH_30"
            ]
            []
        , Svg.feComposite
            [ Svg.Attributes.operator "in"
            , Svg.Attributes.in_ "COLOR-violet"
            , Svg.Attributes.in2 "TOP-SPLASH_30"
            , Svg.Attributes.result "TOP-SPLASH_40"
            ]
            []
        , -- LIGHT EFFECTS
          Svg.feMerge [ Svg.Attributes.result "LIGHT-EFFECTS_10" ]
            [ Svg.feMergeNode [ Svg.Attributes.in_ "BOTTOM-SPLASH_40" ] []
            , Svg.feMergeNode [ Svg.Attributes.in_ "MIDDLE-SPLASH_40" ] []
            , Svg.feMergeNode [ Svg.Attributes.in_ "TOP-SPLASH_40" ] []
            ]
        , Svg.feColorMatrix
            [ Svg.Attributes.type_ "matrix"
            , Svg.Attributes.values "0 0 0 0 0, 0 0 0 0 0, 0 0 0 0 0, 0 0 0 1 0"
            , Svg.Attributes.in_ "LIGHT-EFFECTS_10"
            , Svg.Attributes.result "LIGHT-EFFECTS_20"
            ]
            []
        , Svg.feGaussianBlur
            [ Svg.Attributes.stdDeviation "2"
            , Svg.Attributes.in_ "LIGHT-EFFECTS_20"
            , Svg.Attributes.result "LIGHT-EFFECTS_30"
            ]
            []
        , Svg.feSpecularLighting
            [ Svg.Attributes.surfaceScale "5"
            , Svg.Attributes.specularConstant ".75"
            , Svg.Attributes.specularExponent "30"
            , Svg.Attributes.lightingColor "#white"
            , Svg.Attributes.in_ "LIGHT-EFFECTS_30"
            , Svg.Attributes.result "LIGHT-EFFECTS_40"
            ]
            [ Svg.fePointLight
                [ Svg.Attributes.x "-50"
                , Svg.Attributes.y "-100"
                , Svg.Attributes.z "400"
                ]
                []
            ]
        , Svg.feComposite
            [ Svg.Attributes.operator "in"
            , Svg.Attributes.in_ "LIGHT-EFFECTS_40"
            , Svg.Attributes.in2 "LIGHT-EFFECTS_20"
            , Svg.Attributes.result "LIGHT-EFFECTS_50"
            ]
            []
        , Svg.feComposite
            [ Svg.Attributes.operator "arithmetic"
            , Svg.Attributes.k1 "0"
            , Svg.Attributes.k2 "1"
            , Svg.Attributes.k3 "1"
            , Svg.Attributes.k4 "0"
            , Svg.Attributes.in_ "LIGHT-EFFECTS_10"
            , Svg.Attributes.in2 "LIGHT-EFFECTS_50"
            , Svg.Attributes.result "LIGHT-EFFECTS_60"
            ]
            []
        ]
