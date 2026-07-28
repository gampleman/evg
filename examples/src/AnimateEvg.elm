module AnimateEvg exposing (main)

{-| Pulse rect animation from the README — evg version.
-}

import Evg
import Evg.Animate as Animate
import Html exposing (Html)


main : Html msg
main =
    Evg.svg [] { width = 120, height = 120 }
        [ Evg.rect [ Evg.cornerRadius 30, Evg.fillStr "navy" ]
            { x = 10, y = 10, width = 100, height = 100 }
            |> Animate.animate [ Animate.repeatIndefinite ]
                "rx"
                [ ( 0.8, Animate.easeLinear, "50" )
                , ( 1.8, Animate.easeInOut, "20" )
                , ( 3.0, Animate.easeLinear, "30" )
                ]
        ]
