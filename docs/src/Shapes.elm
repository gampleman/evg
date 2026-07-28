module Shapes exposing (svgs)

{-| Generates documentation images for basic shape functions.
-}

import Svg
import Svg.Attributes


type alias DocSvg =
    { name : String, body : String }


svgs : List DocSvg
svgs =
    [ { name = "line.svg", body = lineSvg }
    , { name = "rect-example.svg", body = rectSvg }
    , { name = "circle-example.svg", body = circleSvg }
    , { name = "ellipse-example.svg", body = ellipseSvg }
    , { name = "polygon-example.svg", body = polygonSvg }
    , { name = "polyline-example.svg", body = polylineSvg }
    ]


lineSvg : String
lineSvg =
    """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 40" width="120" height="40">
  <line x1="10" y1="20" x2="110" y2="20" stroke="black" stroke-width="2"/>
  <circle cx="10" cy="20" r="3" fill="#666"/>
  <circle cx="110" cy="20" r="3" fill="#666"/>
</svg>"""


rectSvg : String
rectSvg =
    """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 80" width="120" height="80">
  <rect x="10" y="10" width="100" height="60" fill="navy" rx="0"/>
</svg>"""


circleSvg : String
circleSvg =
    """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" width="100" height="100">
  <circle cx="50" cy="50" r="40" fill="crimson"/>
</svg>"""


ellipseSvg : String
ellipseSvg =
    """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 160 100" width="160" height="100">
  <ellipse cx="80" cy="50" rx="70" ry="35" fill="mediumpurple"/>
</svg>"""


polygonSvg : String
polygonSvg =
    """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 110" width="120" height="110">
  <polygon points="60,10 110,100 10,100" fill="limegreen"/>
</svg>"""


polylineSvg : String
polylineSvg =
    """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 60" width="120" height="60">
  <polyline points="10,50 30,10 50,40 70,20 90,45 110,15" fill="none" stroke="black" stroke-width="2"/>
</svg>"""
