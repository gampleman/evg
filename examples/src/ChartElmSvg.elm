module ChartElmSvg exposing (main)

{-| A line chart with axes, grid lines, data line, markers, and a clip region.
Implemented with elm/svg.
-}

import Html exposing (Html)
import Svg exposing (Svg)
import Svg.Attributes


main : Html msg
main =
    let
        data =
            [ ( 0, 60 ), ( 40, 30 ), ( 80, 45 ), ( 120, 20 ), ( 160, 55 ), ( 200, 10 ), ( 240, 40 ) ]

        linePath =
            data
                |> List.indexedMap
                    (\i ( x, y ) ->
                        (if i == 0 then
                            "M"

                         else
                            "L"
                        )
                            ++ String.fromFloat (x + 40)
                            ++ " "
                            ++ String.fromFloat (y + 20)
                    )
                |> String.join " "
    in
    Svg.svg
        [ Svg.Attributes.viewBox "0 0 320 160"
        , Svg.Attributes.width "640"
        , Svg.Attributes.height "320"
        ]
        [ Svg.defs []
            [ Svg.clipPath [ Svg.Attributes.id "chart-area" ]
                [ Svg.rect
                    [ Svg.Attributes.x "40"
                    , Svg.Attributes.y "20"
                    , Svg.Attributes.width "240"
                    , Svg.Attributes.height "100"
                    ]
                    []
                ]
            , Svg.marker
                [ Svg.Attributes.id "dot"
                , Svg.Attributes.markerWidth "6"
                , Svg.Attributes.markerHeight "6"
                , Svg.Attributes.refX "3"
                , Svg.Attributes.refY "3"
                ]
                [ Svg.circle
                    [ Svg.Attributes.cx "3"
                    , Svg.Attributes.cy "3"
                    , Svg.Attributes.r "3"
                    , Svg.Attributes.fill "#1976d2"
                    ]
                    []
                ]
            ]
        , -- Grid lines (horizontal)
          Svg.g [ Svg.Attributes.stroke "#eee", Svg.Attributes.strokeWidth "1" ]
            (List.map
                (\y ->
                    Svg.line
                        [ Svg.Attributes.x1 "40"
                        , Svg.Attributes.y1 (String.fromInt y)
                        , Svg.Attributes.x2 "280"
                        , Svg.Attributes.y2 (String.fromInt y)
                        ]
                        []
                )
                [ 20, 45, 70, 95, 120 ]
            )

        -- Axes
        , Svg.line
            [ Svg.Attributes.x1 "40"
            , Svg.Attributes.y1 "120"
            , Svg.Attributes.x2 "280"
            , Svg.Attributes.y2 "120"
            , Svg.Attributes.stroke "#333"
            , Svg.Attributes.strokeWidth "1.5"
            ]
            []
        , Svg.line
            [ Svg.Attributes.x1 "40"
            , Svg.Attributes.y1 "20"
            , Svg.Attributes.x2 "40"
            , Svg.Attributes.y2 "120"
            , Svg.Attributes.stroke "#333"
            , Svg.Attributes.strokeWidth "1.5"
            ]
            []

        -- Data line (clipped to chart area)
        , Svg.g [ Svg.Attributes.clipPath "url(#chart-area)" ]
            [ Svg.path
                [ Svg.Attributes.d linePath
                , Svg.Attributes.fill "none"
                , Svg.Attributes.stroke "#1976d2"
                , Svg.Attributes.strokeWidth "2"
                , Svg.Attributes.strokeLinejoin "round"
                , Svg.Attributes.markerMid "url(#dot)"
                , Svg.Attributes.markerEnd "url(#dot)"
                , Svg.Attributes.markerStart "url(#dot)"
                ]
                []
            ]

        -- X-axis labels
        , Svg.g [ Svg.Attributes.fontSize "8", Svg.Attributes.fill "#666", Svg.Attributes.textAnchor "middle" ]
            (List.map
                (\( x, label ) ->
                    Svg.text_
                        [ Svg.Attributes.x (String.fromInt x)
                        , Svg.Attributes.y "135"
                        ]
                        [ Svg.text label ]
                )
                [ ( 40, "Mon" ), ( 80, "Tue" ), ( 120, "Wed" ), ( 160, "Thu" ), ( 200, "Fri" ), ( 240, "Sat" ), ( 280, "Sun" ) ]
            )

        -- Title
        , Svg.text_
            [ Svg.Attributes.x "160"
            , Svg.Attributes.y "12"
            , Svg.Attributes.textAnchor "middle"
            , Svg.Attributes.fontSize "10"
            , Svg.Attributes.fill "#333"
            , Svg.Attributes.fontWeight "bold"
            ]
            [ Svg.text "Weekly Activity" ]
        ]
