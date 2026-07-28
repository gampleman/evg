module MaskDiagrams exposing (svgs)

{-| Generates documentation images for the Evg.Mask module.
-}


type alias DocSvg =
    { name : String, body : String }


svgs : List DocSvg
svgs =
    [ { name = "clip-vs-mask-example.svg", body = clipVsMaskSvg }
    ]


clipVsMaskSvg : String
clipVsMaskSvg =
    """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 210 100" width="210" height="100">
  <defs>
    <linearGradient id="cm-photo" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#ff8c00"/>
      <stop offset="0.5" stop-color="#e0407b"/>
      <stop offset="1" stop-color="#4b0082"/>
    </linearGradient>
    <clipPath id="cm-clip">
      <circle cx="50" cy="50" r="40"/>
    </clipPath>
    <radialGradient id="cm-soft" cx="0.5" cy="0.5" r="0.5">
      <stop offset="0" stop-color="white"/>
      <stop offset="0.6" stop-color="white"/>
      <stop offset="1" stop-color="black"/>
    </radialGradient>
    <mask id="cm-mask">
      <circle cx="50" cy="50" r="40" fill="url(#cm-soft)"/>
    </mask>
  </defs>
  <rect x="10" y="10" width="80" height="80" fill="url(#cm-photo)" clip-path="url(#cm-clip)"/>
  <g transform="translate(110 0)">
    <rect x="10" y="10" width="80" height="80" fill="url(#cm-photo)" mask="url(#cm-mask)"/>
  </g>
</svg>"""
