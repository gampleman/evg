module PaintDiagrams exposing (svgs)

{-| Generates documentation images for the Evg.Paint module.
-}


type alias DocSvg =
    { name : String, body : String }


svgs : List DocSvg
svgs =
    [ { name = "linear-gradient-example.svg", body = linearGradientSvg }
    , { name = "linear-gradient-diagonal-example.svg", body = linearGradientDiagonalSvg }
    , { name = "radial-gradient-example.svg", body = radialGradientSvg }
    , { name = "pattern-dots-example.svg", body = patternDotsSvg }
    ]


linearGradientSvg : String
linearGradientSvg =
    """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 60" width="120" height="60">
  <defs>
    <linearGradient id="lg" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="rgb(255,255,0)"/>
      <stop offset="1" stop-color="rgb(255,0,0)"/>
    </linearGradient>
  </defs>
  <rect x="0" y="0" width="120" height="60" fill="url(#lg)"/>
</svg>"""


linearGradientDiagonalSvg : String
linearGradientDiagonalSvg =
    """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 60" width="120" height="60">
  <defs>
    <linearGradient id="lgd" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="rgb(0,0,255)"/>
      <stop offset="1" stop-color="rgb(255,0,255)"/>
    </linearGradient>
  </defs>
  <rect x="0" y="0" width="120" height="60" fill="url(#lgd)"/>
</svg>"""


radialGradientSvg : String
radialGradientSvg =
    """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" width="100" height="100">
  <defs>
    <radialGradient id="rg" cx="0.5" cy="0.5" r="0.5">
      <stop offset="0" stop-color="rgb(255,255,255)"/>
      <stop offset="1" stop-color="rgb(0,0,0)"/>
    </radialGradient>
  </defs>
  <rect x="0" y="0" width="100" height="100" fill="url(#rg)"/>
</svg>"""


patternDotsSvg : String
patternDotsSvg =
    """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 60" width="120" height="60">
  <defs>
    <pattern id="dots" width="10" height="10" patternUnits="userSpaceOnUse" viewBox="0 0 10 10">
      <rect x="0" y="0" width="10" height="10" fill="white"/>
      <circle cx="5" cy="5" r="3" fill="red"/>
    </pattern>
  </defs>
  <rect x="0" y="0" width="120" height="60" fill="url(#dots)" stroke="#999" stroke-width="1"/>
</svg>"""
