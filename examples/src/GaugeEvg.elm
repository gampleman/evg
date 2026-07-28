module GaugeEvg exposing (main)

{-| A speedometer-style gauge with tick marks, labels, and a needle.
Implemented with gampleman/evg.
-}

import Evg
import Evg.Path exposing (Path(..), PathSegment(..))
import Html exposing (Html)


main : Html msg
main =
    let
        value =
            0.72

        center =
            ( 200, 200 )

        pointAt radius fraction =
            let
                rad =
                    (180 + fraction * 180) * pi / 180
            in
            ( 200 + radius * cos rad, 200 + radius * sin rad )

        tick i =
            Evg.line [ Evg.strokeStr "#666", Evg.strokeWidth 4, Evg.linecapRound ]
                (pointAt 160 (toFloat i / 8))
                (pointAt 178 (toFloat i / 8))
    in
    Evg.svg []
        { width = 400, height = 220 }
        [ -- Background arc
          Evg.path
            [ Evg.strokeStr "#e0e0e0"
            , Evg.strokeWidth 16
            , Evg.fillStr "none"
            , Evg.linecapRound
            ]
            [ M ( 16, 200 ) [ A 184 184 0 False True ( 384, 200 ) ] ]
        , -- Value arc
          Evg.path
            [ Evg.strokeStr "#4caf50"
            , Evg.strokeWidth 16
            , Evg.fillStr "none"
            , Evg.linecapRound
            ]
            [ M ( 16, 200 ) [ A 184 184 0 False True (pointAt 184 value) ] ]
        , -- Tick marks
          Evg.group [] (List.map tick (List.range 0 8))
        , -- Needle
          Evg.line
            [ Evg.strokeStr "#d32f2f", Evg.strokeWidth 5, Evg.linecapRound ]
            center
            (pointAt 150 value)
        , -- Center dot
          Evg.circle [ Evg.fillStr "#333" ] { r = 10, center = center }
        , -- Label
          Evg.text [ Evg.fillStr "#666", Evg.fontSize 24 ]
            { x = 200, y = 170, anchor = Evg.Middle }
            (String.fromInt (round (value * 100)) ++ "%")
        ]
