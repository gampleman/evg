module FilterDiagrams exposing (svgs)

{-| Generates documentation images for filter functions. Each image shows a
shape without the filter on the left and with the filter on the right.
-}


type alias DocSvg =
    { name : String, body : String }


svgs : List DocSvg
svgs =
    [ { name = "filter-blur.svg", body = blurSvg }
    , { name = "filter-drop-shadow.svg", body = dropShadowSvg }
    , { name = "filter-turbulence.svg", body = turbulenceSvg }
    , { name = "filter-displacement.svg", body = displacementSvg }
    , { name = "filter-saturate.svg", body = saturateSvg }
    , { name = "filter-dilate.svg", body = dilateSvg }
    , { name = "filter-erode.svg", body = erodeSvg }
    ]


blurSvg : String
blurSvg =
    """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 150 80" width="150" height="80">
  <defs>
    <filter id="blur"><feGaussianBlur stdDeviation="3"/></filter>
  </defs>
  <circle cx="38" cy="40" r="22" fill="crimson"/>
  <circle cx="112" cy="40" r="22" fill="crimson" filter="url(#blur)"/>
</svg>"""


dropShadowSvg : String
dropShadowSvg =
    """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 150 80" width="150" height="80">
  <defs>
    <filter id="shadow"><feDropShadow dx="3" dy="3" stdDeviation="3" flood-color="black"/></filter>
  </defs>
  <rect x="18" y="20" width="40" height="40" rx="6" fill="steelblue"/>
  <rect x="92" y="20" width="40" height="40" rx="6" fill="steelblue" filter="url(#shadow)"/>
</svg>"""


turbulenceSvg : String
turbulenceSvg =
    """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 150 80" width="150" height="80">
  <defs>
    <filter id="turb"><feTurbulence type="turbulence" baseFrequency="0.05" numOctaves="2" seed="1"/></filter>
  </defs>
  <rect x="18" y="20" width="40" height="40" fill="mediumseagreen"/>
  <rect x="92" y="20" width="40" height="40" fill="mediumseagreen" filter="url(#turb)"/>
</svg>"""


displacementSvg : String
displacementSvg =
    """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 150 80" width="150" height="80">
  <defs>
    <filter id="disp">
      <feTurbulence type="fractalNoise" baseFrequency="0.08" numOctaves="1" seed="2" result="noise"/>
      <feDisplacementMap in="SourceGraphic" in2="noise" scale="12" xChannelSelector="R" yChannelSelector="G"/>
    </filter>
  </defs>
  <rect x="18" y="20" width="40" height="40" fill="darkorange"/>
  <rect x="92" y="20" width="40" height="40" fill="darkorange" filter="url(#disp)"/>
</svg>"""


saturateSvg : String
saturateSvg =
    """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 150 80" width="150" height="80">
  <defs>
    <filter id="desat"><feColorMatrix type="saturate" values="0"/></filter>
  </defs>
  <g>
    <circle cx="28" cy="40" r="14" fill="tomato"/>
    <circle cx="48" cy="40" r="14" fill="gold" fill-opacity="0.85"/>
  </g>
  <g filter="url(#desat)">
    <circle cx="102" cy="40" r="14" fill="tomato"/>
    <circle cx="122" cy="40" r="14" fill="gold" fill-opacity="0.85"/>
  </g>
</svg>"""


dilateSvg : String
dilateSvg =
    """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 150 80" width="150" height="80">
  <defs>
    <filter id="dilate"><feMorphology operator="dilate" radius="2"/></filter>
  </defs>
  <text x="38" y="48" font-family="sans-serif" font-size="26" text-anchor="middle" fill="navy">Ab</text>
  <text x="112" y="48" font-family="sans-serif" font-size="26" text-anchor="middle" fill="navy" filter="url(#dilate)">Ab</text>
</svg>"""


erodeSvg : String
erodeSvg =
    """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 150 80" width="150" height="80">
  <defs>
    <filter id="erode"><feMorphology operator="erode" radius="1"/></filter>
  </defs>
  <text x="38" y="48" font-family="sans-serif" font-size="26" font-weight="bold" text-anchor="middle" fill="navy">Ab</text>
  <text x="112" y="48" font-family="sans-serif" font-size="26" font-weight="bold" text-anchor="middle" fill="navy" filter="url(#erode)">Ab</text>
</svg>"""
