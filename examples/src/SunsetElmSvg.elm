module SunsetElmSvg exposing (main)

{-| A sunset scene with gradient sky, sun, mountains, and water.
Implemented with elm/svg.
-}

import Html exposing (Html)
import Svg exposing (Svg)
import Svg.Attributes


main : Html msg
main =
    Svg.svg
        [ Svg.Attributes.viewBox "0 0 400 300"
        , Svg.Attributes.width "400"
        , Svg.Attributes.height "300"
        ]
        [ Svg.defs []
            [ Svg.linearGradient
                [ Svg.Attributes.id "sky"
                , Svg.Attributes.x1 "0"
                , Svg.Attributes.y1 "0"
                , Svg.Attributes.x2 "0"
                , Svg.Attributes.y2 "1"
                ]
                [ Svg.stop [ Svg.Attributes.offset "0%", Svg.Attributes.stopColor "#1a0533" ] []
                , Svg.stop [ Svg.Attributes.offset "40%", Svg.Attributes.stopColor "#c2185b" ] []
                , Svg.stop [ Svg.Attributes.offset "70%", Svg.Attributes.stopColor "#ff6f00" ] []
                , Svg.stop [ Svg.Attributes.offset "100%", Svg.Attributes.stopColor "#ffab00" ] []
                ]
            , Svg.radialGradient
                [ Svg.Attributes.id "sun"
                , Svg.Attributes.cx "50%"
                , Svg.Attributes.cy "50%"
                , Svg.Attributes.r "50%"
                ]
                [ Svg.stop [ Svg.Attributes.offset "0%", Svg.Attributes.stopColor "#fff59d" ] []
                , Svg.stop [ Svg.Attributes.offset "80%", Svg.Attributes.stopColor "#ffab00" ] []
                , Svg.stop [ Svg.Attributes.offset "100%", Svg.Attributes.stopColor "#ff6f00", Svg.Attributes.stopOpacity "0" ] []
                ]
            , Svg.linearGradient
                [ Svg.Attributes.id "water"
                , Svg.Attributes.x1 "0"
                , Svg.Attributes.y1 "0"
                , Svg.Attributes.x2 "0"
                , Svg.Attributes.y2 "1"
                ]
                [ Svg.stop [ Svg.Attributes.offset "0%", Svg.Attributes.stopColor "#ff6f00", Svg.Attributes.stopOpacity "0.6" ] []
                , Svg.stop [ Svg.Attributes.offset "100%", Svg.Attributes.stopColor "#0d47a1" ] []
                ]
            ]
        , -- Sky
          Svg.rect
            [ Svg.Attributes.width "400"
            , Svg.Attributes.height "300"
            , Svg.Attributes.fill "url(#sky)"
            ]
            []
        , -- Sun
          Svg.circle
            [ Svg.Attributes.cx "200"
            , Svg.Attributes.cy "180"
            , Svg.Attributes.r "60"
            , Svg.Attributes.fill "url(#sun)"
            ]
            []
        , -- Mountains
          Svg.polygon
            [ Svg.Attributes.points "0,220 80,140 160,220"
            , Svg.Attributes.fill "#1a237e"
            , Svg.Attributes.opacity "0.8"
            ]
            []
        , Svg.polygon
            [ Svg.Attributes.points "120,220 220,120 320,220"
            , Svg.Attributes.fill "#283593"
            , Svg.Attributes.opacity "0.7"
            ]
            []
        , Svg.polygon
            [ Svg.Attributes.points "280,220 360,150 440,220"
            , Svg.Attributes.fill "#1a237e"
            , Svg.Attributes.opacity "0.8"
            ]
            []
        , -- Water
          Svg.rect
            [ Svg.Attributes.y "220"
            , Svg.Attributes.width "400"
            , Svg.Attributes.height "80"
            , Svg.Attributes.fill "url(#water)"
            ]
            []
        , -- Sun reflection on water
          Svg.ellipse
            [ Svg.Attributes.cx "200"
            , Svg.Attributes.cy "260"
            , Svg.Attributes.rx "40"
            , Svg.Attributes.ry "15"
            , Svg.Attributes.fill "#ffab00"
            , Svg.Attributes.opacity "0.4"
            ]
            []
        ]
