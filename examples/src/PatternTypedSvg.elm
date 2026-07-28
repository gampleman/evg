module PatternTypedSvg exposing (main)

{-| Pattern fill examples — typed-svg version.
Shows checkerboard, diagonal stripes, and polka dots.
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
        [ TypedSvg.Attributes.viewBox 0 0 360 120
        , TypedSvg.Attributes.width (TypedSvg.Types.px 360)
        , TypedSvg.Attributes.height (TypedSvg.Types.px 120)
        ]
        [ TypedSvg.defs []
            [ checkerboardPattern
            , stripesPattern
            , dotsPattern
            ]
        , TypedSvg.rect
            [ TypedSvg.Attributes.x (TypedSvg.Types.px 10)
            , TypedSvg.Attributes.y (TypedSvg.Types.px 10)
            , TypedSvg.Attributes.width (TypedSvg.Types.px 100)
            , TypedSvg.Attributes.height (TypedSvg.Types.px 100)
            , TypedSvg.Attributes.fill (TypedSvg.Types.Reference "checkerboard")
            ]
            []
        , TypedSvg.rect
            [ TypedSvg.Attributes.x (TypedSvg.Types.px 130)
            , TypedSvg.Attributes.y (TypedSvg.Types.px 10)
            , TypedSvg.Attributes.width (TypedSvg.Types.px 100)
            , TypedSvg.Attributes.height (TypedSvg.Types.px 100)
            , TypedSvg.Attributes.fill TypedSvg.Types.PaintNone
            , TypedSvg.Attributes.stroke (TypedSvg.Types.Reference "stripes")
            , TypedSvg.Attributes.strokeWidth (TypedSvg.Types.px 10)
            ]
            []
        , TypedSvg.rect
            [ TypedSvg.Attributes.x (TypedSvg.Types.px 250)
            , TypedSvg.Attributes.y (TypedSvg.Types.px 10)
            , TypedSvg.Attributes.width (TypedSvg.Types.px 100)
            , TypedSvg.Attributes.height (TypedSvg.Types.px 100)
            , TypedSvg.Attributes.fill (TypedSvg.Types.Reference "dots")
            , TypedSvg.Attributes.stroke (TypedSvg.Types.Paint (Color.rgb255 51 51 51))
            , TypedSvg.Attributes.strokeWidth (TypedSvg.Types.px 1)
            ]
            []
        ]


checkerboardPattern : TypedSvg.Core.Svg msg
checkerboardPattern =
    TypedSvg.pattern
        [ TypedSvg.Attributes.id "checkerboard"
        , TypedSvg.Core.attribute "width" "0.2"
        , TypedSvg.Core.attribute "height" "0.2"
        , TypedSvg.Attributes.patternContentUnits TypedSvg.Types.CoordinateSystemObjectBoundingBox
        ]
        [ TypedSvg.rect
            [ TypedSvg.Core.attribute "width" "0.2"
            , TypedSvg.Core.attribute "height" "0.2"
            , TypedSvg.Attributes.fill (TypedSvg.Types.Paint (Color.rgb255 238 238 238))
            ]
            []
        , TypedSvg.rect
            [ TypedSvg.Core.attribute "width" "0.1"
            , TypedSvg.Core.attribute "height" "0.1"
            , TypedSvg.Attributes.fill (TypedSvg.Types.Paint (Color.rgb255 51 51 51))
            ]
            []
        , TypedSvg.rect
            [ TypedSvg.Core.attribute "x" "0.1"
            , TypedSvg.Core.attribute "y" "0.1"
            , TypedSvg.Core.attribute "width" "0.1"
            , TypedSvg.Core.attribute "height" "0.1"
            , TypedSvg.Attributes.fill (TypedSvg.Types.Paint (Color.rgb255 51 51 51))
            ]
            []
        ]


stripesPattern : TypedSvg.Core.Svg msg
stripesPattern =
    TypedSvg.pattern
        [ TypedSvg.Attributes.id "stripes"
        , TypedSvg.Core.attribute "width" "0.1"
        , TypedSvg.Core.attribute "height" "0.1"
        , TypedSvg.Attributes.patternContentUnits TypedSvg.Types.CoordinateSystemObjectBoundingBox
        , TypedSvg.Core.attribute "patternTransform" "rotate(45)"
        ]
        [ TypedSvg.rect
            [ TypedSvg.Core.attribute "width" "0.1"
            , TypedSvg.Core.attribute "height" "0.1"
            , TypedSvg.Attributes.fill (TypedSvg.Types.Paint Color.white)
            ]
            []
        , TypedSvg.rect
            [ TypedSvg.Core.attribute "width" "0.05"
            , TypedSvg.Core.attribute "height" "0.1"
            , TypedSvg.Core.attribute "x" "0.05"
            , TypedSvg.Attributes.fill (TypedSvg.Types.Paint (Color.rgb255 70 130 180))
            ]
            []
        ]


dotsPattern : TypedSvg.Core.Svg msg
dotsPattern =
    TypedSvg.pattern
        [ TypedSvg.Attributes.id "dots"
        , TypedSvg.Core.attribute "width" "10%"
        , TypedSvg.Core.attribute "height" "10%"
        , TypedSvg.Attributes.viewBox 0 0 10 10
        ]
        [ TypedSvg.rect
            [ TypedSvg.Attributes.width (TypedSvg.Types.px 10)
            , TypedSvg.Attributes.height (TypedSvg.Types.px 10)
            , TypedSvg.Attributes.fill (TypedSvg.Types.Paint (Color.rgb255 255 105 180))
            ]
            []
        , TypedSvg.circle
            [ TypedSvg.Attributes.r (TypedSvg.Types.px 3)
            , TypedSvg.Attributes.cx (TypedSvg.Types.px 5)
            , TypedSvg.Attributes.cy (TypedSvg.Types.px 5)
            , TypedSvg.Attributes.fill (TypedSvg.Types.Paint (Color.rgb255 220 60 60))
            ]
            []
        ]
