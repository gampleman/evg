module BadgeElmSvg exposing (main)

{-| A notification badge icon with a drop shadow filter.
Implemented with elm/svg.
-}

import Html exposing (Html)
import Svg exposing (Svg)
import Svg.Attributes


main : Html msg
main =
    Svg.svg
        [ Svg.Attributes.viewBox "0 0 100 100"
        , Svg.Attributes.width "200"
        , Svg.Attributes.height "200"
        ]
        [ Svg.defs []
            [ Svg.filter [ Svg.Attributes.id "drop-shadow" ]
                [ Svg.feGaussianBlur
                    [ Svg.Attributes.in_ "SourceAlpha"
                    , Svg.Attributes.stdDeviation "2"
                    , Svg.Attributes.result "blur"
                    ]
                    []
                , Svg.feOffset
                    [ Svg.Attributes.in_ "blur"
                    , Svg.Attributes.dx "1.5"
                    , Svg.Attributes.dy "2"
                    , Svg.Attributes.result "offset"
                    ]
                    []
                , Svg.feComposite
                    [ Svg.Attributes.operator "over"
                    , Svg.Attributes.in_ "SourceGraphic"
                    , Svg.Attributes.in2 "offset"
                    ]
                    []
                ]
            ]
        , -- Bell body
          Svg.path
            [ Svg.Attributes.d "M 50 20 C 35 20 25 32 25 45 L 25 60 L 20 65 L 80 65 L 75 60 L 75 45 C 75 32 65 20 50 20"
            , Svg.Attributes.fill "#ffc107"
            , Svg.Attributes.filter "url(#drop-shadow)"
            ]
            []

        -- Bell clapper
        , Svg.circle
            [ Svg.Attributes.cx "50"
            , Svg.Attributes.cy "72"
            , Svg.Attributes.r "5"
            , Svg.Attributes.fill "#ff8f00"
            ]
            []

        -- Bell top
        , Svg.circle
            [ Svg.Attributes.cx "50"
            , Svg.Attributes.cy "18"
            , Svg.Attributes.r "3"
            , Svg.Attributes.fill "#ffc107"
            ]
            []

        -- Notification dot
        , Svg.circle
            [ Svg.Attributes.cx "68"
            , Svg.Attributes.cy "28"
            , Svg.Attributes.r "10"
            , Svg.Attributes.fill "#f44336"
            , Svg.Attributes.stroke "white"
            , Svg.Attributes.strokeWidth "2"
            ]
            []

        -- Number in dot
        , Svg.text_
            [ Svg.Attributes.x "68"
            , Svg.Attributes.y "32"
            , Svg.Attributes.textAnchor "middle"
            , Svg.Attributes.fontSize "11"
            , Svg.Attributes.fill "white"
            , Svg.Attributes.fontWeight "bold"
            ]
            [ Svg.text "3" ]
        ]
