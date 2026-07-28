module KeyframesDefsElmSvg exposing (main)

{-| Animating between different defs — elm/svg version, hand-written SMIL.
Mirrors KeyframesDefsEvg: gradient stops, filter blur, patterns, and a clip
path all animate. Where evg regenerates defs from keyframes, raw SMIL has to
animate the defs' internals directly (or crossfade, for patterns).
-}

import Html exposing (Html)
import Svg exposing (Svg)
import Svg.Attributes


main : Html msg
main =
    Svg.svg
        [ Svg.Attributes.viewBox "0 0 500 300"
        , Svg.Attributes.width "500"
        , Svg.Attributes.height "300"
        ]
        [ Svg.defs []
            [ -- Animated gradient (sunset <-> ocean)
              Svg.linearGradient
                [ Svg.Attributes.id "kfd-gradient"
                , Svg.Attributes.x1 "0"
                , Svg.Attributes.y1 "0"
                , Svg.Attributes.x2 "0"
                , Svg.Attributes.y2 "1"
                ]
                [ Svg.stop [ Svg.Attributes.offset "0", Svg.Attributes.stopColor "rgb(255,100,0)" ]
                    [ Svg.animate
                        [ Svg.Attributes.attributeName "stop-color"
                        , Svg.Attributes.values "rgb(255,100,0);rgb(0,100,200);rgb(255,100,0)"
                        , Svg.Attributes.keyTimes "0;0.5;1"
                        , Svg.Attributes.calcMode "spline"
                        , Svg.Attributes.keySplines ".5 0 .5 1;.5 0 .5 1"
                        , Svg.Attributes.dur "4s"
                        , Svg.Attributes.repeatCount "indefinite"
                        ]
                        []
                    ]
                , Svg.stop [ Svg.Attributes.offset "0.01", Svg.Attributes.stopColor "rgb(255,100,0)" ]
                    [ Svg.animate
                        [ Svg.Attributes.attributeName "stop-color"
                        , Svg.Attributes.values "rgb(255,100,0);rgb(200,100,100);rgb(255,100,0)"
                        , Svg.Attributes.keyTimes "0;0.5;1"
                        , Svg.Attributes.calcMode "spline"
                        , Svg.Attributes.keySplines ".5 0 .5 1;.5 0 .5 1"
                        , Svg.Attributes.dur "4s"
                        , Svg.Attributes.repeatCount "indefinite"
                        ]
                        []
                    , Svg.animate
                        [ Svg.Attributes.attributeName "offset"
                        , Svg.Attributes.values "0.01;0.5;0.01"
                        , Svg.Attributes.keyTimes "0;0.5;1"
                        , Svg.Attributes.calcMode "spline"
                        , Svg.Attributes.keySplines ".5 0 .5 1;.5 0 .5 1"
                        , Svg.Attributes.dur "4s"
                        , Svg.Attributes.repeatCount "indefinite"
                        ]
                        []
                    ]
                , Svg.stop [ Svg.Attributes.offset "1", Svg.Attributes.stopColor "rgb(255,200,50)" ]
                    [ Svg.animate
                        [ Svg.Attributes.attributeName "stop-color"
                        , Svg.Attributes.values "rgb(255,200,50);rgb(0,200,150);rgb(255,200,50)"
                        , Svg.Attributes.keyTimes "0;0.5;1"
                        , Svg.Attributes.calcMode "spline"
                        , Svg.Attributes.keySplines ".5 0 .5 1;.5 0 .5 1"
                        , Svg.Attributes.dur "4s"
                        , Svg.Attributes.repeatCount "indefinite"
                        ]
                        []
                    ]
                ]

            -- Animated blur filter
            , Svg.filter
                [ Svg.Attributes.id "kfd-blur"
                , Svg.Attributes.colorInterpolationFilters "sRGB"
                ]
                [ Svg.feGaussianBlur
                    [ Svg.Attributes.in_ "SourceGraphic", Svg.Attributes.stdDeviation "0" ]
                    [ Svg.animate
                        [ Svg.Attributes.attributeName "stdDeviation"
                        , Svg.Attributes.values "0;5;0"
                        , Svg.Attributes.keyTimes "0;0.5;1"
                        , Svg.Attributes.calcMode "spline"
                        , Svg.Attributes.keySplines ".5 0 .5 1;.5 0 .5 1"
                        , Svg.Attributes.dur "4s"
                        , Svg.Attributes.repeatCount "indefinite"
                        ]
                        []
                    ]
                ]

            -- Two static patterns (crossfaded in the scene below)
            , Svg.pattern
                [ Svg.Attributes.id "kfd-checkers"
                , Svg.Attributes.width "0.25"
                , Svg.Attributes.height "0.25"
                , Svg.Attributes.patternContentUnits "objectBoundingBox"
                ]
                [ Svg.rect [ Svg.Attributes.width "0.25", Svg.Attributes.height "0.25", Svg.Attributes.fill "white" ] []
                , Svg.rect [ Svg.Attributes.width "0.125", Svg.Attributes.height "0.125", Svg.Attributes.fill "royalblue" ] []
                , Svg.rect [ Svg.Attributes.x "0.125", Svg.Attributes.y "0.125", Svg.Attributes.width "0.125", Svg.Attributes.height "0.125", Svg.Attributes.fill "royalblue" ] []
                ]
            , Svg.pattern
                [ Svg.Attributes.id "kfd-stripes"
                , Svg.Attributes.width "0.1"
                , Svg.Attributes.height "1"
                , Svg.Attributes.patternContentUnits "objectBoundingBox"
                ]
                [ Svg.rect [ Svg.Attributes.width "0.1", Svg.Attributes.height "1", Svg.Attributes.fill "white" ] []
                , Svg.rect [ Svg.Attributes.width "0.05", Svg.Attributes.height "1", Svg.Attributes.fill "coral" ] []
                ]

            -- Animated clip path
            , Svg.clipPath [ Svg.Attributes.id "kfd-clip" ]
                [ Svg.circle
                    [ Svg.Attributes.cx "410", Svg.Attributes.cy "50", Svg.Attributes.r "10" ]
                    [ Svg.animate
                        [ Svg.Attributes.attributeName "r"
                        , Svg.Attributes.values "10;40;10"
                        , Svg.Attributes.keyTimes "0;0.5;1"
                        , Svg.Attributes.calcMode "spline"
                        , Svg.Attributes.keySplines ".5 0 .5 1;.5 0 .5 1"
                        , Svg.Attributes.dur "4s"
                        , Svg.Attributes.repeatCount "indefinite"
                        ]
                        []
                    ]
                ]
            ]

        -- Gradient animation
        , Svg.rect
            [ Svg.Attributes.x "10"
            , Svg.Attributes.y "10"
            , Svg.Attributes.width "100"
            , Svg.Attributes.height "100"
            , Svg.Attributes.fill "url(#kfd-gradient)"
            ]
            []

        -- Filter animation
        , Svg.circle
            [ Svg.Attributes.cx "190"
            , Svg.Attributes.cy "60"
            , Svg.Attributes.r "45"
            , Svg.Attributes.fill "tomato"
            , Svg.Attributes.filter "url(#kfd-blur)"
            ]
            []

        -- Pattern animation (crossfade between two pattern fills)
        , Svg.rect
            [ Svg.Attributes.x "260"
            , Svg.Attributes.y "10"
            , Svg.Attributes.width "100"
            , Svg.Attributes.height "100"
            , Svg.Attributes.fill "url(#kfd-checkers)"
            ]
            []
        , Svg.rect
            [ Svg.Attributes.x "260"
            , Svg.Attributes.y "10"
            , Svg.Attributes.width "100"
            , Svg.Attributes.height "100"
            , Svg.Attributes.fill "url(#kfd-stripes)"
            , Svg.Attributes.opacity "0"
            ]
            [ Svg.animate
                [ Svg.Attributes.attributeName "opacity"
                , Svg.Attributes.values "0;1;0"
                , Svg.Attributes.keyTimes "0;0.5;1"
                , Svg.Attributes.calcMode "spline"
                , Svg.Attributes.keySplines ".5 0 .5 1;.5 0 .5 1"
                , Svg.Attributes.dur "4s"
                , Svg.Attributes.repeatCount "indefinite"
                ]
                []
            ]

        -- Clip animation
        , Svg.rect
            [ Svg.Attributes.x "380"
            , Svg.Attributes.y "10"
            , Svg.Attributes.width "100"
            , Svg.Attributes.height "100"
            , Svg.Attributes.fill "mediumseagreen"
            , Svg.Attributes.clipPath "url(#kfd-clip)"
            ]
            []
        ]
