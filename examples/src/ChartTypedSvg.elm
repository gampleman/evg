module ChartTypedSvg exposing (main)

{-| A line chart with axes, grid lines, data line, markers, and a clip region.
Implemented with elm-community/typed-svg.
-}

import Color
import Html exposing (Html)
import TypedSvg
import TypedSvg.Attributes
import TypedSvg.Core
import TypedSvg.Types


main : Html msg
main =
    let
        data =
            [ ( 0, 60 ), ( 40, 30 ), ( 80, 45 ), ( 120, 20 ), ( 160, 55 ), ( 200, 10 ), ( 240, 40 ) ]

        linePath =
            data
                |> List.indexedMap
                    (\i ( dx, dy ) ->
                        (if i == 0 then
                            "M"

                         else
                            "L"
                        )
                            ++ String.fromFloat (dx + 40)
                            ++ " "
                            ++ String.fromFloat (dy + 20)
                    )
                |> String.join " "
    in
    TypedSvg.svg
        [ TypedSvg.Attributes.viewBox 0 0 320 160
        , TypedSvg.Attributes.width (TypedSvg.Types.px 640)
        , TypedSvg.Attributes.height (TypedSvg.Types.px 320)
        ]
        [ TypedSvg.defs []
            [ TypedSvg.clipPath [ TypedSvg.Attributes.id "chart-area" ]
                [ TypedSvg.rect
                    [ TypedSvg.Attributes.x (TypedSvg.Types.px 40)
                    , TypedSvg.Attributes.y (TypedSvg.Types.px 20)
                    , TypedSvg.Attributes.width (TypedSvg.Types.px 240)
                    , TypedSvg.Attributes.height (TypedSvg.Types.px 100)
                    ]
                    []
                ]
            , TypedSvg.marker
                [ TypedSvg.Attributes.id "dot"
                , TypedSvg.Attributes.markerWidth (TypedSvg.Types.px 6)
                , TypedSvg.Attributes.markerHeight (TypedSvg.Types.px 6)
                , TypedSvg.Attributes.refX "3"
                , TypedSvg.Attributes.refY "3"
                ]
                [ TypedSvg.circle
                    [ TypedSvg.Attributes.cx (TypedSvg.Types.px 3)
                    , TypedSvg.Attributes.cy (TypedSvg.Types.px 3)
                    , TypedSvg.Attributes.r (TypedSvg.Types.px 3)
                    , TypedSvg.Attributes.fill (TypedSvg.Types.Paint (Color.rgb255 25 118 210))
                    ]
                    []
                ]
            ]
        , -- Grid lines (horizontal)
          TypedSvg.g
            [ TypedSvg.Attributes.stroke (TypedSvg.Types.Paint (Color.rgb255 238 238 238))
            , TypedSvg.Attributes.strokeWidth (TypedSvg.Types.px 1)
            ]
            (List.map
                (\gy ->
                    TypedSvg.line
                        [ TypedSvg.Attributes.x1 (TypedSvg.Types.px 40)
                        , TypedSvg.Attributes.y1 (TypedSvg.Types.px (toFloat gy))
                        , TypedSvg.Attributes.x2 (TypedSvg.Types.px 280)
                        , TypedSvg.Attributes.y2 (TypedSvg.Types.px (toFloat gy))
                        ]
                        []
                )
                [ 20, 45, 70, 95, 120 ]
            )

        -- Axes
        , TypedSvg.line
            [ TypedSvg.Attributes.x1 (TypedSvg.Types.px 40)
            , TypedSvg.Attributes.y1 (TypedSvg.Types.px 120)
            , TypedSvg.Attributes.x2 (TypedSvg.Types.px 280)
            , TypedSvg.Attributes.y2 (TypedSvg.Types.px 120)
            , TypedSvg.Attributes.stroke (TypedSvg.Types.Paint (Color.rgb255 51 51 51))
            , TypedSvg.Attributes.strokeWidth (TypedSvg.Types.px 1.5)
            ]
            []
        , TypedSvg.line
            [ TypedSvg.Attributes.x1 (TypedSvg.Types.px 40)
            , TypedSvg.Attributes.y1 (TypedSvg.Types.px 20)
            , TypedSvg.Attributes.x2 (TypedSvg.Types.px 40)
            , TypedSvg.Attributes.y2 (TypedSvg.Types.px 120)
            , TypedSvg.Attributes.stroke (TypedSvg.Types.Paint (Color.rgb255 51 51 51))
            , TypedSvg.Attributes.strokeWidth (TypedSvg.Types.px 1.5)
            ]
            []

        -- Data line (clipped to chart area)
        , TypedSvg.g [ TypedSvg.Attributes.clipPath (TypedSvg.Types.ClipPathFunc "url(#chart-area)") ]
            [ TypedSvg.path
                [ TypedSvg.Attributes.d linePath
                , TypedSvg.Attributes.fill TypedSvg.Types.PaintNone
                , TypedSvg.Attributes.stroke (TypedSvg.Types.Paint (Color.rgb255 25 118 210))
                , TypedSvg.Attributes.strokeWidth (TypedSvg.Types.px 2)
                , TypedSvg.Attributes.strokeLinejoin TypedSvg.Types.StrokeLinejoinRound
                , TypedSvg.Attributes.markerMid "url(#dot)"
                , TypedSvg.Attributes.markerEnd "url(#dot)"
                , TypedSvg.Attributes.markerStart "url(#dot)"
                ]
                []
            ]

        -- X-axis labels
        , TypedSvg.g
            [ TypedSvg.Attributes.fontSize (TypedSvg.Types.px 8)
            , TypedSvg.Attributes.fill (TypedSvg.Types.Paint (Color.rgb255 102 102 102))
            , TypedSvg.Attributes.textAnchor TypedSvg.Types.AnchorMiddle
            ]
            (List.map
                (\( lx, label ) ->
                    TypedSvg.text_
                        [ TypedSvg.Attributes.x (TypedSvg.Types.px (toFloat lx))
                        , TypedSvg.Attributes.y (TypedSvg.Types.px 135)
                        ]
                        [ TypedSvg.Core.text label ]
                )
                [ ( 40, "Mon" ), ( 80, "Tue" ), ( 120, "Wed" ), ( 160, "Thu" ), ( 200, "Fri" ), ( 240, "Sat" ), ( 280, "Sun" ) ]
            )

        -- Title
        , TypedSvg.text_
            [ TypedSvg.Attributes.x (TypedSvg.Types.px 160)
            , TypedSvg.Attributes.y (TypedSvg.Types.px 12)
            , TypedSvg.Attributes.textAnchor TypedSvg.Types.AnchorMiddle
            , TypedSvg.Attributes.fontSize (TypedSvg.Types.px 10)
            , TypedSvg.Attributes.fill (TypedSvg.Types.Paint (Color.rgb255 51 51 51))
            , TypedSvg.Attributes.fontWeight TypedSvg.Types.FontWeightBold
            ]
            [ TypedSvg.Core.text "Weekly Activity" ]
        ]
