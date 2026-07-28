module PathDiagrams exposing (svgs)

{-| Generates documentation diagrams for path commands.
Each diagram shows the command's effect with labeled control points.
-}


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


lineTo : String
lineTo =
    """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 160 80" width="160" height="80">
  <path d="M 20 60 L 140 20" fill="none" stroke="#333" stroke-width="2"/>
  <circle cx="20" cy="60" r="4" fill="#e53935"/>
  <circle cx="140" cy="20" r="4" fill="#1e88e5"/>
  <text x="20" y="75" font-size="10" fill="#e53935" text-anchor="middle">start</text>
  <text x="140" y="15" font-size="10" fill="#1e88e5" text-anchor="middle">end</text>
</svg>"""


hv : String
hv =
    """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 160 80" width="160" height="80">
  <path d="M 20 40 H 90 V 70" fill="none" stroke="#333" stroke-width="2"/>
  <circle cx="20" cy="40" r="4" fill="#e53935"/>
  <circle cx="90" cy="40" r="3" fill="#888"/>
  <circle cx="90" cy="70" r="4" fill="#1e88e5"/>
  <text x="55" y="35" font-size="9" fill="#666" text-anchor="middle">H 90</text>
  <text x="100" y="57" font-size="9" fill="#666">V 70</text>
</svg>"""


cubicBezier : String
cubicBezier =
    """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 120" width="200" height="120">
  <!-- control lines -->
  <line x1="20" y1="90" x2="50" y2="20" stroke="#ccc" stroke-width="1" stroke-dasharray="3 2"/>
  <line x1="180" y1="90" x2="150" y2="20" stroke="#ccc" stroke-width="1" stroke-dasharray="3 2"/>
  <!-- curve -->
  <path d="M 20 90 C 50 20, 150 20, 180 90" fill="none" stroke="#333" stroke-width="2"/>
  <!-- points -->
  <circle cx="20" cy="90" r="4" fill="#e53935"/>
  <circle cx="50" cy="20" r="4" fill="#ff9800"/>
  <circle cx="150" cy="20" r="4" fill="#ff9800"/>
  <circle cx="180" cy="90" r="4" fill="#1e88e5"/>
  <!-- labels -->
  <text x="20" y="105" font-size="9" fill="#e53935" text-anchor="middle">start</text>
  <text x="50" y="14" font-size="9" fill="#ff9800" text-anchor="middle">cp1</text>
  <text x="150" y="14" font-size="9" fill="#ff9800" text-anchor="middle">cp2</text>
  <text x="180" y="105" font-size="9" fill="#1e88e5" text-anchor="middle">end</text>
</svg>"""


smoothCubic : String
smoothCubic =
    """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 240 100" width="240" height="100">
  <!-- first curve C -->
  <line x1="20" y1="70" x2="40" y2="20" stroke="#ccc" stroke-width="1" stroke-dasharray="3 2"/>
  <line x1="100" y1="70" x2="80" y2="20" stroke="#ccc" stroke-width="1" stroke-dasharray="3 2"/>
  <path d="M 20 70 C 40 20, 80 20, 100 70" fill="none" stroke="#333" stroke-width="2"/>
  <!-- smooth continuation S -->
  <line x1="100" y1="70" x2="120" y2="120" stroke="#ddd" stroke-width="1" stroke-dasharray="2 2"/>
  <line x1="180" y1="70" x2="160" y2="20" stroke="#ccc" stroke-width="1" stroke-dasharray="3 2"/>
  <path d="M 100 70 S 160 20, 180 70" fill="none" stroke="#1e88e5" stroke-width="2"/>
  <!-- reflected control point (shown as ghost) -->
  <circle cx="120" cy="120" r="3" fill="none" stroke="#ff9800" stroke-dasharray="2 2"/>
  <!-- points -->
  <circle cx="20" cy="70" r="4" fill="#e53935"/>
  <circle cx="40" cy="20" r="3" fill="#ff9800"/>
  <circle cx="80" cy="20" r="3" fill="#ff9800"/>
  <circle cx="100" cy="70" r="4" fill="#888"/>
  <circle cx="160" cy="20" r="4" fill="#ff9800"/>
  <circle cx="180" cy="70" r="4" fill="#1e88e5"/>
  <!-- labels -->
  <text x="120" y="90" font-size="9" fill="#ff9800" text-anchor="middle">reflected cp1</text>
  <text x="160" y="14" font-size="9" fill="#ff9800" text-anchor="middle">cp2</text>
  <text x="180" y="85" font-size="9" fill="#1e88e5" text-anchor="middle">end</text>
</svg>"""


quadraticBezier : String
quadraticBezier =
    """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 160 100" width="160" height="100">
  <!-- control lines -->
  <line x1="20" y1="80" x2="80" y2="15" stroke="#ccc" stroke-width="1" stroke-dasharray="3 2"/>
  <line x1="80" y1="15" x2="140" y2="80" stroke="#ccc" stroke-width="1" stroke-dasharray="3 2"/>
  <!-- curve -->
  <path d="M 20 80 Q 80 15, 140 80" fill="none" stroke="#333" stroke-width="2"/>
  <!-- points -->
  <circle cx="20" cy="80" r="4" fill="#e53935"/>
  <circle cx="80" cy="15" r="4" fill="#ff9800"/>
  <circle cx="140" cy="80" r="4" fill="#1e88e5"/>
  <!-- labels -->
  <text x="20" y="95" font-size="9" fill="#e53935" text-anchor="middle">start</text>
  <text x="80" y="10" font-size="9" fill="#ff9800" text-anchor="middle">control</text>
  <text x="140" y="95" font-size="9" fill="#1e88e5" text-anchor="middle">end</text>
</svg>"""


smoothQuadratic : String
smoothQuadratic =
    """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 220 100" width="220" height="100">
  <!-- first Q curve -->
  <line x1="20" y1="70" x2="55" y2="15" stroke="#ccc" stroke-width="1" stroke-dasharray="3 2"/>
  <line x1="55" y1="15" x2="90" y2="70" stroke="#ccc" stroke-width="1" stroke-dasharray="3 2"/>
  <path d="M 20 70 Q 55 15, 90 70" fill="none" stroke="#333" stroke-width="2"/>
  <!-- T continuation (reflected control) -->
  <line x1="90" y1="70" x2="125" y2="125" stroke="#ddd" stroke-width="1" stroke-dasharray="2 2"/>
  <path d="M 90 70 T 160 70" fill="none" stroke="#1e88e5" stroke-width="2"/>
  <!-- points -->
  <circle cx="20" cy="70" r="4" fill="#e53935"/>
  <circle cx="55" cy="15" r="3" fill="#ff9800"/>
  <circle cx="90" cy="70" r="4" fill="#888"/>
  <circle cx="125" cy="125" r="3" fill="none" stroke="#ff9800" stroke-dasharray="2 2"/>
  <circle cx="160" cy="70" r="4" fill="#1e88e5"/>
  <!-- labels -->
  <text x="55" y="10" font-size="9" fill="#ff9800" text-anchor="middle">control</text>
  <text x="125" y="90" font-size="9" fill="#ff9800" text-anchor="middle">reflected</text>
  <text x="160" y="85" font-size="9" fill="#1e88e5" text-anchor="middle">end</text>
</svg>"""


arc : String
arc =
    """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 120" width="200" height="120">
  <!-- large arc -->
  <path d="M 40 60 A 40 40 0 1 1 120 60" fill="none" stroke="#333" stroke-width="2"/>
  <!-- small arc (same endpoints) -->
  <path d="M 40 60 A 40 40 0 0 1 120 60" fill="none" stroke="#1e88e5" stroke-width="2" stroke-dasharray="4 3"/>
  <!-- endpoints -->
  <circle cx="40" cy="60" r="4" fill="#e53935"/>
  <circle cx="120" cy="60" r="4" fill="#1e88e5"/>
  <!-- radius annotation -->
  <line x1="80" y1="20" x2="120" y2="20" stroke="#888" stroke-width="1"/>
  <text x="100" y="16" font-size="9" fill="#888" text-anchor="middle">rx</text>
  <!-- labels -->
  <text x="80" y="110" font-size="9" fill="#333" text-anchor="middle">large-arc=1 (solid)</text>
  <text x="80" y="52" font-size="9" fill="#1e88e5" text-anchor="middle">large-arc=0 (dashed)</text>
</svg>"""
