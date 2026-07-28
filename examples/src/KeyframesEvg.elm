module KeyframesEvg exposing (main)

{-| Demonstrates the keyframes animation API with various scenarios:
- Simple attribute interpolation
- Mixed element types (segmented runs)
- Group opacity animation
-}

import Evg
import Evg.Animate as Animate
import Html exposing (Html)


main : Html msg
main =
    Html.div []
        [ Html.h3 [] [ Html.text "Pulsing circle (attr interpolation)" ]
        , pulsingCircle
        , Html.h3 [] [ Html.text "Shape morphing (segmented runs)" ]
        , shapeMorph
        , Html.h3 [] [ Html.text "Moving dot (position interpolation)" ]
        , movingDot
        , Html.h3 [] [ Html.text "Group animation (shared children)" ]
        , groupAnimation
        , Html.h3 [] [ Html.text "Appearing children (different child counts)" ]
        , appearingChildren
        ]


{-| Simple pulsing: radius and opacity change -}
pulsingCircle : Html msg
pulsingCircle =
    Evg.svg [] { width = 120, height = 120 }
        [ Animate.keyframes [ Animate.repeatIndefinite, Animate.easing Animate.easeInOut ]
            [ ( 0.0, Evg.circle [ Evg.fillStr "tomato", Evg.opacity 1 ] { r = 20, center = ( 60, 60 ) } )
            , ( 1.0, Evg.circle [ Evg.fillStr "tomato", Evg.opacity 0.4 ] { r = 50, center = ( 60, 60 ) } )
            , ( 2.0, Evg.circle [ Evg.fillStr "tomato", Evg.opacity 1 ] { r = 20, center = ( 60, 60 ) } )
            ]
        ]


{-| Mixed shapes: circle → circle → rect → rect → circle
Demonstrates segmented runs with visibility switching between incompatible types.
-}
shapeMorph : Html msg
shapeMorph =
    Evg.svg [] { width = 120, height = 120 }
        [ Animate.keyframes [ Animate.repeatIndefinite, Animate.easing Animate.easeInOut ]
            [ ( 0.0, Evg.circle [ Evg.fillStr "royalblue" ] { r = 20, center = ( 60, 60 ) } )
            , ( 1.0, Evg.circle [ Evg.fillStr "dodgerblue" ] { r = 40, center = ( 60, 60 ) } )
            , ( 2.0, Evg.rect [ Evg.fillStr "limegreen" ] { x = 20, y = 20, width = 80, height = 80 } )
            , ( 3.0, Evg.rect [ Evg.fillStr "forestgreen" ] { x = 30, y = 30, width = 60, height = 60 } )
            , ( 4.0, Evg.circle [ Evg.fillStr "royalblue" ] { r = 20, center = ( 60, 60 ) } )
            ]
        ]


{-| A dot that moves in a square path -}
movingDot : Html msg
movingDot =
    Evg.svg [] { width = 120, height = 120 }
        [ Animate.keyframes [ Animate.repeatIndefinite, Animate.easing Animate.easeInOut ]
            [ ( 0.0, Evg.circle [ Evg.fillStr "hotpink" ] { r = 8, center = ( 20, 20 ) } )
            , ( 0.5, Evg.circle [ Evg.fillStr "hotpink" ] { r = 8, center = ( 100, 20 ) } )
            , ( 1.0, Evg.circle [ Evg.fillStr "hotpink" ] { r = 8, center = ( 100, 100 ) } )
            , ( 1.5, Evg.circle [ Evg.fillStr "hotpink" ] { r = 8, center = ( 20, 100 ) } )
            , ( 2.0, Evg.circle [ Evg.fillStr "hotpink" ] { r = 8, center = ( 20, 20 ) } )
            ]
        ]


{-| A group where a shared background changes color while a child shape
moves independently.
-}
groupAnimation : Html msg
groupAnimation =
    Evg.svg [] { width = 120, height = 120 }
        [ Animate.keyframes [ Animate.repeatIndefinite, Animate.easing Animate.easeInOut ]
            [ ( 0.0
              , Evg.group [ Evg.opacity 1 ]
                    [ Evg.rect [ Evg.fillStr "lavender" ] { x = 10, y = 10, width = 100, height = 100 }
                    , Evg.circle [ Evg.fillStr "indigo" ] { r = 15, center = ( 30, 60 ) }
                    ]
              )
            , ( 1.0
              , Evg.group [ Evg.opacity 0.8 ]
                    [ Evg.rect [ Evg.fillStr "mistyrose" ] { x = 10, y = 10, width = 100, height = 100 }
                    , Evg.circle [ Evg.fillStr "crimson" ] { r = 25, center = ( 90, 60 ) }
                    ]
              )
            , ( 2.0
              , Evg.group [ Evg.opacity 1 ]
                    [ Evg.rect [ Evg.fillStr "lavender" ] { x = 10, y = 10, width = 100, height = 100 }
                    , Evg.circle [ Evg.fillStr "indigo" ] { r = 15, center = ( 30, 60 ) }
                    ]
              )
            ]
        ]


{-| A group where the number of children changes between frames —
demonstrates visibility switching at the child level.
-}
appearingChildren : Html msg
appearingChildren =
    Evg.svg [] { width = 120, height = 120 }
        [ Animate.keyframes [ Animate.repeatIndefinite, Animate.easing Animate.easeInOut ]
            [ ( 0.0
              , Evg.group []
                    [ Evg.circle [ Evg.fillStr "steelblue" ] { r = 15, center = ( 30, 60 ) }
                    , Evg.circle [ Evg.fillStr "coral" ] { r = 15, center = ( 60, 60 ) }
                    ]
              )
            , ( 1.0
              , Evg.group []
                    [ Evg.circle [ Evg.fillStr "steelblue" ] { r = 20, center = ( 30, 40 ) }
                    , Evg.circle [ Evg.fillStr "coral" ] { r = 20, center = ( 60, 40 ) }
                    , Evg.circle [ Evg.fillStr "gold" ] { r = 20, center = ( 90, 40 ) }
                    ]
              )
            , ( 2.0
              , Evg.group []
                    [ Evg.circle [ Evg.fillStr "steelblue" ] { r = 15, center = ( 30, 60 ) }
                    , Evg.circle [ Evg.fillStr "coral" ] { r = 15, center = ( 60, 60 ) }
                    ]
              )
            ]
        ]
