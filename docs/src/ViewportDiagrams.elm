module ViewportDiagrams exposing (svgs)

{-| Generates documentation images for viewport control functions.
-}


type alias DocSvg =
    { name : String, body : String }


svgs : List DocSvg
svgs =
    [ { name = "preserve-aspect-ratio.svg", body = preserveAspectRatioSvg }
    ]


{-| Two square viewports showing the same wide drawing (a landscape scene)
rendered with Meet (letterboxed) and Slice (cropped).
-}
preserveAspectRatioSvg : String
preserveAspectRatioSvg =
    """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 320 180" width="320" height="180">
  <!-- Meet: whole drawing visible, empty bands above and below -->
  <g>
    <rect x="10" y="10" width="130" height="130" fill="#f2f2f2" stroke="#999" stroke-width="1"/>
    <svg x="10" y="10" width="130" height="130" viewBox="0 0 200 100" preserveAspectRatio="xMidYMid meet">
      <rect x="0" y="0" width="200" height="100" fill="#bcd9ef"/>
      <circle cx="150" cy="30" r="18" fill="#f6c344"/>
      <polygon points="0,100 60,40 120,100" fill="#5b8c5a"/>
      <polygon points="80,100 150,55 200,100" fill="#3f6f3e"/>
    </svg>
    <text x="75" y="160" font-family="sans-serif" font-size="13" text-anchor="middle" fill="#333">Meet</text>
  </g>
  <!-- Slice: viewport filled, sides of the drawing cropped away -->
  <g>
    <rect x="180" y="10" width="130" height="130" fill="#f2f2f2" stroke="#999" stroke-width="1"/>
    <svg x="180" y="10" width="130" height="130" viewBox="0 0 200 100" preserveAspectRatio="xMidYMid slice">
      <rect x="0" y="0" width="200" height="100" fill="#bcd9ef"/>
      <circle cx="150" cy="30" r="18" fill="#f6c344"/>
      <polygon points="0,100 60,40 120,100" fill="#5b8c5a"/>
      <polygon points="80,100 150,55 200,100" fill="#3f6f3e"/>
    </svg>
    <text x="245" y="160" font-family="sans-serif" font-size="13" text-anchor="middle" fill="#333">Slice</text>
  </g>
</svg>"""
