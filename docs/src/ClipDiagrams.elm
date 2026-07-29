module ClipDiagrams exposing (svgs)

{-| Generates documentation images for the Evg.Clip module.

These are produced with `Evg.toString` itself, so the pictures in the docs
are guaranteed to show what the library actually renders.

-}

import Evg
import Evg.Advanced as Advanced
import Evg.Clip as Clip
import Evg.Paint as Paint


type alias DocSvg =
    { name : String, body : String }


svgs : List DocSvg
svgs =
    [ { name = "clip-example.svg", body = clipSvg }
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


clipSvg : String
clipSvg =
    docImage { width = 120, height = 120 }
        [ Evg.rect
            [ Evg.fill photo
            , Clip.clip (Evg.circle [] { r = 50, center = ( 60, 60 ) })
            ]
            { x = 10, y = 10, width = 100, height = 100 }
        ]
