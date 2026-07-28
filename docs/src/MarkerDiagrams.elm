module MarkerDiagrams exposing (svgs)

{-| Generates documentation images for the Evg.Marker module.
-}


type alias DocSvg =
    { name : String, body : String }


svgs : List DocSvg
svgs =
    [ { name = "marker-arrow-example.svg", body = arrowSvg }
    , { name = "marker-mid-example.svg", body = midSvg }
    ]


arrowSvg : String
arrowSvg =
    """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 160 40" width="160" height="40">
  <defs>
    <marker id="mk-arrow" markerWidth="10" markerHeight="10" refX="10" refY="5" orient="auto" markerUnits="strokeWidth">
      <polygon points="0,0 10,5 0,10" fill="black"/>
    </marker>
  </defs>
  <line x1="15" y1="20" x2="145" y2="20" stroke="black" stroke-width="2" marker-end="url(#mk-arrow)"/>
</svg>"""


midSvg : String
midSvg =
    """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 100" width="120" height="100">
  <defs>
    <marker id="mk-dot" markerWidth="8" markerHeight="8" refX="4" refY="4" orient="auto" markerUnits="userSpaceOnUse">
      <circle cx="4" cy="4" r="4" fill="crimson"/>
    </marker>
  </defs>
  <polyline points="15,15 60,85 105,15" fill="none" stroke="black" stroke-width="2" marker-mid="url(#mk-dot)"/>
</svg>"""
