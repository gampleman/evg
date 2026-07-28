module GaugeTypedSvg exposing (main)

{-| A speedometer-style gauge with tick marks, labels, and a needle.
Implemented with elm-community/typed-svg.
-}

import Color
import Html exposing (Html)
import TypedSvg
import TypedSvg.Attributes
import TypedSvg.Core
import TypedSvg.Types


pointAt : Float -> Float -> ( Float, Float )
pointAt radius fraction =
    let
        rad =
            (180 + fraction * 180) * pi / 180
    in
    ( 200 + radius * cos rad, 200 + radius * sin rad )


main : Html msg
main =
    let
        value =
            0.72

        ( arcEndX, arcEndY ) =
            pointAt 184 value

        ( needleX, needleY ) =
            pointAt 150 value
    in
    TypedSvg.svg
        [ TypedSvg.Attributes.viewBox 0 0 400 220
        , TypedSvg.Attributes.width (TypedSvg.Types.px 400)
        , TypedSvg.Attributes.height (TypedSvg.Types.px 220)
        ]
        [ -- Background arc
          TypedSvg.path
            [ TypedSvg.Attributes.d "M 16 200 A 184 184 0 0 1 384 200"
            , TypedSvg.Attributes.fill TypedSvg.Types.PaintNone
            , TypedSvg.Attributes.stroke (TypedSvg.Types.Paint (Color.rgb255 224 224 224))
            , TypedSvg.Attributes.strokeWidth (TypedSvg.Types.px 16)
            , TypedSvg.Attributes.strokeLinecap TypedSvg.Types.StrokeLinecapRound
            ]
            []

        -- Colored arc (value indicator)
        , TypedSvg.path
            [ TypedSvg.Attributes.d
                ("M 16 200 A 184 184 0 0 1 "
                    ++ String.fromFloat arcEndX
                    ++ " "
                    ++ String.fromFloat arcEndY
                )
            , TypedSvg.Attributes.fill TypedSvg.Types.PaintNone
            , TypedSvg.Attributes.stroke (TypedSvg.Types.Paint (Color.rgb255 76 175 80))
            , TypedSvg.Attributes.strokeWidth (TypedSvg.Types.px 16)
            , TypedSvg.Attributes.strokeLinecap TypedSvg.Types.StrokeLinecapRound
            ]
            []

        -- Tick marks
        , TypedSvg.g []
            (List.map
                (\i ->
                    let
                        ( lx1, ly1 ) =
                            pointAt 160 (toFloat i / 8)

                        ( lx2, ly2 ) =
                            pointAt 178 (toFloat i / 8)
                    in
                    TypedSvg.line
                        [ TypedSvg.Attributes.x1 (TypedSvg.Types.px lx1)
                        , TypedSvg.Attributes.y1 (TypedSvg.Types.px ly1)
                        , TypedSvg.Attributes.x2 (TypedSvg.Types.px lx2)
                        , TypedSvg.Attributes.y2 (TypedSvg.Types.px ly2)
                        , TypedSvg.Attributes.stroke (TypedSvg.Types.Paint (Color.rgb255 102 102 102))
                        , TypedSvg.Attributes.strokeWidth (TypedSvg.Types.px 4)
                        , TypedSvg.Attributes.strokeLinecap TypedSvg.Types.StrokeLinecapRound
                        ]
                        []
                )
                (List.range 0 8)
            )

        -- Needle
        , TypedSvg.line
            [ TypedSvg.Attributes.x1 (TypedSvg.Types.px 200)
            , TypedSvg.Attributes.y1 (TypedSvg.Types.px 200)
            , TypedSvg.Attributes.x2 (TypedSvg.Types.px needleX)
            , TypedSvg.Attributes.y2 (TypedSvg.Types.px needleY)
            , TypedSvg.Attributes.stroke (TypedSvg.Types.Paint (Color.rgb255 211 47 47))
            , TypedSvg.Attributes.strokeWidth (TypedSvg.Types.px 5)
            , TypedSvg.Attributes.strokeLinecap TypedSvg.Types.StrokeLinecapRound
            ]
            []

        -- Center dot
        , TypedSvg.circle
            [ TypedSvg.Attributes.cx (TypedSvg.Types.px 200)
            , TypedSvg.Attributes.cy (TypedSvg.Types.px 200)
            , TypedSvg.Attributes.r (TypedSvg.Types.px 10)
            , TypedSvg.Attributes.fill (TypedSvg.Types.Paint (Color.rgb255 51 51 51))
            ]
            []

        -- Label
        , TypedSvg.text_
            [ TypedSvg.Attributes.x (TypedSvg.Types.px 200)
            , TypedSvg.Attributes.y (TypedSvg.Types.px 170)
            , TypedSvg.Attributes.textAnchor TypedSvg.Types.AnchorMiddle
            , TypedSvg.Attributes.fontSize (TypedSvg.Types.px 24)
            , TypedSvg.Attributes.fill (TypedSvg.Types.Paint (Color.rgb255 102 102 102))
            ]
            [ TypedSvg.Core.text (String.fromInt (round (value * 100)) ++ "%") ]
        ]
