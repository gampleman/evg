module GridTypedSvg exposing (main)

{-| Grid example — typed-svg version.
-}

import Color
import Html exposing (Html)
import TypedSvg exposing (g, line, svg)
import TypedSvg.Attributes exposing (stroke, viewBox, x1, x2, y1, y2)
import TypedSvg.Core exposing (Svg)
import TypedSvg.Types exposing (Paint(..), px)


main : Html msg
main =
    svg [ viewBox 0 0 150 150, TypedSvg.Attributes.width (px 150), TypedSvg.Attributes.height (px 150) ]
        [ grid 20 { width = 150, height = 150 } ]


grid : Float -> { width : Float, height : Float } -> Svg msg
grid lineEveryPx dims =
    let
        xCount =
            floor (dims.height / lineEveryPx)

        yCount =
            floor (dims.width / lineEveryPx)
    in
    g []
        [ List.range 0 xCount
            |> List.map
                (\i ->
                    line
                        [ x1 (px 0)
                        , y1 (px (toFloat i * lineEveryPx))
                        , x2 (px dims.width)
                        , y2 (px (toFloat i * lineEveryPx))
                        , stroke (Paint Color.black)
                        ]
                        []
                )
            |> g []
        , List.range 0 yCount
            |> List.map
                (\i ->
                    line
                        [ x1 (px (toFloat i * lineEveryPx))
                        , y1 (px 0)
                        , x2 (px (toFloat i * lineEveryPx))
                        , y2 (px dims.height)
                        , stroke (Paint Color.black)
                        ]
                        []
                )
            |> g []
        ]
