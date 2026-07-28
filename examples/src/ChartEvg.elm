module ChartEvg exposing (main)

{-| A line chart with axes, grid lines, data line, markers, and a clip region.
Implemented with gampleman/evg.
-}

import Evg
import Evg.Clip as Clip
import Evg.Marker as Marker
import Evg.Path exposing (Path(..), PathSegment(..))
import Evg.Text as Text
import Html exposing (Html)


main : Html msg
main =
    let
        data =
            [ ( 40, 80 ), ( 80, 50 ), ( 120, 65 ), ( 160, 40 ), ( 200, 75 ), ( 240, 30 ), ( 280, 60 ) ]

        linePath =
            case data of
                first :: rest ->
                    M first (List.map L rest)

                [] ->
                    M ( 0, 0 ) []

        dot =
            Marker.marker []
                { width = 6, height = 6, refX = 3, refY = 3 }
                Marker.AutoOrientation
                (Evg.circle [ Evg.fillStr "#1976d2" ] { r = 3, center = ( 3, 3 ) })

        chartClip =
            Clip.clip
                (Evg.rect [] { x = 40, y = 20, width = 240, height = 100 })

        gridLine y =
            Evg.line [ Evg.strokeStr "#eee", Evg.strokeWidth 1 ]
                ( 40, y )
                ( 280, y )

        xLabel x label =
            Evg.text [ Evg.fillStr "#666", Evg.fontSize 8 ]
                { x = x, y = 135, anchor = Evg.Middle }
                label
    in
    Evg.svg [ Evg.style "width: 640px; height: 320px" ]
        { width = 320, height = 160 }
        [ -- Grid
          Evg.group [] (List.map gridLine [ 20, 45, 70, 95, 120 ])
        , -- Axes
          Evg.line [ Evg.strokeStr "#333", Evg.strokeWidth 1.5 ] ( 40, 120 ) ( 280, 120 )
        , Evg.line [ Evg.strokeStr "#333", Evg.strokeWidth 1.5 ] ( 40, 20 ) ( 40, 120 )
        , -- Data line with markers (clipped)
          Evg.group [ chartClip ]
            [ Evg.path
                [ Evg.fillStr "none"
                , Evg.strokeStr "#1976d2"
                , Evg.strokeWidth 2
                , Evg.linejoinRound
                , Marker.markerStart dot
                , Marker.markerMid dot
                , Marker.markerEnd dot
                ]
                [ linePath ]
            ]
        , -- X-axis labels
          Evg.group []
            [ xLabel 40 "Mon"
            , xLabel 80 "Tue"
            , xLabel 120 "Wed"
            , xLabel 160 "Thu"
            , xLabel 200 "Fri"
            , xLabel 240 "Sat"
            , xLabel 280 "Sun"
            ]
        , -- Title
          Evg.text [ Evg.fillStr "#333", Evg.fontSize 10, Text.fontWeight Text.Bold ]
            { x = 160, y = 12, anchor = Evg.Middle }
            "Weekly Activity"
        ]
