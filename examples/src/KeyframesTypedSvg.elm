module KeyframesTypedSvg exposing (main)

{-| Keyframe-style animations hand-written in raw SMIL — typed-svg version.
Mirrors the scenarios from KeyframesEvg: attribute interpolation, shape
morphing via visibility switching, position interpolation, group animation,
and children that appear and disappear.
-}

import Html exposing (Html)
import TypedSvg
import TypedSvg.Attributes
import TypedSvg.Core exposing (Svg)
import TypedSvg.Types


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
    TypedSvg.svg
        [ TypedSvg.Attributes.viewBox 0 0 120 120
        , TypedSvg.Attributes.width (TypedSvg.Types.px 120)
        , TypedSvg.Attributes.height (TypedSvg.Types.px 120)
        ]


{-| Simple pulsing: radius and opacity change
-}
pulsingCircle : Html msg
pulsingCircle =
    svg120
        [ TypedSvg.circle
            [ TypedSvg.Attributes.cx (TypedSvg.Types.px 60)
            , TypedSvg.Attributes.cy (TypedSvg.Types.px 60)
            , TypedSvg.Attributes.r (TypedSvg.Types.px 20)
            , TypedSvg.Core.attribute "fill" "tomato"
            ]
            [ TypedSvg.animate
                [ TypedSvg.Attributes.attributeName "r"
                , TypedSvg.Core.attribute "values" "20;50;20"
                , TypedSvg.Attributes.keyTimes [ 0, 0.5, 1 ]
                , TypedSvg.Attributes.calcMode TypedSvg.Types.CalcModeSpline
                , TypedSvg.Attributes.keySplines [ { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 }, { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 } ]
                , TypedSvg.Core.attribute "dur" "2s"
                , TypedSvg.Attributes.repeatCount TypedSvg.Types.RepeatIndefinite
                ]
                []
            , TypedSvg.animate
                [ TypedSvg.Attributes.attributeName "opacity"
                , TypedSvg.Core.attribute "values" "1;0.4;1"
                , TypedSvg.Attributes.keyTimes [ 0, 0.5, 1 ]
                , TypedSvg.Attributes.calcMode TypedSvg.Types.CalcModeSpline
                , TypedSvg.Attributes.keySplines [ { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 }, { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 } ]
                , TypedSvg.Core.attribute "dur" "2s"
                , TypedSvg.Attributes.repeatCount TypedSvg.Types.RepeatIndefinite
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
        [ TypedSvg.g [ TypedSvg.Core.attribute "visibility" "hidden" ]
            [ TypedSvg.circle
                [ TypedSvg.Attributes.cx (TypedSvg.Types.px 60)
                , TypedSvg.Attributes.cy (TypedSvg.Types.px 60)
                , TypedSvg.Attributes.r (TypedSvg.Types.px 20)
                , TypedSvg.Core.attribute "fill" "royalblue"
                ]
                [ TypedSvg.animate
                    [ TypedSvg.Attributes.attributeName "r"
                    , TypedSvg.Core.attribute "values" "20;40;40"
                    , TypedSvg.Attributes.keyTimes [ 0, 0.25, 1 ]
                    , TypedSvg.Attributes.calcMode TypedSvg.Types.CalcModeSpline
                    , TypedSvg.Attributes.keySplines [ { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 }, { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 } ]
                    , TypedSvg.Core.attribute "dur" "4s"
                    , TypedSvg.Attributes.repeatCount TypedSvg.Types.RepeatIndefinite
                    ]
                    []
                , TypedSvg.animate
                    [ TypedSvg.Attributes.attributeName "fill"
                    , TypedSvg.Core.attribute "values" "royalblue;dodgerblue;dodgerblue"
                    , TypedSvg.Attributes.keyTimes [ 0, 0.25, 1 ]
                    , TypedSvg.Attributes.calcMode TypedSvg.Types.CalcModeSpline
                    , TypedSvg.Attributes.keySplines [ { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 }, { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 } ]
                    , TypedSvg.Core.attribute "dur" "4s"
                    , TypedSvg.Attributes.repeatCount TypedSvg.Types.RepeatIndefinite
                    ]
                    []
                ]
            , TypedSvg.animate
                [ TypedSvg.Attributes.attributeName "visibility"
                , TypedSvg.Core.attribute "values" "visible;hidden"
                , TypedSvg.Attributes.keyTimes [ 0, 0.5 ]
                , TypedSvg.Attributes.calcMode TypedSvg.Types.CalcModeDiscrete
                , TypedSvg.Core.attribute "dur" "4s"
                , TypedSvg.Attributes.repeatCount TypedSvg.Types.RepeatIndefinite
                ]
                []
            ]
        , TypedSvg.g [ TypedSvg.Core.attribute "visibility" "hidden" ]
            [ TypedSvg.rect
                [ TypedSvg.Attributes.x (TypedSvg.Types.px 20)
                , TypedSvg.Attributes.y (TypedSvg.Types.px 20)
                , TypedSvg.Attributes.width (TypedSvg.Types.px 80)
                , TypedSvg.Attributes.height (TypedSvg.Types.px 80)
                , TypedSvg.Core.attribute "fill" "limegreen"
                ]
                [ TypedSvg.animate
                    [ TypedSvg.Attributes.attributeName "x"
                    , TypedSvg.Core.attribute "values" "20;20;30;30"
                    , TypedSvg.Attributes.keyTimes [ 0, 0.5, 0.75, 1 ]
                    , TypedSvg.Attributes.calcMode TypedSvg.Types.CalcModeSpline
                    , TypedSvg.Attributes.keySplines [ { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 }, { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 }, { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 } ]
                    , TypedSvg.Core.attribute "dur" "4s"
                    , TypedSvg.Attributes.repeatCount TypedSvg.Types.RepeatIndefinite
                    ]
                    []
                , TypedSvg.animate
                    [ TypedSvg.Attributes.attributeName "y"
                    , TypedSvg.Core.attribute "values" "20;20;30;30"
                    , TypedSvg.Attributes.keyTimes [ 0, 0.5, 0.75, 1 ]
                    , TypedSvg.Attributes.calcMode TypedSvg.Types.CalcModeSpline
                    , TypedSvg.Attributes.keySplines [ { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 }, { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 }, { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 } ]
                    , TypedSvg.Core.attribute "dur" "4s"
                    , TypedSvg.Attributes.repeatCount TypedSvg.Types.RepeatIndefinite
                    ]
                    []
                , TypedSvg.animate
                    [ TypedSvg.Attributes.attributeName "width"
                    , TypedSvg.Core.attribute "values" "80;80;60;60"
                    , TypedSvg.Attributes.keyTimes [ 0, 0.5, 0.75, 1 ]
                    , TypedSvg.Attributes.calcMode TypedSvg.Types.CalcModeSpline
                    , TypedSvg.Attributes.keySplines [ { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 }, { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 }, { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 } ]
                    , TypedSvg.Core.attribute "dur" "4s"
                    , TypedSvg.Attributes.repeatCount TypedSvg.Types.RepeatIndefinite
                    ]
                    []
                , TypedSvg.animate
                    [ TypedSvg.Attributes.attributeName "height"
                    , TypedSvg.Core.attribute "values" "80;80;60;60"
                    , TypedSvg.Attributes.keyTimes [ 0, 0.5, 0.75, 1 ]
                    , TypedSvg.Attributes.calcMode TypedSvg.Types.CalcModeSpline
                    , TypedSvg.Attributes.keySplines [ { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 }, { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 }, { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 } ]
                    , TypedSvg.Core.attribute "dur" "4s"
                    , TypedSvg.Attributes.repeatCount TypedSvg.Types.RepeatIndefinite
                    ]
                    []
                , TypedSvg.animate
                    [ TypedSvg.Attributes.attributeName "fill"
                    , TypedSvg.Core.attribute "values" "limegreen;limegreen;forestgreen;forestgreen"
                    , TypedSvg.Attributes.keyTimes [ 0, 0.5, 0.75, 1 ]
                    , TypedSvg.Attributes.calcMode TypedSvg.Types.CalcModeSpline
                    , TypedSvg.Attributes.keySplines [ { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 }, { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 }, { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 } ]
                    , TypedSvg.Core.attribute "dur" "4s"
                    , TypedSvg.Attributes.repeatCount TypedSvg.Types.RepeatIndefinite
                    ]
                    []
                ]
            , TypedSvg.animate
                [ TypedSvg.Attributes.attributeName "visibility"
                , TypedSvg.Core.attribute "values" "hidden;visible"
                , TypedSvg.Attributes.keyTimes [ 0, 0.5 ]
                , TypedSvg.Attributes.calcMode TypedSvg.Types.CalcModeDiscrete
                , TypedSvg.Core.attribute "dur" "4s"
                , TypedSvg.Attributes.repeatCount TypedSvg.Types.RepeatIndefinite
                ]
                []
            ]
        ]


{-| A dot that moves in a square path
-}
movingDot : Html msg
movingDot =
    svg120
        [ TypedSvg.circle
            [ TypedSvg.Attributes.cx (TypedSvg.Types.px 20)
            , TypedSvg.Attributes.cy (TypedSvg.Types.px 20)
            , TypedSvg.Attributes.r (TypedSvg.Types.px 8)
            , TypedSvg.Core.attribute "fill" "hotpink"
            ]
            [ TypedSvg.animate
                [ TypedSvg.Attributes.attributeName "cx"
                , TypedSvg.Core.attribute "values" "20;100;100;20;20"
                , TypedSvg.Attributes.keyTimes [ 0, 0.25, 0.5, 0.75, 1 ]
                , TypedSvg.Attributes.calcMode TypedSvg.Types.CalcModeSpline
                , TypedSvg.Attributes.keySplines [ { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 }, { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 }, { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 }, { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 } ]
                , TypedSvg.Core.attribute "dur" "2s"
                , TypedSvg.Attributes.repeatCount TypedSvg.Types.RepeatIndefinite
                ]
                []
            , TypedSvg.animate
                [ TypedSvg.Attributes.attributeName "cy"
                , TypedSvg.Core.attribute "values" "20;20;100;100;20"
                , TypedSvg.Attributes.keyTimes [ 0, 0.25, 0.5, 0.75, 1 ]
                , TypedSvg.Attributes.calcMode TypedSvg.Types.CalcModeSpline
                , TypedSvg.Attributes.keySplines [ { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 }, { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 }, { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 }, { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 } ]
                , TypedSvg.Core.attribute "dur" "2s"
                , TypedSvg.Attributes.repeatCount TypedSvg.Types.RepeatIndefinite
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
        [ TypedSvg.g []
            [ TypedSvg.rect
                [ TypedSvg.Attributes.x (TypedSvg.Types.px 10)
                , TypedSvg.Attributes.y (TypedSvg.Types.px 10)
                , TypedSvg.Attributes.width (TypedSvg.Types.px 100)
                , TypedSvg.Attributes.height (TypedSvg.Types.px 100)
                , TypedSvg.Core.attribute "fill" "lavender"
                ]
                [ TypedSvg.animate
                    [ TypedSvg.Attributes.attributeName "fill"
                    , TypedSvg.Core.attribute "values" "lavender;mistyrose;lavender"
                    , TypedSvg.Attributes.keyTimes [ 0, 0.5, 1 ]
                    , TypedSvg.Attributes.calcMode TypedSvg.Types.CalcModeSpline
                    , TypedSvg.Attributes.keySplines [ { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 }, { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 } ]
                    , TypedSvg.Core.attribute "dur" "2s"
                    , TypedSvg.Attributes.repeatCount TypedSvg.Types.RepeatIndefinite
                    ]
                    []
                ]
            , TypedSvg.circle
                [ TypedSvg.Attributes.cx (TypedSvg.Types.px 30)
                , TypedSvg.Attributes.cy (TypedSvg.Types.px 60)
                , TypedSvg.Attributes.r (TypedSvg.Types.px 15)
                , TypedSvg.Core.attribute "fill" "indigo"
                ]
                [ TypedSvg.animate
                    [ TypedSvg.Attributes.attributeName "fill"
                    , TypedSvg.Core.attribute "values" "indigo;crimson;indigo"
                    , TypedSvg.Attributes.keyTimes [ 0, 0.5, 1 ]
                    , TypedSvg.Attributes.calcMode TypedSvg.Types.CalcModeSpline
                    , TypedSvg.Attributes.keySplines [ { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 }, { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 } ]
                    , TypedSvg.Core.attribute "dur" "2s"
                    , TypedSvg.Attributes.repeatCount TypedSvg.Types.RepeatIndefinite
                    ]
                    []
                , TypedSvg.animate
                    [ TypedSvg.Attributes.attributeName "r"
                    , TypedSvg.Core.attribute "values" "15;25;15"
                    , TypedSvg.Attributes.keyTimes [ 0, 0.5, 1 ]
                    , TypedSvg.Attributes.calcMode TypedSvg.Types.CalcModeSpline
                    , TypedSvg.Attributes.keySplines [ { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 }, { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 } ]
                    , TypedSvg.Core.attribute "dur" "2s"
                    , TypedSvg.Attributes.repeatCount TypedSvg.Types.RepeatIndefinite
                    ]
                    []
                , TypedSvg.animate
                    [ TypedSvg.Attributes.attributeName "cx"
                    , TypedSvg.Core.attribute "values" "30;90;30"
                    , TypedSvg.Attributes.keyTimes [ 0, 0.5, 1 ]
                    , TypedSvg.Attributes.calcMode TypedSvg.Types.CalcModeSpline
                    , TypedSvg.Attributes.keySplines [ { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 }, { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 } ]
                    , TypedSvg.Core.attribute "dur" "2s"
                    , TypedSvg.Attributes.repeatCount TypedSvg.Types.RepeatIndefinite
                    ]
                    []
                ]
            , TypedSvg.animate
                [ TypedSvg.Attributes.attributeName "opacity"
                , TypedSvg.Core.attribute "values" "1;0.8;1"
                , TypedSvg.Attributes.keyTimes [ 0, 0.5, 1 ]
                , TypedSvg.Attributes.calcMode TypedSvg.Types.CalcModeSpline
                , TypedSvg.Attributes.keySplines [ { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 }, { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 } ]
                , TypedSvg.Core.attribute "dur" "2s"
                , TypedSvg.Attributes.repeatCount TypedSvg.Types.RepeatIndefinite
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
        [ TypedSvg.circle
            [ TypedSvg.Attributes.cx (TypedSvg.Types.px 30)
            , TypedSvg.Attributes.cy (TypedSvg.Types.px 60)
            , TypedSvg.Attributes.r (TypedSvg.Types.px 15)
            , TypedSvg.Core.attribute "fill" "steelblue"
            ]
            [ TypedSvg.animate
                [ TypedSvg.Attributes.attributeName "r"
                , TypedSvg.Core.attribute "values" "15;20;15"
                , TypedSvg.Attributes.keyTimes [ 0, 0.5, 1 ]
                , TypedSvg.Attributes.calcMode TypedSvg.Types.CalcModeSpline
                , TypedSvg.Attributes.keySplines [ { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 }, { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 } ]
                , TypedSvg.Core.attribute "dur" "2s"
                , TypedSvg.Attributes.repeatCount TypedSvg.Types.RepeatIndefinite
                ]
                []
            , TypedSvg.animate
                [ TypedSvg.Attributes.attributeName "cy"
                , TypedSvg.Core.attribute "values" "60;40;60"
                , TypedSvg.Attributes.keyTimes [ 0, 0.5, 1 ]
                , TypedSvg.Attributes.calcMode TypedSvg.Types.CalcModeSpline
                , TypedSvg.Attributes.keySplines [ { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 }, { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 } ]
                , TypedSvg.Core.attribute "dur" "2s"
                , TypedSvg.Attributes.repeatCount TypedSvg.Types.RepeatIndefinite
                ]
                []
            ]
        , TypedSvg.circle
            [ TypedSvg.Attributes.cx (TypedSvg.Types.px 60)
            , TypedSvg.Attributes.cy (TypedSvg.Types.px 60)
            , TypedSvg.Attributes.r (TypedSvg.Types.px 15)
            , TypedSvg.Core.attribute "fill" "coral"
            ]
            [ TypedSvg.animate
                [ TypedSvg.Attributes.attributeName "r"
                , TypedSvg.Core.attribute "values" "15;20;15"
                , TypedSvg.Attributes.keyTimes [ 0, 0.5, 1 ]
                , TypedSvg.Attributes.calcMode TypedSvg.Types.CalcModeSpline
                , TypedSvg.Attributes.keySplines [ { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 }, { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 } ]
                , TypedSvg.Core.attribute "dur" "2s"
                , TypedSvg.Attributes.repeatCount TypedSvg.Types.RepeatIndefinite
                ]
                []
            , TypedSvg.animate
                [ TypedSvg.Attributes.attributeName "cy"
                , TypedSvg.Core.attribute "values" "60;40;60"
                , TypedSvg.Attributes.keyTimes [ 0, 0.5, 1 ]
                , TypedSvg.Attributes.calcMode TypedSvg.Types.CalcModeSpline
                , TypedSvg.Attributes.keySplines [ { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 }, { x1 = 0.5, y1 = 0, x2 = 0.5, y2 = 1 } ]
                , TypedSvg.Core.attribute "dur" "2s"
                , TypedSvg.Attributes.repeatCount TypedSvg.Types.RepeatIndefinite
                ]
                []
            ]
        , TypedSvg.g [ TypedSvg.Core.attribute "visibility" "hidden" ]
            [ TypedSvg.circle
                [ TypedSvg.Attributes.cx (TypedSvg.Types.px 90)
                , TypedSvg.Attributes.cy (TypedSvg.Types.px 40)
                , TypedSvg.Attributes.r (TypedSvg.Types.px 20)
                , TypedSvg.Core.attribute "fill" "gold"
                ]
                []
            , TypedSvg.animate
                [ TypedSvg.Attributes.attributeName "visibility"
                , TypedSvg.Core.attribute "values" "hidden;visible"
                , TypedSvg.Attributes.keyTimes [ 0, 0.5 ]
                , TypedSvg.Attributes.calcMode TypedSvg.Types.CalcModeDiscrete
                , TypedSvg.Core.attribute "dur" "2s"
                , TypedSvg.Attributes.repeatCount TypedSvg.Types.RepeatIndefinite
                ]
                []
            ]
        ]
