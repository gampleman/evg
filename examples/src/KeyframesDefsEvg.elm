module KeyframesDefsEvg exposing (main)

{-| Demonstrates animating between different defs: gradients, filters, patterns, and clips.
-}

import Color
import Evg exposing (Evg)
import Evg.Animate as Animate
import Evg.Clip as Clip
import Evg.Filter as Filter
import Evg.Paint as Paint
import Html exposing (Html)


main : Html msg
main =
    Evg.svg [] { width = 500, height = 300 }
        [ gradientAnimation
        , filterAnimation
        , patternAnimation
        , clipAnimation
        ]



-- Animate between two linear gradients


gradientAnimation : Evg msg
gradientAnimation =
    let
        sunset =
            Paint.linearGradient ( 0, 0 ) ( 0, 1 )
                [ Paint.stop 0 (Color.rgb255 255 100 0)
                , Paint.stop 0.01 (Color.rgb255 255 100 0)
                , Paint.stop 1 (Color.rgb255 255 200 50)
                ]

        ocean =
            Paint.linearGradient ( 0, 0 ) ( 0, 1 )
                [ Paint.stop 0 (Color.rgb255 0 100 200)
                , Paint.stop 0.5 (Color.rgb255 200 100 100)
                , Paint.stop 1 (Color.rgb255 0 200 150)
                ]
    in
    Animate.keyframes [ Animate.repeatIndefinite ]
        [ ( 0, Evg.rect [ Evg.fill sunset ] { x = 10, y = 10, width = 100, height = 100 } )
        , ( 2, Evg.rect [ Evg.fill ocean ] { x = 10, y = 10, width = 100, height = 100 } )
        , ( 4, Evg.rect [ Evg.fill sunset ] { x = 10, y = 10, width = 100, height = 100 } )
        ]



-- Animate between two filters


filterAnimation : Evg msg
filterAnimation =
    let
        blur radius =
            Filter.sourceGraphic
                |> Filter.gaussianBlur radius
                |> Filter.withinSRGB
                |> Evg.filter

       
    in
    Animate.keyframes [ Animate.repeatIndefinite ]
        [ ( 0, Evg.circle [ Evg.fillStr "tomato", blur 0 ] { r = 45, center = ( 190, 60 ) } )
        , ( 2, Evg.circle [ Evg.fillStr "tomato", blur 5 ] { r = 45, center = ( 190, 60 ) } )
        , ( 4, Evg.circle [ Evg.fillStr "tomato", blur 0 ] { r = 45, center = ( 190, 60 ) } )
        ]



-- Animate between two patterns


patternAnimation : Evg msg
patternAnimation =
    let
        checkers =
            Paint.patternWithCoordinates []
                (Evg.objectBoundingBox { x = 0, y = 0, width = 0.25, height = 0.25 })
                [ Evg.rect [ Evg.fillStr "white" ] { x = 0, y = 0, width = 0.25, height = 0.25 }
                , Evg.rect [ Evg.fillStr "royalblue" ] { x = 0, y = 0, width = 0.125, height = 0.125 }
                , Evg.rect [ Evg.fillStr "royalblue" ] { x = 0.125, y = 0.125, width = 0.125, height = 0.125 }
                ]

        stripes =
            Paint.patternWithCoordinates []
                (Evg.objectBoundingBox { x = 0, y = 0, width = 0.1, height = 1 })
                [ Evg.rect [ Evg.fillStr "white" ] { x = 0, y = 0, width = 0.1, height = 1 }
                , Evg.rect [ Evg.fillStr "coral" ] { x = 0, y = 0, width = 0.05, height = 1 }
                ]
    in
    Animate.keyframes [ Animate.repeatIndefinite ]
        [ ( 0, Evg.rect [ Evg.fill checkers ] { x = 260, y = 10, width = 100, height = 100 } )
        , ( 2, Evg.rect [ Evg.fill stripes ] { x = 260, y = 10, width = 100, height = 100 } )
        , ( 4, Evg.rect [ Evg.fill checkers ] { x = 260, y = 10, width = 100, height = 100 } )
        ]



-- Animate between two clip paths


clipAnimation : Evg msg
clipAnimation =
    let
        circleClip r =
            Clip.clip (Evg.circle [] { r = r, center = ( 410, 50 ) })

        diamondClip =
            Clip.clip
                (Evg.polygon []
                    [ ( 50, 5 ), ( 95, 50 ), ( 50, 95 ), ( 5, 50 ) ]
                )
    in
    Animate.keyframes [ Animate.repeatIndefinite ]
        [ ( 0
          , Evg.rect [ Evg.fillStr "mediumseagreen", circleClip 10 ]
                { x = 380, y = 10, width = 100, height = 100 }
          )
        , ( 2
          , Evg.rect [ Evg.fillStr "mediumseagreen", circleClip 40 ]
                { x = 380, y = 10, width = 100, height = 100 }
          )
        , ( 4
          , Evg.rect [ Evg.fillStr "mediumseagreen", circleClip 10 ]
                { x = 380, y = 10, width = 100, height = 100 }
          )
        ]
