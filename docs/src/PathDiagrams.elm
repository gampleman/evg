module PathDiagrams exposing (svgs)

{-| Generates documentation diagrams for path commands.
Each diagram shows the command's effect with labeled control points.

These are produced with `Evg.toString` itself, so the pictures in the docs
are guaranteed to show what the library actually renders.

-}

import Evg
import Evg.Advanced as Advanced
import Evg.Path exposing (Path(..), PathSegment(..))


type alias DocSvg =
    { name : String, body : String }


svgs : List DocSvg
svgs =
    [ { name = "path-l.svg", body = lineTo }
    , { name = "path-h-v.svg", body = hv }
    , { name = "path-c.svg", body = cubicBezier }
    , { name = "path-s.svg", body = smoothCubic }
    , { name = "path-q.svg", body = quadraticBezier }
    , { name = "path-t.svg", body = smoothQuadratic }
    , { name = "path-a.svg", body = arc }
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


{-| A dashed guide line connecting a curve endpoint to its control point.
-}
guide : List Float -> ( Float, Float ) -> ( Float, Float ) -> Evg.Evg Never
guide dashes from to =
    Evg.line
        [ Evg.strokeStr "#ccc", Evg.strokeWidth 1, Evg.dashPattern dashes ]
        from
        to


lineTo : String
lineTo =
    docImage { width = 160, height = 80 }
        [ Evg.path [ Evg.fillStr "none", Evg.strokeStr "#333", Evg.strokeWidth 2 ]
            [ M ( 20, 60 ) [ L ( 140, 20 ) ] ]
        , Evg.circle [ Evg.fillStr "#e53935" ] { r = 4, center = ( 20, 60 ) }
        , Evg.circle [ Evg.fillStr "#1e88e5" ] { r = 4, center = ( 140, 20 ) }
        , Evg.text [ Evg.fontSize 10, Evg.fillStr "#e53935" ] { x = 20, y = 75, anchor = Evg.Middle } "start"
        , Evg.text [ Evg.fontSize 10, Evg.fillStr "#1e88e5" ] { x = 140, y = 15, anchor = Evg.Middle } "end"
        ]


hv : String
hv =
    docImage { width = 160, height = 80 }
        [ Evg.path [ Evg.fillStr "none", Evg.strokeStr "#333", Evg.strokeWidth 2 ]
            [ M ( 20, 40 ) [ H 90, V 70 ] ]
        , Evg.circle [ Evg.fillStr "#e53935" ] { r = 4, center = ( 20, 40 ) }
        , Evg.circle [ Evg.fillStr "#888" ] { r = 3, center = ( 90, 40 ) }
        , Evg.circle [ Evg.fillStr "#1e88e5" ] { r = 4, center = ( 90, 70 ) }
        , Evg.text [ Evg.fontSize 9, Evg.fillStr "#666" ] { x = 55, y = 35, anchor = Evg.Middle } "H 90"
        , Evg.text [ Evg.fontSize 9, Evg.fillStr "#666" ] { x = 100, y = 57, anchor = Evg.Start } "V 70"
        ]


cubicBezier : String
cubicBezier =
    docImage { width = 200, height = 120 }
        [ guide [ 3, 2 ] ( 20, 90 ) ( 50, 20 )
        , guide [ 3, 2 ] ( 180, 90 ) ( 150, 20 )
        , Evg.path [ Evg.fillStr "none", Evg.strokeStr "#333", Evg.strokeWidth 2 ]
            [ M ( 20, 90 ) [ C ( 50, 20 ) ( 150, 20 ) ( 180, 90 ) ] ]
        , Evg.circle [ Evg.fillStr "#e53935" ] { r = 4, center = ( 20, 90 ) }
        , Evg.circle [ Evg.fillStr "#ff9800" ] { r = 4, center = ( 50, 20 ) }
        , Evg.circle [ Evg.fillStr "#ff9800" ] { r = 4, center = ( 150, 20 ) }
        , Evg.circle [ Evg.fillStr "#1e88e5" ] { r = 4, center = ( 180, 90 ) }
        , Evg.text [ Evg.fontSize 9, Evg.fillStr "#e53935" ] { x = 20, y = 105, anchor = Evg.Middle } "start"
        , Evg.text [ Evg.fontSize 9, Evg.fillStr "#ff9800" ] { x = 50, y = 14, anchor = Evg.Middle } "cp1"
        , Evg.text [ Evg.fontSize 9, Evg.fillStr "#ff9800" ] { x = 150, y = 14, anchor = Evg.Middle } "cp2"
        , Evg.text [ Evg.fontSize 9, Evg.fillStr "#1e88e5" ] { x = 180, y = 105, anchor = Evg.Middle } "end"
        ]


smoothCubic : String
smoothCubic =
    docImage { width = 240, height = 150 }
        [ guide [ 3, 2 ] ( 20, 70 ) ( 40, 20 )
        , guide [ 3, 2 ] ( 100, 70 ) ( 80, 20 )
        , Evg.path [ Evg.fillStr "none", Evg.strokeStr "#333", Evg.strokeWidth 2 ]
            [ M ( 20, 70 ) [ C ( 40, 20 ) ( 80, 20 ) ( 100, 70 ) ] ]
        , Evg.line [ Evg.strokeStr "#ff9800", Evg.strokeWidth 1, Evg.dashPattern [ 2, 2 ] ] ( 100, 70 ) ( 120, 120 )
        , guide [ 3, 2 ] ( 180, 70 ) ( 160, 20 )
        , Evg.path [ Evg.fillStr "none", Evg.strokeStr "#1e88e5", Evg.strokeWidth 2 ]
            [ M ( 100, 70 ) [ C ( 120, 120 ) ( 160, 20 ) ( 180, 70 ) ] ]
        , Evg.circle [ Evg.fillStr "none", Evg.strokeStr "#ff9800", Evg.dashPattern [ 2, 2 ] ] { r = 3, center = ( 120, 120 ) }
        , Evg.circle [ Evg.fillStr "#e53935" ] { r = 4, center = ( 20, 70 ) }
        , Evg.circle [ Evg.fillStr "#ff9800" ] { r = 3, center = ( 40, 20 ) }
        , Evg.circle [ Evg.fillStr "#ff9800" ] { r = 3, center = ( 80, 20 ) }
        , Evg.circle [ Evg.fillStr "#888" ] { r = 4, center = ( 100, 70 ) }
        , Evg.circle [ Evg.fillStr "#ff9800" ] { r = 4, center = ( 160, 20 ) }
        , Evg.circle [ Evg.fillStr "#1e88e5" ] { r = 4, center = ( 180, 70 ) }
        , Evg.text [ Evg.fontSize 9, Evg.fillStr "#ff9800" ] { x = 120, y = 135, anchor = Evg.Middle } "mirrored cp1"
        , Evg.text [ Evg.fontSize 9, Evg.fillStr "#ff9800" ] { x = 160, y = 14, anchor = Evg.Middle } "cp2"
        , Evg.text [ Evg.fontSize 9, Evg.fillStr "#1e88e5" ] { x = 192, y = 85, anchor = Evg.Middle } "end"
        ]


quadraticBezier : String
quadraticBezier =
    docImage { width = 160, height = 100 }
        [ guide [ 3, 2 ] ( 20, 80 ) ( 80, 15 )
        , guide [ 3, 2 ] ( 80, 15 ) ( 140, 80 )
        , Evg.path [ Evg.fillStr "none", Evg.strokeStr "#333", Evg.strokeWidth 2 ]
            [ M ( 20, 80 ) [ Q ( 80, 15 ) ( 140, 80 ) ] ]
        , Evg.circle [ Evg.fillStr "#e53935" ] { r = 4, center = ( 20, 80 ) }
        , Evg.circle [ Evg.fillStr "#ff9800" ] { r = 4, center = ( 80, 15 ) }
        , Evg.circle [ Evg.fillStr "#1e88e5" ] { r = 4, center = ( 140, 80 ) }
        , Evg.text [ Evg.fontSize 9, Evg.fillStr "#e53935" ] { x = 20, y = 95, anchor = Evg.Middle } "start"
        , Evg.text [ Evg.fontSize 9, Evg.fillStr "#ff9800" ] { x = 80, y = 10, anchor = Evg.Middle } "control"
        , Evg.text [ Evg.fontSize 9, Evg.fillStr "#1e88e5" ] { x = 140, y = 95, anchor = Evg.Middle } "end"
        ]


smoothQuadratic : String
smoothQuadratic =
    docImage { width = 220, height = 150 }
        [ guide [ 3, 2 ] ( 20, 70 ) ( 55, 15 )
        , guide [ 3, 2 ] ( 55, 15 ) ( 90, 70 )
        , Evg.path [ Evg.fillStr "none", Evg.strokeStr "#333", Evg.strokeWidth 2 ]
            [ M ( 20, 70 ) [ Q ( 55, 15 ) ( 90, 70 ) ] ]
        , Evg.line [ Evg.strokeStr "#ff9800", Evg.strokeWidth 1, Evg.dashPattern [ 2, 2 ] ] ( 90, 70 ) ( 125, 125 )
        , Evg.line [ Evg.strokeStr "#ff9800", Evg.strokeWidth 1, Evg.dashPattern [ 2, 2 ] ] ( 125, 125 ) ( 160, 70 )
        , Evg.path [ Evg.fillStr "none", Evg.strokeStr "#1e88e5", Evg.strokeWidth 2 ]
            [ M ( 90, 70 ) [ Q ( 125, 125 ) ( 160, 70 ) ] ]
        , Evg.circle [ Evg.fillStr "#e53935" ] { r = 4, center = ( 20, 70 ) }
        , Evg.circle [ Evg.fillStr "#ff9800" ] { r = 3, center = ( 55, 15 ) }
        , Evg.circle [ Evg.fillStr "#888" ] { r = 4, center = ( 90, 70 ) }
        , Evg.circle [ Evg.fillStr "none", Evg.strokeStr "#ff9800", Evg.dashPattern [ 2, 2 ] ] { r = 3, center = ( 125, 125 ) }
        , Evg.circle [ Evg.fillStr "#1e88e5" ] { r = 4, center = ( 160, 70 ) }
        , Evg.text [ Evg.fontSize 9, Evg.fillStr "#ff9800" ] { x = 55, y = 10, anchor = Evg.Middle } "control"
        , Evg.text [ Evg.fontSize 9, Evg.fillStr "#ff9800" ] { x = 125, y = 140, anchor = Evg.Middle } "mirrored control"
        , Evg.text [ Evg.fontSize 9, Evg.fillStr "#1e88e5" ] { x = 172, y = 85, anchor = Evg.Middle } "end"
        ]


{-| One panel of the arc diagram: the same two endpoints and radii every time,
with only the largeArc and sweep flags changing. The four panels together are
the four arcs those flags can pick out.
-}
arcPanel : ( Float, Float ) -> Bool -> Bool -> Evg.Evg Never
arcPanel ( ox, oy ) largeArc sweep =
    let
        -- The endpoints sit at the vertical middle of the panel, so the two
        -- possible circles extend equally above and below them.
        from =
            ( ox + 22, oy + 58 )

        to =
            ( ox + 62, oy + 58 )

        -- Labelled with the Elm values the API takes, not SVG's 1/0 encoding.
        flag b =
            if b then
                "True"

            else
                "False"
    in
    Evg.group []
        [ -- The three arcs not being shown, faint, for context.
          Evg.path
            [ Evg.fillStr "none", Evg.strokeStr "#e8e8e8", Evg.strokeWidth 1.5 ]
            [ M from [ A 30 30 0 (not largeArc) sweep to ]
            , M from [ A 30 30 0 largeArc (not sweep) to ]
            , M from [ A 30 30 0 (not largeArc) (not sweep) to ]
            ]
        , Evg.path
            [ Evg.fillStr "none", Evg.strokeStr "#1e88e5", Evg.strokeWidth 2.5 ]
            [ M from [ A 30 30 0 largeArc sweep to ] ]
        , Evg.circle [ Evg.fillStr "#e53935" ] { r = 3.5, center = from }
        , Evg.circle [ Evg.fillStr "#333" ] { r = 3.5, center = to }
        , Evg.text
            [ Evg.fontSize 9, Evg.fontFamily "sans-serif", Evg.fillStr "#555" ]
            { x = ox + 42, y = oy + 118, anchor = Evg.Middle }
            ("largeArc=" ++ flag largeArc ++ " sweep=" ++ flag sweep)
        ]


{-| All four arcs that share a pair of endpoints. The blue arc is the one the
flags select; the pale arcs are the other three possibilities.
-}
arc : String
arc =
    docImage { width = 380, height = 260 }
        [ arcPanel ( 26, 4 ) True True
        , arcPanel ( 216, 4 ) True False
        , arcPanel ( 26, 134 ) False True
        , arcPanel ( 216, 134 ) False False
        , Evg.text
            [ Evg.fontSize 9, Evg.fontFamily "sans-serif", Evg.fillStr "#e53935" ]
            { x = 43, y = 76, anchor = Evg.End }
            "start"
        , Evg.text
            [ Evg.fontSize 9, Evg.fontFamily "sans-serif", Evg.fillStr "#333" ]
            { x = 95, y = 76, anchor = Evg.Start }
            "end"
        ]
