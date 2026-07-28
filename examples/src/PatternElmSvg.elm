module PatternElmSvg exposing (main)

{-| Pattern fill examples — elm/svg version.
Shows checkerboard, diagonal stripes, and polka dots.
-}

import Html exposing (Html)
import Svg exposing (Svg)
import Svg.Attributes


main : Html msg
main =
    Svg.svg
        [ Svg.Attributes.viewBox "0 0 360 120"
        , Svg.Attributes.width "360"
        , Svg.Attributes.height "120"
        ]
        [ Svg.defs []
            [ checkerboardPattern
            , stripesPattern
            , dotsPattern
            ]
        , Svg.rect
            [ Svg.Attributes.x "10"
            , Svg.Attributes.y "10"
            , Svg.Attributes.width "100"
            , Svg.Attributes.height "100"
            , Svg.Attributes.fill "url(#checkerboard)"
            ]
            []
        , Svg.rect
            [ Svg.Attributes.x "130"
            , Svg.Attributes.y "10"
            , Svg.Attributes.width "100"
            , Svg.Attributes.height "100"
            , Svg.Attributes.fill "none"
            , Svg.Attributes.stroke "url(#stripes)"
            , Svg.Attributes.strokeWidth "10"
            ]
            []
        , Svg.rect
            [ Svg.Attributes.x "250"
            , Svg.Attributes.y "10"
            , Svg.Attributes.width "100"
            , Svg.Attributes.height "100"
            , Svg.Attributes.fill "url(#dots)"
            , Svg.Attributes.stroke "#333"
            , Svg.Attributes.strokeWidth "1"
            ]
            []
        ]


checkerboardPattern : Svg msg
checkerboardPattern =
    Svg.pattern
        [ Svg.Attributes.id "checkerboard"
        , Svg.Attributes.width "0.2"
        , Svg.Attributes.height "0.2"
        , Svg.Attributes.patternContentUnits "objectBoundingBox"
        ]
        [ Svg.rect
            [ Svg.Attributes.width "0.2"
            , Svg.Attributes.height "0.2"
            , Svg.Attributes.fill "#eee"
            ]
            []
        , Svg.rect
            [ Svg.Attributes.width "0.1"
            , Svg.Attributes.height "0.1"
            , Svg.Attributes.fill "#333"
            ]
            []
        , Svg.rect
            [ Svg.Attributes.x "0.1"
            , Svg.Attributes.y "0.1"
            , Svg.Attributes.width "0.1"
            , Svg.Attributes.height "0.1"
            , Svg.Attributes.fill "#333"
            ]
            []
        ]


stripesPattern : Svg msg
stripesPattern =
    Svg.pattern
        [ Svg.Attributes.id "stripes"
        , Svg.Attributes.width "0.1"
        , Svg.Attributes.height "0.1"
        , Svg.Attributes.patternContentUnits "objectBoundingBox"
        , Svg.Attributes.patternTransform "rotate(45)"
        ]
        [ Svg.rect
            [ Svg.Attributes.width "0.1"
            , Svg.Attributes.height "0.1"
            , Svg.Attributes.fill "white"
            ]
            []
        , Svg.rect
            [ Svg.Attributes.width "0.05"
            , Svg.Attributes.height "0.1"
            , Svg.Attributes.x "0.05"
            , Svg.Attributes.fill "rgb(70,130,180)"
            ]
            []
           
        ]



dotsPattern : Svg msg
dotsPattern =
    Svg.pattern
        [ Svg.Attributes.id "dots"
        , Svg.Attributes.width "10%"
        , Svg.Attributes.height "10%"
        , Svg.Attributes.viewBox "0 0 10 10"
        ]
        [ Svg.rect
            [ Svg.Attributes.width "10"
            , Svg.Attributes.height "10"
            , Svg.Attributes.fill "hotpink"
            ]
            []
        , Svg.circle
            [ Svg.Attributes.r "3"
            , Svg.Attributes.cx "5"
            , Svg.Attributes.cy "5"
            , Svg.Attributes.fill "rgb(220,60,60)"
            ]
            []
        ]
