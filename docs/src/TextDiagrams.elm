module TextDiagrams exposing (svgs)

{-| Generates documentation diagrams for text layout.
-}


type alias DocSvg =
    { name : String, body : String }


svgs : List DocSvg
svgs =
    [ { name = "text-anchors.svg", body = anchors }
    , { name = "text-on-path.svg", body = textOnPath }
    ]


anchors : String
anchors =
    """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 100" width="200" height="100">
  <line x1="100" y1="5" x2="100" y2="95" stroke="#ccc" stroke-width="1" stroke-dasharray="3 2"/>
  <circle cx="100" cy="25" r="3" fill="#e53935"/>
  <text x="100" y="29" font-size="12" fill="#333" text-anchor="start">Start</text>
  <circle cx="100" cy="55" r="3" fill="#e53935"/>
  <text x="100" y="59" font-size="12" fill="#333" text-anchor="middle">Middle</text>
  <circle cx="100" cy="85" r="3" fill="#e53935"/>
  <text x="100" y="89" font-size="12" fill="#333" text-anchor="end">End</text>
</svg>"""


textOnPath : String
textOnPath =
    """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 90" width="120" height="90">
  <path id="curve" d="M 10 80 C 40 10, 65 10, 95 80" fill="none" stroke="none"/>
  <text font-size="11" fill="#333">
    <textPath href="#curve">along a curve</textPath>
  </text>
</svg>"""
