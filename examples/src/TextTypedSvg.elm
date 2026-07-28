module TextTypedSvg exposing (main)

{-| Text examples — typed-svg version.
Shows rich text, text on path, weight/style, and spacing.
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
        [ TypedSvg.Attributes.viewBox 0 0 300 260
        , TypedSvg.Attributes.width (TypedSvg.Types.px 300)
        , TypedSvg.Attributes.height (TypedSvg.Types.px 300)
        ]
        [ -- Basic text
          TypedSvg.text_
            [ TypedSvg.Attributes.x (TypedSvg.Types.px 10)
            , TypedSvg.Attributes.y (TypedSvg.Types.px 25)
            , TypedSvg.Attributes.fill (TypedSvg.Types.Paint Color.black)
            , TypedSvg.Attributes.fontSize (TypedSvg.Types.px 18)
            ]
            [ TypedSvg.Core.text "Hello, SVG text!" ]

        -- Rich text with mixed styles
        , TypedSvg.text_
            [ TypedSvg.Attributes.x (TypedSvg.Types.px 10)
            , TypedSvg.Attributes.y (TypedSvg.Types.px 55)
            , TypedSvg.Attributes.fontSize (TypedSvg.Types.px 14)
            ]
            [ TypedSvg.tspan [ TypedSvg.Attributes.fill (TypedSvg.Types.Paint Color.black) ] [ TypedSvg.Core.text "Normal " ]
            , TypedSvg.tspan [ TypedSvg.Attributes.fill (TypedSvg.Types.Paint (Color.rgb255 220 20 60)), TypedSvg.Attributes.fontWeight TypedSvg.Types.FontWeightBold ] [ TypedSvg.Core.text "bold red " ]
            , TypedSvg.tspan [ TypedSvg.Attributes.fill (TypedSvg.Types.Paint (Color.rgb255 0 0 128)), TypedSvg.Attributes.fontStyle TypedSvg.Types.FontStyleItalic ] [ TypedSvg.Core.text "italic blue" ]
            ]

        -- Text on a path
        , TypedSvg.defs []
            [ TypedSvg.path
                [ TypedSvg.Attributes.id "curvePath"
                , TypedSvg.Attributes.d "M20,100 C80,50 180,150 280,90"
                ]
                []
            ]
        , TypedSvg.text_
            [ TypedSvg.Attributes.fill (TypedSvg.Types.Paint (Color.rgb255 0 100 0))
            , TypedSvg.Attributes.fontSize (TypedSvg.Types.px 13)
            ]
            [ TypedSvg.textPath
                [ TypedSvg.Attributes.xlinkHref "#curvePath" ]
                [ TypedSvg.Core.text "Text flowing along a curve" ]
            ]

        -- Letter spacing
        , TypedSvg.text_
            [ TypedSvg.Attributes.x (TypedSvg.Types.px 10)
            , TypedSvg.Attributes.y (TypedSvg.Types.px 170)
            , TypedSvg.Attributes.fill (TypedSvg.Types.Paint (Color.rgb255 85 85 85))
            , TypedSvg.Attributes.fontSize (TypedSvg.Types.px 14)
            , TypedSvg.Attributes.letterSpacing "4"
            ]
            [ TypedSvg.Core.text "S P A C E D" ]

        -- Text decoration
        , TypedSvg.text_
            [ TypedSvg.Attributes.x (TypedSvg.Types.px 10)
            , TypedSvg.Attributes.y (TypedSvg.Types.px 195)
            , TypedSvg.Attributes.fill (TypedSvg.Types.Paint Color.black)
            , TypedSvg.Attributes.fontSize (TypedSvg.Types.px 14)
            , TypedSvg.Attributes.textDecoration "underline"
            ]
            [ TypedSvg.Core.text "Underlined text" ]

        -- Vertical writing
        , TypedSvg.text_
            [ TypedSvg.Attributes.x (TypedSvg.Types.px 280)
            , TypedSvg.Attributes.y (TypedSvg.Types.px 150)
            , TypedSvg.Attributes.fill (TypedSvg.Types.Paint (Color.rgb255 128 0 128))
            , TypedSvg.Attributes.fontSize (TypedSvg.Types.px 14)
            , TypedSvg.Attributes.writingMode "vertical-rl"
            ]
            [ TypedSvg.Core.text "縦書き" ]

        -- TextLength — stretch to fit
        , TypedSvg.text_
            [ TypedSvg.Attributes.x (TypedSvg.Types.px 10)
            , TypedSvg.Attributes.y (TypedSvg.Types.px 225)
            , TypedSvg.Attributes.fill (TypedSvg.Types.Paint Color.black)
            , TypedSvg.Attributes.fontSize (TypedSvg.Types.px 14)
            , TypedSvg.Attributes.textLength (TypedSvg.Types.px 200)
            , TypedSvg.Attributes.lengthAdjust TypedSvg.Types.LengthAdjustSpacingAndGlyphs
            ]
            [ TypedSvg.Core.text "Stretched to 200px" ]

        -- Baseline
        , TypedSvg.text_
            [ TypedSvg.Attributes.x (TypedSvg.Types.px 10)
            , TypedSvg.Attributes.y (TypedSvg.Types.px 245)
            , TypedSvg.Attributes.fill (TypedSvg.Types.Paint Color.gray)
            , TypedSvg.Attributes.fontSize (TypedSvg.Types.px 10)
            , TypedSvg.Attributes.dominantBaseline TypedSvg.Types.DominantBaselineHanging
            ]
            [ TypedSvg.Core.text "hanging baseline" ]
        ]
