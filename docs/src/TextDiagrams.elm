module TextDiagrams exposing (svgs)

{-| Generates documentation diagrams for text layout.

These are produced with `Evg.toString` itself, so the pictures in the docs
are guaranteed to show what the library actually renders.

-}

import Evg
import Evg.Advanced as Advanced
import Evg.Path exposing (Path(..), PathSegment(..))
import Evg.Text as Text


type alias DocSvg =
    { name : String, body : String }


svgs : List DocSvg
svgs =
    [ { name = "text-anchors.svg", body = anchors }
    , { name = "text-on-path.svg", body = textOnPath }
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


anchors : String
anchors =
    docImage { width = 200, height = 100 }
        [ Evg.line
            [ Evg.strokeStr "#ccc", Evg.strokeWidth 1, Evg.dashPattern [ 3, 2 ] ]
            ( 100, 5 )
            ( 100, 95 )
        , Evg.circle [ Evg.fillStr "#e53935" ] { r = 3, center = ( 100, 25 ) }
        , Evg.text [ Evg.fontSize 12, Evg.fillStr "#333" ]
            { x = 100, y = 29, anchor = Evg.Start }
            "Start"
        , Evg.circle [ Evg.fillStr "#e53935" ] { r = 3, center = ( 100, 55 ) }
        , Evg.text [ Evg.fontSize 12, Evg.fillStr "#333" ]
            { x = 100, y = 59, anchor = Evg.Middle }
            "Middle"
        , Evg.circle [ Evg.fillStr "#e53935" ] { r = 3, center = ( 100, 85 ) }
        , Evg.text [ Evg.fontSize 12, Evg.fillStr "#333" ]
            { x = 100, y = 89, anchor = Evg.End }
            "End"
        ]


textOnPath : String
textOnPath =
    docImage { width = 120, height = 90 }
        [ Evg.text
            [ Evg.fontSize 11
            , Evg.fillStr "#333"
            , Text.onPath [ M ( 10, 80 ) [ C ( 40, 10 ) ( 65, 10 ) ( 95, 80 ) ] ]
            ]
            { x = 0, y = 0, anchor = Evg.Start }
            "along a curve"
        ]
