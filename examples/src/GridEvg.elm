module GridEvg exposing (main)

{-| Grid example from the README — evg version.
-}

import Evg exposing (Evg)
import Html exposing (Html)


main : Html msg
main =
    let
        dims =
            { width = 150, height = 150 }
    in
    Evg.svg [] dims
        [ grid 20 dims ]


grid : Float -> { width : Float, height : Float } -> Evg msg
grid lineEveryPx dims =
    let
        xCount =
            floor (dims.height / lineEveryPx)

        yCount =
            floor (dims.width / lineEveryPx)
    in
    Evg.group []
        [ List.range 0 xCount
            |> List.map
                (\i ->
                    Evg.line [] ( 0, toFloat i * lineEveryPx ) ( dims.width, toFloat i * lineEveryPx )
                )
            |> Evg.group []
        , List.range 0 yCount
            |> List.map
                (\i ->
                    Evg.line [] ( toFloat i * lineEveryPx, 0 ) ( toFloat i * lineEveryPx, dims.height )
                )
            |> Evg.group []
        ]
