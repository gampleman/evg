module PatternEvg exposing (main)

{-| Pattern fill examples — evg version.
Shows checkerboard, diagonal stripes, and polka dots.
-}

import Color
import Evg exposing (Evg)
import Evg.Advanced as Advanced
import Evg.Paint as Paint
import Evg.Transform as Transform
import Html exposing (Html)


main : Html msg
main =
    Evg.svg []
        { width = 360, height = 120 }
        [ Evg.rect [ Evg.fill checkerboard ]
            { x = 10, y = 10, width = 100, height = 100 }
        , Evg.rect [ Evg.stroke stripes, Evg.strokeWidth 10, Evg.fill Paint.none ]
            { x = 130, y = 15, width = 100, height = 90 }
        , Evg.rect [ Evg.fill dots, Evg.strokeStr "#333", Evg.strokeWidth 1 ]
            { x = 250, y = 10, width = 100, height = 100 }
        ]


checkerboard : Paint.Paint
checkerboard =
    Paint.patternWithCoordinates []
        (Evg.objectBoundingBox { x = 0, y = 0, width = 0.2, height = 0.2 })
        [ Evg.rect [ Evg.fillStr "#eee" ] { x = 0, y = 0, width = 0.2, height = 0.2 }
        , Evg.rect [ Evg.fillStr "#333" ] { x = 0, y = 0, width = 0.1, height = 0.1 }
        , Evg.rect [ Evg.fillStr "#333" ] { x = 0.1, y = 0.1, width = 0.1, height = 0.1 }
        ]


stripes : Paint.Paint
stripes =
    Paint.patternWithCoordinates [ Transform.rotate 45 ]
        (Evg.objectBoundingBox { x = 0, y = 0, width = 0.1, height = 0.1 })
        [ Evg.rect [ Evg.fillStr "white" ] { x = 0, y = 0, width = 0.1, height = 0.1 }
        , Evg.rect [ Evg.fill (Paint.solid (Color.rgb255 70 130 180)) ] { x = 0.05, y = 0, width = 0.05, height = 0.1 }
        ]


dots : Paint.Paint
dots =
    Paint.pattern [ Advanced.viewBox 0 0 10 10 ]
        { width = 10, height = 10 }
        [ Evg.rect [ Evg.fillStr "hotpink" ] { x = 0, y = 0, width = 10, height = 10 }
        , Evg.circle [ Evg.fill (Paint.solid (Color.rgb255 220 60 60)) ] { r = 3, center = ( 5, 5 ) }
        ]
