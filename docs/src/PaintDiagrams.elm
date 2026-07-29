module PaintDiagrams exposing (svgs)

{-| Generates documentation images for the Evg.Paint module.

These are produced with `Evg.toString` itself, so the pictures in the docs
are guaranteed to show what the library actually renders.

-}

import Color
import Evg
import Evg.Advanced as Advanced
import Evg.Paint as Paint


type alias DocSvg =
    { name : String, body : String }


svgs : List DocSvg
svgs =
    [ { name = "linear-gradient-example.svg", body = linearGradientSvg }
    , { name = "linear-gradient-diagonal-example.svg", body = linearGradientDiagonalSvg }
    , { name = "radial-gradient-example.svg", body = radialGradientSvg }
    , { name = "pattern-dots-example.svg", body = patternDotsSvg }
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


linearGradientSvg : String
linearGradientSvg =
    docImage { width = 120, height = 60 }
        [ Evg.rect
            [ Evg.fill
                (Paint.linearGradient ( 0, 0 )
                    ( 1, 0 )
                    [ Paint.stop 0 (Color.rgb255 255 255 0)
                    , Paint.stop 1 (Color.rgb255 255 0 0)
                    ]
                )
            ]
            { x = 0, y = 0, width = 120, height = 60 }
        ]


linearGradientDiagonalSvg : String
linearGradientDiagonalSvg =
    docImage { width = 120, height = 60 }
        [ Evg.rect
            [ Evg.fill
                (Paint.linearGradient ( 0, 0 )
                    ( 1, 1 )
                    [ Paint.stop 0 (Color.rgb255 0 0 255)
                    , Paint.stop 1 (Color.rgb255 255 0 255)
                    ]
                )
            ]
            { x = 0, y = 0, width = 120, height = 60 }
        ]


radialGradientSvg : String
radialGradientSvg =
    docImage { width = 100, height = 100 }
        [ Evg.rect
            [ Evg.fill
                (Paint.radialGradient ( 0.5, 0.5 )
                    0.5
                    [ Paint.stop 0 (Color.rgb255 255 255 255)
                    , Paint.stop 1 (Color.rgb255 0 0 0)
                    ]
                )
            ]
            { x = 0, y = 0, width = 100, height = 100 }
        ]


patternDotsSvg : String
patternDotsSvg =
    docImage { width = 120, height = 60 }
        [ Evg.rect
            [ Evg.fill
                (Paint.pattern [ Advanced.viewBox 0 0 10 10 ]
                    { width = 10, height = 10 }
                    [ Evg.rect [ Evg.fillStr "white" ]
                        { x = 0, y = 0, width = 10, height = 10 }
                    , Evg.circle [ Evg.fillStr "red" ]
                        { r = 3, center = ( 5, 5 ) }
                    ]
                )
            , Evg.strokeStr "#999"
            , Evg.strokeWidth 1
            ]
            { x = 0, y = 0, width = 120, height = 60 }
        ]
