module SunsetEvg exposing (main)

{-| A sunset scene with gradient sky, sun, mountains, and water.
Implemented with gampleman/evg.
-}

import Color
import Evg
import Evg.Paint as Paint
import Html exposing (Html)


main : Html msg
main =
    let
        sky =
            Paint.linearGradient ( 0.5, 0 ) ( 0.5, 1 )
                [ Paint.stop 0 (Color.rgb255 26 5 51)
                , Paint.stop 0.4 (Color.rgb255 194 24 91)
                , Paint.stop 0.7 (Color.rgb255 255 111 0)
                , Paint.stop 1 (Color.rgb255 255 171 0)
                ]

        sun =
            Paint.radialGradient ( 0.5, 0.5 ) 0.5
                [ Paint.stop 0 (Color.rgb255 255 245 157)
                , Paint.stop 0.8 (Color.rgb255 255 171 0)
                , Paint.stopWithOpacity 1 (Color.rgb255 255 111 0) 0
                ]

        water =
            Paint.linearGradient ( 0.5, 0 ) ( 0.5, 1 )
                [ Paint.stopWithOpacity 0 (Color.rgb255 255 111 0) 0.6
                , Paint.stop 1 (Color.rgb255 13 71 161)
                ]
    in
    Evg.svg [] { width = 400, height = 300 }
        [ -- Sky
          Evg.rect [ Evg.fill sky ] { x = 0, y = 0, width = 400, height = 300 }

        , -- Sun
          Evg.circle [ Evg.fill sun ] { r = 60, center = ( 200, 180 ) }

        , -- Mountains
          Evg.polygon [ Evg.fillStr "#1a237e", Evg.opacity 0.8 ]
            [ ( 0, 220 ), ( 80, 140 ), ( 160, 220 ) ]
        , Evg.polygon [ Evg.fillStr "#283593", Evg.opacity 0.7 ]
            [ ( 120, 220 ), ( 220, 120 ), ( 320, 220 ) ]
        , Evg.polygon [ Evg.fillStr "#1a237e", Evg.opacity 0.8 ]
            [ ( 280, 220 ), ( 360, 150 ), ( 440, 220 ) ]

        , -- Water
          Evg.rect [ Evg.fill water ] { x = 0, y = 220, width = 400, height = 80 }

        , -- Sun reflection
          Evg.ellipse [ Evg.fillStr "#ffab00", Evg.opacity 0.4 ]
            { rx = 40, ry = 15, center = ( 200, 260 ) }
        ]
