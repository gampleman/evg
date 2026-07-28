module TextEvg exposing (main)

{-| Text examples — evg version.
Shows rich text, text on path, weight/style, and spacing.
-}

import Evg exposing (Evg)
import Evg.Path exposing (Path(..), PathSegment(..))
import Evg.Text as Text
import Html exposing (Html)


main : Html msg
main =
    Evg.svg [] { width = 300, height = 260 }
        [ -- Basic text
          Evg.text [ Evg.fillStr "black", Evg.fontSize 18 ]
            { x = 10, y = 25, anchor = Evg.Start }
            "Hello, SVG text!"

        -- Rich text with mixed styles
        , Text.richText [ Evg.fontSize 14 ]
            { x = 10, y = 55, anchor = Evg.Start }
            [ Text.tspan [ Evg.fillStr "black" ] "Normal "
            , Text.tspan [ Evg.fillStr "crimson", Text.fontWeight Text.Bold ] "bold red "
            , Text.tspan [ Evg.fillStr "navy", Text.fontStyle Text.Italic ] "italic blue"
            ]

        -- Text on a path
        , Evg.text
            [ Evg.fillStr "darkgreen"
            , Evg.fontSize 13
            , Text.onPath [ M ( 20, 100 ) [ C ( 80, 50 ) ( 180, 150 ) ( 280, 90 ) ] ]
            ]
            { x = 0, y = 0, anchor = Evg.Start }
            "Text flowing along a curve"

        -- Letter spacing
        , Evg.text [ Evg.fillStr "#555", Evg.fontSize 14, Text.letterSpacing 4 ]
            { x = 10, y = 170, anchor = Evg.Start }
            "S P A C E D"

        -- Text decoration
        , Evg.text [ Evg.fillStr "black", Evg.fontSize 14, Text.textDecoration Text.Underline ]
            { x = 10, y = 195, anchor = Evg.Start }
            "Underlined text"

        -- Vertical writing
        , Evg.text [ Evg.fillStr "purple", Evg.fontSize 14, Text.writingMode Text.VerticalRL ]
            { x = 280, y = 150, anchor = Evg.Start }
            "縦書き"

        -- TextLength — stretch to fit
        , Evg.text [ Evg.fillStr "black", Evg.fontSize 14, Text.textLength 200 Text.SpacingAndGlyphs ]
            { x = 10, y = 225, anchor = Evg.Start }
            "Stretched to 200px"

        -- Baseline
        , Evg.text [ Evg.fillStr "gray", Evg.fontSize 10, Text.dominantBaseline Text.Hanging ]
            { x = 10, y = 245, anchor = Evg.Start }
            "hanging baseline"
        ]
