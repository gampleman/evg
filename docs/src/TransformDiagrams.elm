module TransformDiagrams exposing (svgs)

{-| Generates documentation images for the Evg.Transform module.

Each image shows a before/after pair: the grey shape is the original and
the blue shape is the transformed result.

These are produced with `Evg.toString` itself, so the pictures in the docs
are guaranteed to show what the library actually renders.

-}

import Evg
import Evg.Advanced as Advanced
import Evg.Transform as Transform


type alias DocSvg =
    { name : String, body : String }


svgs : List DocSvg
svgs =
    [ { name = "transform-translate-example.svg", body = translateSvg }
    , { name = "transform-rotate-example.svg", body = rotateSvg }
    , { name = "transform-rotate-around-example.svg", body = rotateAroundSvg }
    , { name = "transform-scale-example.svg", body = scaleSvg }
    , { name = "transform-skew-x-example.svg", body = skewXSvg }
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


translateSvg : String
translateSvg =
    docImage { width = 140, height = 70 }
        [ Evg.rect [ Evg.fillStr "#bbb" ] { x = 10, y = 10, width = 30, height = 30 }
        , Evg.rect [ Evg.fillStr "royalblue", Transform.translate 80 20 ] { x = 10, y = 10, width = 30, height = 30 }
        , Evg.line [ Evg.strokeStr "#888", Evg.strokeWidth 1.5, Evg.dashPattern [ 3, 2 ] ] ( 43, 28 ) ( 85, 38 )
        ]


rotateSvg : String
rotateSvg =
    docImage { width = 140, height = 100 }
        [ Evg.circle [ Evg.fillStr "#333" ] { r = 3, center = ( 0, 0 ) }
        , Evg.rect [ Evg.fillStr "#bbb" ] { x = 70, y = 10, width = 30, height = 30 }
        , Evg.rect [ Evg.fillStr "royalblue", Evg.fillOpacity 0.85, Transform.rotate 30 ] { x = 70, y = 10, width = 30, height = 30 }
        ]


rotateAroundSvg : String
rotateAroundSvg =
    docImage { width = 130, height = 80 }
        [ Evg.rect [ Evg.fillStr "#bbb" ] { x = 45, y = 20, width = 40, height = 40 }
        , Evg.rect [ Evg.fillStr "royalblue", Evg.fillOpacity 0.85, Transform.rotateAround 45 ( 65, 40 ) ] { x = 45, y = 20, width = 40, height = 40 }
        , Evg.circle [ Evg.fillStr "white" ] { r = 2, center = ( 65, 40 ) }
        ]


scaleSvg : String
scaleSvg =
    docImage { width = 140, height = 60 }
        [ Evg.rect [ Evg.fillStr "#bbb" ] { x = 10, y = 10, width = 30, height = 30 }
        , Evg.rect [ Evg.fillStr "royalblue", Evg.fillOpacity 0.7, Transform.scale 2 1 ] { x = 10, y = 10, width = 30, height = 30 }
        ]


skewXSvg : String
skewXSvg =
    docImage { width = 120, height = 70 }
        [ Evg.rect [ Evg.fillStr "#bbb" ] { x = 10, y = 10, width = 40, height = 40 }
        , Evg.rect [ Evg.fillStr "royalblue", Evg.fillOpacity 0.85, Transform.skewX 20 ] { x = 10, y = 10, width = 40, height = 40 }
        ]
