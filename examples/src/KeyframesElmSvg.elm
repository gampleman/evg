module KeyframesElmSvg exposing (main)

{-| Keyframe-style animations hand-written in raw SMIL — elm/svg version.
Mirrors the scenarios from KeyframesEvg: attribute interpolation, shape
morphing via visibility switching, position interpolation, group animation,
and children that appear and disappear.
-}

import Html exposing (Html)
import Svg exposing (Svg)
import Svg.Attributes


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


svg120 : List (Svg msg) -> Html msg
svg120 =
    Svg.svg
        [ Svg.Attributes.viewBox "0 0 120 120"
        , Svg.Attributes.width "120"
        , Svg.Attributes.height "120"
        ]


{-| Simple pulsing: radius and opacity change
-}
pulsingCircle : Html msg
pulsingCircle =
    svg120
        [ Svg.circle
            [ Svg.Attributes.cx "60", Svg.Attributes.cy "60", Svg.Attributes.r "20", Svg.Attributes.fill "tomato" ]
            [ Svg.animate
                [ Svg.Attributes.attributeName "r"
                , Svg.Attributes.values "20;50;20"
                , Svg.Attributes.keyTimes "0;0.5;1"
                , Svg.Attributes.calcMode "spline"
                , Svg.Attributes.keySplines ".5 0 .5 1;.5 0 .5 1"
                , Svg.Attributes.dur "2s"
                , Svg.Attributes.repeatCount "indefinite"
                ]
                []
            , Svg.animate
                [ Svg.Attributes.attributeName "opacity"
                , Svg.Attributes.values "1;0.4;1"
                , Svg.Attributes.keyTimes "0;0.5;1"
                , Svg.Attributes.calcMode "spline"
                , Svg.Attributes.keySplines ".5 0 .5 1;.5 0 .5 1"
                , Svg.Attributes.dur "2s"
                , Svg.Attributes.repeatCount "indefinite"
                ]
                []
            ]
        ]


{-| Mixed shapes: circle → rect → circle.
Incompatible element types can't interpolate, so each shape is shown
during its window with a discrete visibility switch.
-}
shapeMorph : Html msg
shapeMorph =
    svg120
        [ Svg.g [ Svg.Attributes.visibility "hidden" ]
            [ Svg.circle
                [ Svg.Attributes.cx "60", Svg.Attributes.cy "60", Svg.Attributes.r "20", Svg.Attributes.fill "royalblue" ]
                [ Svg.animate
                    [ Svg.Attributes.attributeName "r"
                    , Svg.Attributes.values "20;40;40"
                    , Svg.Attributes.keyTimes "0;0.25;1"
                    , Svg.Attributes.calcMode "spline"
                    , Svg.Attributes.keySplines ".5 0 .5 1;.5 0 .5 1"
                    , Svg.Attributes.dur "4s"
                    , Svg.Attributes.repeatCount "indefinite"
                    ]
                    []
                , Svg.animate
                    [ Svg.Attributes.attributeName "fill"
                    , Svg.Attributes.values "royalblue;dodgerblue;dodgerblue"
                    , Svg.Attributes.keyTimes "0;0.25;1"
                    , Svg.Attributes.calcMode "spline"
                    , Svg.Attributes.keySplines ".5 0 .5 1;.5 0 .5 1"
                    , Svg.Attributes.dur "4s"
                    , Svg.Attributes.repeatCount "indefinite"
                    ]
                    []
                ]
            , Svg.animate
                [ Svg.Attributes.attributeName "visibility"
                , Svg.Attributes.values "visible;hidden"
                , Svg.Attributes.keyTimes "0;0.5"
                , Svg.Attributes.calcMode "discrete"
                , Svg.Attributes.dur "4s"
                , Svg.Attributes.repeatCount "indefinite"
                ]
                []
            ]
        , Svg.g [ Svg.Attributes.visibility "hidden" ]
            [ Svg.rect
                [ Svg.Attributes.x "20", Svg.Attributes.y "20", Svg.Attributes.width "80", Svg.Attributes.height "80", Svg.Attributes.fill "limegreen" ]
                [ Svg.animate
                    [ Svg.Attributes.attributeName "x"
                    , Svg.Attributes.values "20;20;30;30"
                    , Svg.Attributes.keyTimes "0;0.5;0.75;1"
                    , Svg.Attributes.calcMode "spline"
                    , Svg.Attributes.keySplines ".5 0 .5 1;.5 0 .5 1;.5 0 .5 1"
                    , Svg.Attributes.dur "4s"
                    , Svg.Attributes.repeatCount "indefinite"
                    ]
                    []
                , Svg.animate
                    [ Svg.Attributes.attributeName "y"
                    , Svg.Attributes.values "20;20;30;30"
                    , Svg.Attributes.keyTimes "0;0.5;0.75;1"
                    , Svg.Attributes.calcMode "spline"
                    , Svg.Attributes.keySplines ".5 0 .5 1;.5 0 .5 1;.5 0 .5 1"
                    , Svg.Attributes.dur "4s"
                    , Svg.Attributes.repeatCount "indefinite"
                    ]
                    []
                , Svg.animate
                    [ Svg.Attributes.attributeName "width"
                    , Svg.Attributes.values "80;80;60;60"
                    , Svg.Attributes.keyTimes "0;0.5;0.75;1"
                    , Svg.Attributes.calcMode "spline"
                    , Svg.Attributes.keySplines ".5 0 .5 1;.5 0 .5 1;.5 0 .5 1"
                    , Svg.Attributes.dur "4s"
                    , Svg.Attributes.repeatCount "indefinite"
                    ]
                    []
                , Svg.animate
                    [ Svg.Attributes.attributeName "height"
                    , Svg.Attributes.values "80;80;60;60"
                    , Svg.Attributes.keyTimes "0;0.5;0.75;1"
                    , Svg.Attributes.calcMode "spline"
                    , Svg.Attributes.keySplines ".5 0 .5 1;.5 0 .5 1;.5 0 .5 1"
                    , Svg.Attributes.dur "4s"
                    , Svg.Attributes.repeatCount "indefinite"
                    ]
                    []
                , Svg.animate
                    [ Svg.Attributes.attributeName "fill"
                    , Svg.Attributes.values "limegreen;limegreen;forestgreen;forestgreen"
                    , Svg.Attributes.keyTimes "0;0.5;0.75;1"
                    , Svg.Attributes.calcMode "spline"
                    , Svg.Attributes.keySplines ".5 0 .5 1;.5 0 .5 1;.5 0 .5 1"
                    , Svg.Attributes.dur "4s"
                    , Svg.Attributes.repeatCount "indefinite"
                    ]
                    []
                ]
            , Svg.animate
                [ Svg.Attributes.attributeName "visibility"
                , Svg.Attributes.values "hidden;visible"
                , Svg.Attributes.keyTimes "0;0.5"
                , Svg.Attributes.calcMode "discrete"
                , Svg.Attributes.dur "4s"
                , Svg.Attributes.repeatCount "indefinite"
                ]
                []
            ]
        ]


{-| A dot that moves in a square path
-}
movingDot : Html msg
movingDot =
    svg120
        [ Svg.circle
            [ Svg.Attributes.cx "20", Svg.Attributes.cy "20", Svg.Attributes.r "8", Svg.Attributes.fill "hotpink" ]
            [ Svg.animate
                [ Svg.Attributes.attributeName "cx"
                , Svg.Attributes.values "20;100;100;20;20"
                , Svg.Attributes.keyTimes "0;0.25;0.5;0.75;1"
                , Svg.Attributes.calcMode "spline"
                , Svg.Attributes.keySplines ".5 0 .5 1;.5 0 .5 1;.5 0 .5 1;.5 0 .5 1"
                , Svg.Attributes.dur "2s"
                , Svg.Attributes.repeatCount "indefinite"
                ]
                []
            , Svg.animate
                [ Svg.Attributes.attributeName "cy"
                , Svg.Attributes.values "20;20;100;100;20"
                , Svg.Attributes.keyTimes "0;0.25;0.5;0.75;1"
                , Svg.Attributes.calcMode "spline"
                , Svg.Attributes.keySplines ".5 0 .5 1;.5 0 .5 1;.5 0 .5 1;.5 0 .5 1"
                , Svg.Attributes.dur "2s"
                , Svg.Attributes.repeatCount "indefinite"
                ]
                []
            ]
        ]


{-| A group where a shared background changes color while a child shape
moves independently.
-}
groupAnimation : Html msg
groupAnimation =
    svg120
        [ Svg.g []
            [ Svg.rect
                [ Svg.Attributes.x "10", Svg.Attributes.y "10", Svg.Attributes.width "100", Svg.Attributes.height "100", Svg.Attributes.fill "lavender" ]
                [ Svg.animate
                    [ Svg.Attributes.attributeName "fill"
                    , Svg.Attributes.values "lavender;mistyrose;lavender"
                    , Svg.Attributes.keyTimes "0;0.5;1"
                    , Svg.Attributes.calcMode "spline"
                    , Svg.Attributes.keySplines ".5 0 .5 1;.5 0 .5 1"
                    , Svg.Attributes.dur "2s"
                    , Svg.Attributes.repeatCount "indefinite"
                    ]
                    []
                ]
            , Svg.circle
                [ Svg.Attributes.cx "30", Svg.Attributes.cy "60", Svg.Attributes.r "15", Svg.Attributes.fill "indigo" ]
                [ Svg.animate
                    [ Svg.Attributes.attributeName "fill"
                    , Svg.Attributes.values "indigo;crimson;indigo"
                    , Svg.Attributes.keyTimes "0;0.5;1"
                    , Svg.Attributes.calcMode "spline"
                    , Svg.Attributes.keySplines ".5 0 .5 1;.5 0 .5 1"
                    , Svg.Attributes.dur "2s"
                    , Svg.Attributes.repeatCount "indefinite"
                    ]
                    []
                , Svg.animate
                    [ Svg.Attributes.attributeName "r"
                    , Svg.Attributes.values "15;25;15"
                    , Svg.Attributes.keyTimes "0;0.5;1"
                    , Svg.Attributes.calcMode "spline"
                    , Svg.Attributes.keySplines ".5 0 .5 1;.5 0 .5 1"
                    , Svg.Attributes.dur "2s"
                    , Svg.Attributes.repeatCount "indefinite"
                    ]
                    []
                , Svg.animate
                    [ Svg.Attributes.attributeName "cx"
                    , Svg.Attributes.values "30;90;30"
                    , Svg.Attributes.keyTimes "0;0.5;1"
                    , Svg.Attributes.calcMode "spline"
                    , Svg.Attributes.keySplines ".5 0 .5 1;.5 0 .5 1"
                    , Svg.Attributes.dur "2s"
                    , Svg.Attributes.repeatCount "indefinite"
                    ]
                    []
                ]
            , Svg.animate
                [ Svg.Attributes.attributeName "opacity"
                , Svg.Attributes.values "1;0.8;1"
                , Svg.Attributes.keyTimes "0;0.5;1"
                , Svg.Attributes.calcMode "spline"
                , Svg.Attributes.keySplines ".5 0 .5 1;.5 0 .5 1"
                , Svg.Attributes.dur "2s"
                , Svg.Attributes.repeatCount "indefinite"
                ]
                []
            ]
        ]


{-| A group where the number of children changes between frames —
the extra child is toggled with a discrete visibility switch.
-}
appearingChildren : Html msg
appearingChildren =
    svg120
        [ Svg.circle
            [ Svg.Attributes.cx "30", Svg.Attributes.cy "60", Svg.Attributes.r "15", Svg.Attributes.fill "steelblue" ]
            [ Svg.animate
                [ Svg.Attributes.attributeName "r"
                , Svg.Attributes.values "15;20;15"
                , Svg.Attributes.keyTimes "0;0.5;1"
                , Svg.Attributes.calcMode "spline"
                , Svg.Attributes.keySplines ".5 0 .5 1;.5 0 .5 1"
                , Svg.Attributes.dur "2s"
                , Svg.Attributes.repeatCount "indefinite"
                ]
                []
            , Svg.animate
                [ Svg.Attributes.attributeName "cy"
                , Svg.Attributes.values "60;40;60"
                , Svg.Attributes.keyTimes "0;0.5;1"
                , Svg.Attributes.calcMode "spline"
                , Svg.Attributes.keySplines ".5 0 .5 1;.5 0 .5 1"
                , Svg.Attributes.dur "2s"
                , Svg.Attributes.repeatCount "indefinite"
                ]
                []
            ]
        , Svg.circle
            [ Svg.Attributes.cx "60", Svg.Attributes.cy "60", Svg.Attributes.r "15", Svg.Attributes.fill "coral" ]
            [ Svg.animate
                [ Svg.Attributes.attributeName "r"
                , Svg.Attributes.values "15;20;15"
                , Svg.Attributes.keyTimes "0;0.5;1"
                , Svg.Attributes.calcMode "spline"
                , Svg.Attributes.keySplines ".5 0 .5 1;.5 0 .5 1"
                , Svg.Attributes.dur "2s"
                , Svg.Attributes.repeatCount "indefinite"
                ]
                []
            , Svg.animate
                [ Svg.Attributes.attributeName "cy"
                , Svg.Attributes.values "60;40;60"
                , Svg.Attributes.keyTimes "0;0.5;1"
                , Svg.Attributes.calcMode "spline"
                , Svg.Attributes.keySplines ".5 0 .5 1;.5 0 .5 1"
                , Svg.Attributes.dur "2s"
                , Svg.Attributes.repeatCount "indefinite"
                ]
                []
            ]
        , Svg.g [ Svg.Attributes.visibility "hidden" ]
            [ Svg.circle
                [ Svg.Attributes.cx "90", Svg.Attributes.cy "40", Svg.Attributes.r "20", Svg.Attributes.fill "gold" ]
                []
            , Svg.animate
                [ Svg.Attributes.attributeName "visibility"
                , Svg.Attributes.values "hidden;visible"
                , Svg.Attributes.keyTimes "0;0.5"
                , Svg.Attributes.calcMode "discrete"
                , Svg.Attributes.dur "2s"
                , Svg.Attributes.repeatCount "indefinite"
                ]
                []
            ]
        ]
