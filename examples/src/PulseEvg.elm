module PulseEvg exposing (main)

{-| An animated pulsing shape demonstrating SMIL animation.
Implemented with gampleman/evg using the keyframes API.
-}

import Evg
import Evg.Animate as Animate
import Html exposing (Html)


main : Html msg
main =
    Evg.svg [] { width = 200, height = 200 }
        [ Animate.keyframes [ Animate.repeatIndefinite, Animate.easing Animate.easeInOut ]
            [ ( 0.0, Evg.circle [ Evg.fillStr "tomato", Evg.opacity 1 ] { r = 30, center = ( 100, 100 ) } )
            , ( 1.0, Evg.circle [ Evg.fillStr "tomato", Evg.opacity 0.5 ] { r = 60, center = ( 100, 100 ) } )
            , ( 2.0, Evg.circle [ Evg.fillStr "tomato", Evg.opacity 1 ] { r = 30, center = ( 100, 100 ) } )
            ]
        ]
