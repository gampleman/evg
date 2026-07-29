module MaskDiagrams exposing (svgs)

{-| Generates documentation images for the Evg.Mask module.

These are produced with `Evg.toString` itself, so the pictures in the docs
are guaranteed to show what the library actually renders.

-}

import Color
import Evg
import Evg.Advanced as Advanced
import Evg.Clip as Clip
import Evg.Mask as Mask
import Evg.Paint as Paint
import Evg.Transform as Transform


type alias DocSvg =
    { name : String, body : String }


svgs : List DocSvg
svgs =
    [ { name = "clip-vs-mask-example.svg", body = clipVsMaskSvg }
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


photo : Paint.Paint
photo =
    Paint.linearGradient ( 0, 0 )
        ( 1, 1 )
        [ Paint.stopStr 0 "#ff8c00"
        , Paint.stopStr 0.5 "#e0407b"
        , Paint.stopStr 1 "#4b0082"
        ]


softCircle : Evg.Evg Never
softCircle =
    Evg.circle
        [ Evg.fill
            (Paint.radialGradient ( 0.5, 0.5 )
                0.5
                [ Paint.stop 0 (Color.rgb255 255 255 255)
                , Paint.stop 0.6 (Color.rgb255 255 255 255)
                , Paint.stop 1 (Color.rgb255 0 0 0)
                ]
            )
        ]
        { r = 40, center = ( 50, 50 ) }


clipVsMaskSvg : String
clipVsMaskSvg =
    docImage { width = 210, height = 100 }
        [ Evg.rect
            [ Evg.fill photo
            , Clip.clip (Evg.circle [] { r = 40, center = ( 50, 50 ) })
            ]
            { x = 10, y = 10, width = 80, height = 80 }
        , Evg.group [ Transform.translate 110 0 ]
            [ Evg.rect
                [ Evg.fill photo
                , Mask.luminance softCircle
                ]
                { x = 10, y = 10, width = 80, height = 80 }
            ]
        ]
