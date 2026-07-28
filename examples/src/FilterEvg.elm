module FilterEvg exposing (main)

{-| Splash text filter example from the README — evg version.
-}

import Color
import Evg
import Evg.Filter as Filter
import Html exposing (Html)


flip : ( a -> b -> c) -> b -> a -> c 
flip fn b a =
    fn a b

main : Html msg
main =
    let
        splash { blur, frequency, color, scale } =
            Filter.sourceAlpha
                |> Filter.gaussianBlur blur
                |> flip (Filter.displacementMap { scale = scale })
                    (Filter.fractalNoise { baseFrequency = frequency, numOctaves = 1, seed = 1, stitchTiles = False })
                |> Filter.compositeIn (Filter.floodStr color)

        base =
            Filter.merge
                [ splash { blur = 6.5, color = "#16B5FF", frequency = 0.05, scale = 420 }
                , splash { blur = 0.1, color = "#A64DFF", frequency = 0.1, scale = 25 }
                , splash { blur = 3.5, color = "#9800FF", frequency = 0.07, scale = 220 }
                ]

        shifted =
            base
                |> Filter.colorMatrix [ [ 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0 ], [ 0, 0, 0, 1, 0 ] ]

        lit =
            shifted
                |> Filter.gaussianBlur 2
                |> Filter.specularLighting
                    { surfaceScale = 5
                    , specularConstant = 0.75
                    , specularExponent = 30
                    , lightingColor = Color.white
                    }
                    (Filter.pointLight { x = -50, y = -100, z = 400 })

        filterPipeline =
            Filter.compositeIn lit shifted
                |> Filter.compositeArithmetic 0 1 1 0 base
    in
    Evg.svg [] { width = 640, height = 300 }
        [ Evg.text
            [ Evg.fillStr "#16B5FF"
            , Evg.fontFamily "'Racing Sans One', cursive"
            , Evg.fontSize 160
            , Evg.filterWithCoordinates (Evg.objectBoundingBox { x = -0.25, y = -0.25, width = 1.5, height = 1.6 }) filterPipeline
            ]
            { x = 320, y = 170, anchor = Evg.Middle }
            "Evg"
        ]
