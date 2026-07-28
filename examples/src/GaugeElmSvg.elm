module GaugeElmSvg exposing (main)

{-| A speedometer-style gauge with tick marks, labels, and a needle.
Implemented with elm/svg.
-}

import Html exposing (Html)
import Svg exposing (Svg)
import Svg.Attributes


pointAt : Float -> Float -> ( Float, Float )
pointAt radius fraction =
    let
        rad =
            (180 + fraction * 180) * pi / 180
    in
    ( 200 + radius * cos rad, 200 + radius * sin rad )


main : Html msg
main =
    let
        value =
            0.72

        ( arcEndX, arcEndY ) =
            pointAt 184 value

        ( needleX, needleY ) =
            pointAt 150 value
    in
    Svg.svg
        [ Svg.Attributes.viewBox "0 0 400 220"
        , Svg.Attributes.width "400"
        , Svg.Attributes.height "220"
        ]
        [ -- Background arc
          Svg.path
            [ Svg.Attributes.d "M 16 200 A 184 184 0 0 1 384 200"
            , Svg.Attributes.fill "none"
            , Svg.Attributes.stroke "#e0e0e0"
            , Svg.Attributes.strokeWidth "16"
            , Svg.Attributes.strokeLinecap "round"
            ]
            []

        -- Colored arc (value indicator)
        , Svg.path
            [ Svg.Attributes.d
                ("M 16 200 A 184 184 0 0 1 "
                    ++ String.fromFloat arcEndX
                    ++ " "
                    ++ String.fromFloat arcEndY
                )
            , Svg.Attributes.fill "none"
            , Svg.Attributes.stroke "#4caf50"
            , Svg.Attributes.strokeWidth "16"
            , Svg.Attributes.strokeLinecap "round"
            ]
            []

        -- Tick marks
        , Svg.g []
            (List.map
                (\i ->
                    let
                        ( x1, y1 ) =
                            pointAt 160 (toFloat i / 8)

                        ( x2, y2 ) =
                            pointAt 178 (toFloat i / 8)
                    in
                    Svg.line
                        [ Svg.Attributes.x1 (String.fromFloat x1)
                        , Svg.Attributes.y1 (String.fromFloat y1)
                        , Svg.Attributes.x2 (String.fromFloat x2)
                        , Svg.Attributes.y2 (String.fromFloat y2)
                        , Svg.Attributes.stroke "#666"
                        , Svg.Attributes.strokeWidth "4"
                        , Svg.Attributes.strokeLinecap "round"
                        ]
                        []
                )
                (List.range 0 8)
            )

        -- Needle
        , Svg.line
            [ Svg.Attributes.x1 "200"
            , Svg.Attributes.y1 "200"
            , Svg.Attributes.x2 (String.fromFloat needleX)
            , Svg.Attributes.y2 (String.fromFloat needleY)
            , Svg.Attributes.stroke "#d32f2f"
            , Svg.Attributes.strokeWidth "5"
            , Svg.Attributes.strokeLinecap "round"
            ]
            []

        -- Center dot
        , Svg.circle
            [ Svg.Attributes.cx "200"
            , Svg.Attributes.cy "200"
            , Svg.Attributes.r "10"
            , Svg.Attributes.fill "#333"
            ]
            []

        -- Label
        , Svg.text_
            [ Svg.Attributes.x "200"
            , Svg.Attributes.y "170"
            , Svg.Attributes.textAnchor "middle"
            , Svg.Attributes.fontSize "24"
            , Svg.Attributes.fill "#666"
            ]
            [ Svg.text (String.fromInt (round (value * 100)) ++ "%") ]
        ]
