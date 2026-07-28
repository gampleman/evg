module GridElmSvg exposing (main)

{-| Grid example from the README — elm/svg version.
-}

import Html exposing (Html)
import Svg exposing (Svg)
import Svg.Attributes


main : Html msg
main =
    let
        dims =
            { width = 150, height = 150 }

        lineEveryPx =
            20
    in
    Svg.svg
        [ Svg.Attributes.viewBox "0 0 150 150"
        , Svg.Attributes.width "150"
        , Svg.Attributes.height "150"
        ]
        [ grid lineEveryPx dims ]


grid : Float -> { width : Float, height : Float } -> Svg msg
grid lineEveryPx dims =
    let
        xCount =
            floor (dims.height / lineEveryPx)

        yCount =
            floor (dims.width / lineEveryPx)
    in
    Svg.g []
        [ List.range 0 xCount
            |> List.map
                (\i ->
                    Svg.line
                        [ Svg.Attributes.x1 "0"
                        , Svg.Attributes.y1 (String.fromFloat (toFloat i * lineEveryPx))
                        , Svg.Attributes.x2 (String.fromFloat dims.width)
                        , Svg.Attributes.y2 (String.fromFloat (toFloat i * lineEveryPx))
                        , Svg.Attributes.stroke "black"
                        ]
                        []
                )
            |> Svg.g []
        , List.range 0 yCount
            |> List.map
                (\i ->
                    Svg.line
                        [ Svg.Attributes.x1 (String.fromFloat (toFloat i * lineEveryPx))
                        , Svg.Attributes.y1 "0"
                        , Svg.Attributes.x2 (String.fromFloat (toFloat i * lineEveryPx))
                        , Svg.Attributes.y2 (String.fromFloat dims.height)
                        , Svg.Attributes.stroke "black"
                        ]
                        []
                )
            |> Svg.g []
        ]
