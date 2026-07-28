module TextElmSvg exposing (main)

{-| Text examples — elm/svg version.
Shows rich text, text on path, weight/style, and spacing.
-}

import Html exposing (Html)
import Svg exposing (Svg)
import Svg.Attributes


main : Html msg
main =
    Svg.svg
        [ Svg.Attributes.viewBox "0 0 300 260"
        , Svg.Attributes.width "300"
        , Svg.Attributes.height "260"
        ]
        [ -- Basic text
          Svg.text_
            [ Svg.Attributes.x "10"
            , Svg.Attributes.y "25"
            , Svg.Attributes.fill "black"
            , Svg.Attributes.fontSize "18"
            ]
            [ Svg.text "Hello, SVG text!" ]

        -- Rich text with mixed styles
        , Svg.text_
            [ Svg.Attributes.x "10"
            , Svg.Attributes.y "55"
            , Svg.Attributes.fontSize "14"
            ]
            [ Svg.tspan [ Svg.Attributes.fill "black" ] [ Svg.text "Normal " ]
            , Svg.tspan [ Svg.Attributes.fill "crimson", Svg.Attributes.fontWeight "bold" ] [ Svg.text "bold red " ]
            , Svg.tspan [ Svg.Attributes.fill "navy", Svg.Attributes.fontStyle "italic" ] [ Svg.text "italic blue" ]
            ]

        -- Text on a path
        , Svg.defs []
            [ Svg.path
                [ Svg.Attributes.id "curvePath"
                , Svg.Attributes.d "M20,100 C80,50 180,150 280,90"
                ]
                []
            ]
        , Svg.text_
            [ Svg.Attributes.fill "darkgreen"
            , Svg.Attributes.fontSize "13"
            ]
            [ Svg.textPath
                [ Svg.Attributes.xlinkHref "#curvePath" ]
                [ Svg.text "Text flowing along a curve" ]
            ]

        -- Letter spacing
        , Svg.text_
            [ Svg.Attributes.x "10"
            , Svg.Attributes.y "170"
            , Svg.Attributes.fill "#555"
            , Svg.Attributes.fontSize "14"
            , Svg.Attributes.letterSpacing "4"
            ]
            [ Svg.text "S P A C E D" ]

        -- Text decoration
        , Svg.text_
            [ Svg.Attributes.x "10"
            , Svg.Attributes.y "195"
            , Svg.Attributes.fill "black"
            , Svg.Attributes.fontSize "14"
            , Svg.Attributes.textDecoration "underline"
            ]
            [ Svg.text "Underlined text" ]

        -- Vertical writing
        , Svg.text_
            [ Svg.Attributes.x "280"
            , Svg.Attributes.y "150"
            , Svg.Attributes.fill "purple"
            , Svg.Attributes.fontSize "14"
            , Svg.Attributes.writingMode "vertical-rl"
            ]
            [ Svg.text "縦書き" ]

        -- TextLength — stretch to fit
        , Svg.text_
            [ Svg.Attributes.x "10"
            , Svg.Attributes.y "225"
            , Svg.Attributes.fill "black"
            , Svg.Attributes.fontSize "14"
            , Svg.Attributes.textLength "200"
            , Svg.Attributes.lengthAdjust "spacingAndGlyphs"
            ]
            [ Svg.text "Stretched to 200px" ]

        -- Baseline
        , Svg.text_
            [ Svg.Attributes.x "10"
            , Svg.Attributes.y "245"
            , Svg.Attributes.fill "gray"
            , Svg.Attributes.fontSize "10"
            , Svg.Attributes.dominantBaseline "hanging"
            ]
            [ Svg.text "hanging baseline" ]
        ]
