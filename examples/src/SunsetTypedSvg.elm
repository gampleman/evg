module SunsetTypedSvg exposing (main)

{-| A sunset scene with gradient sky, sun, mountains, and water.
Implemented with elm-community/typed-svg.
-}

import Color
import Html exposing (Html)
import TypedSvg
import TypedSvg.Attributes
import TypedSvg.Core
import TypedSvg.Types


main : Html msg
main =
    TypedSvg.svg
        [ TypedSvg.Attributes.viewBox 0 0 400 300
        , TypedSvg.Attributes.width (TypedSvg.Types.px 400)
        , TypedSvg.Attributes.height (TypedSvg.Types.px 300)
        ]
        [ TypedSvg.defs []
            [ TypedSvg.linearGradient
                [ TypedSvg.Attributes.id "sky"
                , TypedSvg.Attributes.x1 (TypedSvg.Types.px 0)
                , TypedSvg.Attributes.y1 (TypedSvg.Types.px 0)
                , TypedSvg.Attributes.x2 (TypedSvg.Types.px 0)
                , TypedSvg.Attributes.y2 (TypedSvg.Types.px 1)
                ]
                [ TypedSvg.stop [ TypedSvg.Attributes.offset "0%", TypedSvg.Attributes.stopColor "#1a0533" ] []
                , TypedSvg.stop [ TypedSvg.Attributes.offset "40%", TypedSvg.Attributes.stopColor "#c2185b" ] []
                , TypedSvg.stop [ TypedSvg.Attributes.offset "70%", TypedSvg.Attributes.stopColor "#ff6f00" ] []
                , TypedSvg.stop [ TypedSvg.Attributes.offset "100%", TypedSvg.Attributes.stopColor "#ffab00" ] []
                ]
            , TypedSvg.radialGradient
                [ TypedSvg.Attributes.id "sun"
                , TypedSvg.Attributes.cx (TypedSvg.Types.percent 50)
                , TypedSvg.Attributes.cy (TypedSvg.Types.percent 50)
                , TypedSvg.Attributes.r (TypedSvg.Types.percent 50)
                ]
                [ TypedSvg.stop [ TypedSvg.Attributes.offset "0%", TypedSvg.Attributes.stopColor "#fff59d" ] []
                , TypedSvg.stop [ TypedSvg.Attributes.offset "80%", TypedSvg.Attributes.stopColor "#ffab00" ] []
                , TypedSvg.stop [ TypedSvg.Attributes.offset "100%", TypedSvg.Attributes.stopColor "#ff6f00", TypedSvg.Attributes.stopOpacity (TypedSvg.Types.Opacity 0) ] []
                ]
            , TypedSvg.linearGradient
                [ TypedSvg.Attributes.id "water"
                , TypedSvg.Attributes.x1 (TypedSvg.Types.px 0)
                , TypedSvg.Attributes.y1 (TypedSvg.Types.px 0)
                , TypedSvg.Attributes.x2 (TypedSvg.Types.px 0)
                , TypedSvg.Attributes.y2 (TypedSvg.Types.px 1)
                ]
                [ TypedSvg.stop [ TypedSvg.Attributes.offset "0%", TypedSvg.Attributes.stopColor "#ff6f00", TypedSvg.Attributes.stopOpacity (TypedSvg.Types.Opacity 0.6) ] []
                , TypedSvg.stop [ TypedSvg.Attributes.offset "100%", TypedSvg.Attributes.stopColor "#0d47a1" ] []
                ]
            ]
        , -- Sky
          TypedSvg.rect
            [ TypedSvg.Attributes.width (TypedSvg.Types.px 400)
            , TypedSvg.Attributes.height (TypedSvg.Types.px 300)
            , TypedSvg.Attributes.fill (TypedSvg.Types.Reference "sky")
            ]
            []
        , -- Sun
          TypedSvg.circle
            [ TypedSvg.Attributes.cx (TypedSvg.Types.px 200)
            , TypedSvg.Attributes.cy (TypedSvg.Types.px 180)
            , TypedSvg.Attributes.r (TypedSvg.Types.px 60)
            , TypedSvg.Attributes.fill (TypedSvg.Types.Reference "sun")
            ]
            []
        , -- Mountains
          TypedSvg.polygon
            [ TypedSvg.Attributes.points [ ( 0, 220 ), ( 80, 140 ), ( 160, 220 ) ]
            , TypedSvg.Attributes.fill (TypedSvg.Types.Paint (Color.rgb255 26 35 126))
            , TypedSvg.Attributes.opacity (TypedSvg.Types.Opacity 0.8)
            ]
            []
        , TypedSvg.polygon
            [ TypedSvg.Attributes.points [ ( 120, 220 ), ( 220, 120 ), ( 320, 220 ) ]
            , TypedSvg.Attributes.fill (TypedSvg.Types.Paint (Color.rgb255 40 53 147))
            , TypedSvg.Attributes.opacity (TypedSvg.Types.Opacity 0.7)
            ]
            []
        , TypedSvg.polygon
            [ TypedSvg.Attributes.points [ ( 280, 220 ), ( 360, 150 ), ( 440, 220 ) ]
            , TypedSvg.Attributes.fill (TypedSvg.Types.Paint (Color.rgb255 26 35 126))
            , TypedSvg.Attributes.opacity (TypedSvg.Types.Opacity 0.8)
            ]
            []
        , -- Water
          TypedSvg.rect
            [ TypedSvg.Attributes.y (TypedSvg.Types.px 220)
            , TypedSvg.Attributes.width (TypedSvg.Types.px 400)
            , TypedSvg.Attributes.height (TypedSvg.Types.px 80)
            , TypedSvg.Attributes.fill (TypedSvg.Types.Reference "water")
            ]
            []
        , -- Sun reflection on water
          TypedSvg.ellipse
            [ TypedSvg.Attributes.cx (TypedSvg.Types.px 200)
            , TypedSvg.Attributes.cy (TypedSvg.Types.px 260)
            , TypedSvg.Attributes.rx (TypedSvg.Types.px 40)
            , TypedSvg.Attributes.ry (TypedSvg.Types.px 15)
            , TypedSvg.Attributes.fill (TypedSvg.Types.Paint (Color.rgb255 255 171 0))
            , TypedSvg.Attributes.opacity (TypedSvg.Types.Opacity 0.4)
            ]
            []
        ]
