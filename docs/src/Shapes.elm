module Shapes exposing (svgs)

{-| Generates documentation images for basic shape functions.

These are produced with `Evg.toString` itself, so the pictures in the docs
are guaranteed to show what the library actually renders.

-}

import Evg
import Evg.Advanced as Advanced


type alias DocSvg =
    { name : String, body : String }


svgs : List DocSvg
svgs =
    [ { name = "line.svg", body = lineSvg }
    , { name = "rect-example.svg", body = rectSvg }
    , { name = "circle-example.svg", body = circleSvg }
    , { name = "ellipse-example.svg", body = ellipseSvg }
    , { name = "polygon-example.svg", body = polygonSvg }
    , { name = "polyline-example.svg", body = polylineSvg }
    ]


{-| Render at double display size: the width/height attributes are twice the
viewBox, keeping the drawing coordinates unchanged.
-}
docImage : { width : Float, height : Float } -> List (Evg.Evg Never) -> String
docImage dims children =
    Evg.toString
        [ Advanced.viewBox 0 0 dims.width dims.height ]
        { width = dims.width * 2, height = dims.height * 2 }
        children


lineSvg : String
lineSvg =
    docImage { width = 120, height = 40 }
        [ Evg.line [ Evg.strokeWidth 2 ] ( 10, 20 ) ( 110, 20 )
        , Evg.circle [ Evg.fillStr "#666" ] { r = 3, center = ( 10, 20 ) }
        , Evg.circle [ Evg.fillStr "#666" ] { r = 3, center = ( 110, 20 ) }
        ]


rectSvg : String
rectSvg =
    docImage { width = 120, height = 80 }
        [ Evg.rect [ Evg.fillStr "navy" ] { x = 10, y = 10, width = 100, height = 60 } ]


circleSvg : String
circleSvg =
    docImage { width = 100, height = 100 }
        [ Evg.circle [ Evg.fillStr "crimson" ] { r = 40, center = ( 50, 50 ) } ]


ellipseSvg : String
ellipseSvg =
    docImage { width = 160, height = 100 }
        [ Evg.ellipse [ Evg.fillStr "mediumpurple" ] { rx = 70, ry = 35, center = ( 80, 50 ) } ]


polygonSvg : String
polygonSvg =
    docImage { width = 120, height = 110 }
        [ Evg.polygon [ Evg.fillStr "limegreen" ]
            [ ( 60, 10 ), ( 110, 100 ), ( 10, 100 ) ]
        ]


polylineSvg : String
polylineSvg =
    docImage { width = 120, height = 60 }
        [ Evg.polyline [ Evg.strokeWidth 2 ]
            [ ( 10, 50 ), ( 30, 10 ), ( 50, 40 ), ( 70, 20 ), ( 90, 45 ), ( 110, 15 ) ]
        ]
