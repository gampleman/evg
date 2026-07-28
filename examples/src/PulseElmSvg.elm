module PulseElmSvg exposing (main)

{-| An animated pulsing shape demonstrating SMIL animation.
Implemented with elm/svg.
-}

import Html exposing (Html)
import Svg exposing (Svg)
import Svg.Attributes


main : Html msg
main =
    Svg.svg
        [ Svg.Attributes.viewBox "0 0 200 200"
        , Svg.Attributes.width "200"
        , Svg.Attributes.height "200"
        ]
        [ Svg.circle
            [ Svg.Attributes.cx "100"
            , Svg.Attributes.cy "100"
            , Svg.Attributes.r "30"
            , Svg.Attributes.fill "tomato"
            ]
            [ Svg.animate
                [ Svg.Attributes.attributeName "r"
                , Svg.Attributes.values "30;60;30"
                , Svg.Attributes.dur "2s"
                , Svg.Attributes.keyTimes "0;0.5;1"
                , Svg.Attributes.calcMode "spline"
                , Svg.Attributes.keySplines ".5 0 .5 1;.5 0 .5 1"
                , Svg.Attributes.repeatCount "indefinite"
                ]
                []
            , Svg.animate
                [ Svg.Attributes.attributeName "opacity"
                , Svg.Attributes.values "1;0.5;1"
                , Svg.Attributes.dur "2s"
                , Svg.Attributes.keyTimes "0;0.5;1"
                , Svg.Attributes.calcMode "spline"
                , Svg.Attributes.keySplines ".5 0 .5 1;.5 0 .5 1"
                , Svg.Attributes.repeatCount "indefinite"
                ]
                []
            ]
        ]
