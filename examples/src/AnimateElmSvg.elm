module AnimateElmSvg exposing (main)

{-| Pulse rect animation from the README — elm/svg version.
-}

import Html exposing (Html)
import Svg exposing (Svg)
import Svg.Attributes


main : Html msg
main =
    Svg.svg
        [ Svg.Attributes.viewBox "0 0 120 120"
        , Svg.Attributes.width "120"
        , Svg.Attributes.height "120"
        ]
        [ Svg.rect
            [ Svg.Attributes.rx "30"
            , Svg.Attributes.fill "navy"
            , Svg.Attributes.x "10"
            , Svg.Attributes.y "10"
            , Svg.Attributes.width "100"
            , Svg.Attributes.height "100"
            ]
            [ Svg.animate
                [ Svg.Attributes.attributeName "rx"
                , Svg.Attributes.values "30; 50; 20; 30"
                , Svg.Attributes.begin "0s"
                , Svg.Attributes.dur "3s"
                , Svg.Attributes.keyTimes "0; 0.2; 0.6; 1"
                , Svg.Attributes.calcMode "spline"
                , Svg.Attributes.repeatCount "indefinite"
                , Svg.Attributes.keySplines "0 0 1 1; .5 0 .5 1; 0 0 1 1"
                ]
                []
            ]
        ]
