module TransformDiagrams exposing (svgs)

{-| Generates documentation images for the Evg.Transform module.

Each image shows a before/after pair: the grey shape is the original and
the blue shape is the transformed result.

-}


type alias DocSvg =
    { name : String, body : String }


svgs : List DocSvg
svgs =
    [ { name = "transform-translate-example.svg", body = translateSvg }
    , { name = "transform-rotate-example.svg", body = rotateSvg }
    , { name = "transform-rotate-around-example.svg", body = rotateAroundSvg }
    , { name = "transform-scale-example.svg", body = scaleSvg }
    , { name = "transform-skew-x-example.svg", body = skewXSvg }
    ]


translateSvg : String
translateSvg =
    """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 140 70" width="140" height="70">
  <rect x="10" y="10" width="30" height="30" fill="#bbb"/>
  <rect x="10" y="10" width="30" height="30" fill="royalblue" transform="translate(80 20)"/>
  <line x1="43" y1="28" x2="85" y2="38" stroke="#888" stroke-width="1.5" stroke-dasharray="3 2"/>
</svg>"""


rotateSvg : String
rotateSvg =
    """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 140 100" width="140" height="100">
  <circle cx="0" cy="0" r="3" fill="#333"/>
  <rect x="70" y="10" width="30" height="30" fill="#bbb"/>
  <rect x="70" y="10" width="30" height="30" fill="royalblue" fill-opacity="0.85" transform="rotate(30)"/>
</svg>"""


rotateAroundSvg : String
rotateAroundSvg =
    """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 130 80" width="130" height="80">
  <rect x="45" y="20" width="40" height="40" fill="#bbb"/>
  <rect x="45" y="20" width="40" height="40" fill="royalblue" fill-opacity="0.85" transform="rotate(45 65 40)"/>
  <circle cx="65" cy="40" r="2" fill="white"/>
</svg>"""


scaleSvg : String
scaleSvg =
    """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 140 60" width="140" height="60">
  <rect x="10" y="10" width="30" height="30" fill="#bbb"/>
  <rect x="10" y="10" width="30" height="30" fill="royalblue" fill-opacity="0.7" transform="scale(2 1)"/>
</svg>"""


skewXSvg : String
skewXSvg =
    """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 70" width="120" height="70">
  <rect x="10" y="10" width="40" height="40" fill="#bbb"/>
  <rect x="10" y="10" width="40" height="40" fill="royalblue" fill-opacity="0.85" transform="skewX(20)"/>
</svg>"""
