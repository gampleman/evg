module BadgeTypedSvg exposing (main)

{-| A notification badge icon with a drop shadow filter.
Implemented with elm-community/typed-svg.
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
        [ TypedSvg.Attributes.viewBox 0 0 100 100
        , TypedSvg.Attributes.width (TypedSvg.Types.px 200)
        , TypedSvg.Attributes.height (TypedSvg.Types.px 200)
        ]
        [ TypedSvg.defs []
            [ TypedSvg.filter [ TypedSvg.Attributes.id "drop-shadow" ]
                [ TypedSvg.Filters.gaussianBlur
                    [ TypedSvg.Filters.Attributes.in_ TypedSvg.Types.InSourceAlpha
                    , TypedSvg.Core.attribute "stdDeviation" "2"
                    , TypedSvg.Filters.Attributes.result "blur"
                    ]
                    []
                , TypedSvg.Filters.offset
                    [ TypedSvg.Filters.Attributes.in_ (TypedSvg.Types.InReference "blur")
                    , TypedSvg.Core.attribute "dx" "1.5"
                    , TypedSvg.Core.attribute "dy" "2"
                    , TypedSvg.Filters.Attributes.result "offset"
                    ]
                    []
                , TypedSvg.Filters.composite
                    [ TypedSvg.Filters.Attributes.compositeOperator TypedSvg.Types.CompositeOperatorOver
                    , TypedSvg.Filters.Attributes.in_ TypedSvg.Types.InSourceGraphic
                    , TypedSvg.Filters.Attributes.in2 (TypedSvg.Types.InReference "offset")
                    ]
                    []
                ]
            ]
        , -- Bell body
          TypedSvg.path
            [ TypedSvg.Attributes.d "M 50 20 C 35 20 25 32 25 45 L 25 60 L 20 65 L 80 65 L 75 60 L 75 45 C 75 32 65 20 50 20"
            , TypedSvg.Attributes.fill (TypedSvg.Types.Paint (Color.rgb255 255 193 7))
            , TypedSvg.Attributes.filter (TypedSvg.Types.Filter "url(#drop-shadow)")
            ]
            []

        -- Bell clapper
        , TypedSvg.circle
            [ TypedSvg.Attributes.cx (TypedSvg.Types.px 50)
            , TypedSvg.Attributes.cy (TypedSvg.Types.px 72)
            , TypedSvg.Attributes.r (TypedSvg.Types.px 5)
            , TypedSvg.Attributes.fill (TypedSvg.Types.Paint (Color.rgb255 255 143 0))
            ]
            []

        -- Bell top
        , TypedSvg.circle
            [ TypedSvg.Attributes.cx (TypedSvg.Types.px 50)
            , TypedSvg.Attributes.cy (TypedSvg.Types.px 18)
            , TypedSvg.Attributes.r (TypedSvg.Types.px 3)
            , TypedSvg.Attributes.fill (TypedSvg.Types.Paint (Color.rgb255 255 193 7))
            ]
            []

        -- Notification dot
        , TypedSvg.circle
            [ TypedSvg.Attributes.cx (TypedSvg.Types.px 68)
            , TypedSvg.Attributes.cy (TypedSvg.Types.px 28)
            , TypedSvg.Attributes.r (TypedSvg.Types.px 10)
            , TypedSvg.Attributes.fill (TypedSvg.Types.Paint (Color.rgb255 244 67 54))
            , TypedSvg.Attributes.stroke (TypedSvg.Types.Paint Color.white)
            , TypedSvg.Attributes.strokeWidth (TypedSvg.Types.px 2)
            ]
            []

        -- Number in dot
        , TypedSvg.text_
            [ TypedSvg.Attributes.x (TypedSvg.Types.px 68)
            , TypedSvg.Attributes.y (TypedSvg.Types.px 32)
            , TypedSvg.Attributes.textAnchor TypedSvg.Types.AnchorMiddle
            , TypedSvg.Attributes.fontSize (TypedSvg.Types.px 11)
            , TypedSvg.Attributes.fill (TypedSvg.Types.Paint Color.white)
            , TypedSvg.Attributes.fontWeight TypedSvg.Types.FontWeightBold
            ]
            [ TypedSvg.Core.text "3" ]
        ]
