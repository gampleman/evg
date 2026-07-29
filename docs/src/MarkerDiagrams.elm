module MarkerDiagrams exposing (svgs)

{-| Generates documentation images for the Evg.Marker module.

These are produced with `Evg.toString` itself, so the pictures in the docs
are guaranteed to show what the library actually renders.

-}

import Evg
import Evg.Advanced as Advanced
import Evg.Marker as Marker


type alias DocSvg =
    { name : String, body : String }


svgs : List DocSvg
svgs =
    [ { name = "marker-arrow-example.svg", body = arrowSvg }
    , { name = "marker-mid-example.svg", body = midSvg }
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


arrow : Marker.Marker Never
arrow =
    Marker.marker []
        { width = 10, height = 10, refX = 10, refY = 5 }
        Marker.AutoOrientation
        (Evg.polygon [ Evg.fillStr "black" ]
            [ ( 0, 0 ), ( 10, 5 ), ( 0, 10 ) ]
        )


dot : Marker.Marker Never
dot =
    Marker.markerUserSpace []
        { width = 8, height = 8, refX = 4, refY = 4 }
        Marker.AutoOrientation
        (Evg.circle [ Evg.fillStr "crimson" ]
            { r = 4, center = ( 4, 4 ) }
        )


arrowSvg : String
arrowSvg =
    docImage { width = 160, height = 40 }
        [ Evg.line
            [ Evg.strokeStr "black", Evg.strokeWidth 2, Marker.markerEnd arrow ]
            ( 15, 20 )
            ( 145, 20 )
        ]


midSvg : String
midSvg =
    docImage { width = 120, height = 100 }
        [ Evg.polyline
            [ Evg.strokeStr "black", Evg.strokeWidth 2, Marker.markerMid dot ]
            [ ( 15, 15 ), ( 60, 85 ), ( 105, 15 ) ]
        ]
