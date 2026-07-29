module ViewportDiagrams exposing (svgs)

{-| Generates documentation images for viewport control functions.

These are produced with `Evg.toString` itself, so the pictures in the docs
are guaranteed to show what the library actually renders.

-}

import Evg
import Evg.Advanced as Advanced


type alias DocSvg =
    { name : String, body : String }


svgs : List DocSvg
svgs =
    [ { name = "preserve-aspect-ratio.svg", body = preserveAspectRatioSvg }
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


{-| The wide landscape scene shown inside each viewport.
-}
scene : List (Evg.Evg Never)
scene =
    [ Evg.rect [ Evg.fillStr "#bcd9ef" ] { x = 0, y = 0, width = 200, height = 100 }
    , Evg.circle [ Evg.fillStr "#f6c344" ] { r = 18, center = ( 150, 30 ) }
    , Evg.polygon [ Evg.fillStr "#5b8c5a" ] [ ( 0, 100 ), ( 60, 40 ), ( 120, 100 ) ]
    , Evg.polygon [ Evg.fillStr "#3f6f3e" ] [ ( 80, 100 ), ( 150, 55 ), ( 200, 100 ) ]
    ]


panel : Float -> Advanced.MeetOrSlice -> Float -> String -> Evg.Evg Never
panel x meetOrSlice labelX label =
    Evg.group []
        [ Evg.rect [ Evg.fillStr "#f2f2f2", Evg.strokeStr "#999", Evg.strokeWidth 1 ]
            { x = x, y = 10, width = 130, height = 130 }
        , Advanced.nestedSvg
            [ Advanced.viewBox 0 0 200 100
            , Advanced.preserveAspectRatio Advanced.XMidYMid meetOrSlice
            ]
            { x = x, y = 10, width = 130, height = 130 }
            scene
        , Evg.text
            [ Evg.fontFamily "sans-serif", Evg.fontSize 13, Evg.fillStr "#333" ]
            { x = labelX, y = 160, anchor = Evg.Middle }
            label
        ]


{-| Two square viewports showing the same wide drawing (a landscape scene)
rendered with Meet (letterboxed) and Slice (cropped).
-}
preserveAspectRatioSvg : String
preserveAspectRatioSvg =
    docImage { width = 320, height = 180 }
        [ panel 10 Advanced.Meet 75 "Meet"
        , panel 180 Advanced.Slice 245 "Slice"
        ]
