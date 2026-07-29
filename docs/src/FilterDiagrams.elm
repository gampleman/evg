module FilterDiagrams exposing (svgs)

{-| Generates documentation images for filter functions. Each image shows a
shape without the filter on the left and with the filter on the right.

The single-effect before/after images are built with the library's own
`Evg.toString`, so the pictures are guaranteed to show what the library
actually renders. The multi-panel comparison images further down stay as raw
SVG strings: their hand-coordinated absolute subregion pixel positions read
more clearly as literal SVG.

-}

import Color
import Evg
import Evg.Advanced as Advanced
import Evg.Filter as Filter


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
    , { name = "filter-flood.svg", body = floodSvg }
    , { name = "filter-noise-types.svg", body = noiseTypesSvg }
    , { name = "filter-composite.svg", body = compositeSvg }
    , { name = "filter-blend.svg", body = blendSvg }
    , { name = "filter-hue-rotate.svg", body = hueRotateSvg }
    , { name = "filter-luminance-to-alpha.svg", body = luminanceToAlphaSvg }
    , { name = "filter-component-transfer.svg", body = componentTransferSvg }
    , { name = "filter-offset.svg", body = offsetSvg }
    , { name = "filter-tile.svg", body = tileSvg }
    , { name = "filter-convolve.svg", body = convolveSvg }
    , { name = "filter-lighting.svg", body = lightingSvg }
    , { name = "filter-subregion.svg", body = subregionSvg }
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


{-| A small caption used under comparison panels: 10px grey sans-serif text.
-}
label : ( Float, Float ) -> String -> Evg.Evg Never
label ( x, y ) content =
    Evg.text
        [ Evg.fontFamily "sans-serif"
        , Evg.fontSize 10
        , Evg.fillStr "#555"
        ]
        { x = x, y = y, anchor = Evg.Middle }
        content


blurSvg : String
blurSvg =
    docImage { width = 150, height = 80 }
        [ Evg.circle [ Evg.fillStr "crimson" ] { r = 22, center = ( 38, 40 ) }
        , Evg.circle
            [ Evg.fillStr "crimson"
            , Evg.filter (Filter.sourceGraphic |> Filter.gaussianBlur 3)
            ]
            { r = 22, center = ( 112, 40 ) }
        ]


dropShadowSvg : String
dropShadowSvg =
    docImage { width = 150, height = 80 }
        [ Evg.rect [ Evg.fillStr "steelblue", Evg.cornerRadius 6 ]
            { x = 18, y = 20, width = 40, height = 40 }
        , Evg.rect
            [ Evg.fillStr "steelblue"
            , Evg.cornerRadius 6
            , Evg.filter
                (Filter.sourceGraphic
                    |> Filter.dropShadow
                        { offset = ( 3, 3 ), blur = 3, color = Color.black }
                )
            ]
            { x = 92, y = 20, width = 40, height = 40 }
        ]


turbulenceSvg : String
turbulenceSvg =
    let
        turb =
            Filter.turbulence
                { baseFrequency = 0.05, numOctaves = 2, seed = 1, stitchTiles = False }
    in
    docImage { width = 150, height = 80 }
        [ Evg.rect [ Evg.fillStr "mediumseagreen" ]
            { x = 18, y = 20, width = 40, height = 40 }
        , Evg.rect [ Evg.fillStr "mediumseagreen", Evg.filter turb ]
            { x = 92, y = 20, width = 40, height = 40 }
        ]


displacementSvg : String
displacementSvg =
    let
        noise =
            Filter.fractalNoise
                { baseFrequency = 0.08, numOctaves = 1, seed = 2, stitchTiles = False }

        disp =
            noise
                |> Filter.displacementMapWithChannelSelector
                    { scale = 12
                    , xChannelSelector = Filter.Red
                    , yChannelSelector = Filter.Green
                    }
                    Filter.sourceGraphic
    in
    docImage { width = 150, height = 80 }
        [ Evg.rect [ Evg.fillStr "darkorange" ]
            { x = 18, y = 20, width = 40, height = 40 }
        , Evg.rect [ Evg.fillStr "darkorange", Evg.filter disp ]
            { x = 92, y = 20, width = 40, height = 40 }
        ]


saturateSvg : String
saturateSvg =
    let
        swatches ( cx1, _ ) ( cx2, _ ) =
            [ Evg.circle [ Evg.fillStr "tomato" ] { r = 14, center = ( cx1, 40 ) }
            , Evg.circle [ Evg.fillStr "gold", Evg.fillOpacity 0.85 ]
                { r = 14, center = ( cx2, 40 ) }
            ]
    in
    docImage { width = 150, height = 80 }
        [ Evg.group [] (swatches ( 28, 40 ) ( 48, 40 ))
        , Evg.group
            [ Evg.filter (Filter.sourceGraphic |> Filter.saturate 0) ]
            (swatches ( 102, 40 ) ( 122, 40 ))
        ]


dilateSvg : String
dilateSvg =
    docImage { width = 150, height = 80 }
        [ Evg.text
            [ Evg.fontFamily "sans-serif", Evg.fontSize 26, Evg.fillStr "navy" ]
            { x = 38, y = 48, anchor = Evg.Middle }
            "Ab"
        , Evg.text
            [ Evg.fontFamily "sans-serif"
            , Evg.fontSize 26
            , Evg.fillStr "navy"
            , Evg.filter (Filter.sourceGraphic |> Filter.dilate 2)
            ]
            { x = 112, y = 48, anchor = Evg.Middle }
            "Ab"
        ]


erodeSvg : String
erodeSvg =
    docImage { width = 150, height = 80 }
        [ Evg.text
            [ Evg.fontFamily "sans-serif"
            , Evg.fontSize 26
            , Evg.fillStr "navy"
            , Evg.style "font-weight: bold"
            ]
            { x = 38, y = 48, anchor = Evg.Middle }
            "Ab"
        , Evg.text
            [ Evg.fontFamily "sans-serif"
            , Evg.fontSize 26
            , Evg.fillStr "navy"
            , Evg.style "font-weight: bold"
            , Evg.filter (Filter.sourceGraphic |> Filter.erode 1)
            ]
            { x = 112, y = 48, anchor = Evg.Middle }
            "Ab"
        ]


floodSvg : String
floodSvg =
    let
        floodFilter =
            Filter.compositeOver Filter.sourceGraphic (Filter.floodStr "teal")
    in
    docImage { width = 150, height = 80 }
        [ Evg.circle
            [ Evg.fillStr "gold"
            , Evg.filterWithCoordinates
                (Evg.userSpace { x = 20, y = 14, width = 110, height = 52 })
                floodFilter
            ]
            { r = 12, center = ( 75, 40 ) }
        ]


noiseTypesSvg : String
noiseTypesSvg =
    let
        region =
            Evg.objectBoundingBox { x = 0, y = 0, width = 1, height = 1 }

        fractal =
            Filter.fractalNoise
                { baseFrequency = 0.05, numOctaves = 2, seed = 3, stitchTiles = False }

        turb =
            Filter.turbulence
                { baseFrequency = 0.05, numOctaves = 2, seed = 3, stitchTiles = False }
    in
    docImage { width = 150, height = 80 }
        [ Evg.rect [ Evg.filterWithCoordinates region fractal ]
            { x = 18, y = 14, width = 40, height = 40 }
        , Evg.rect [ Evg.filterWithCoordinates region turb ]
            { x = 92, y = 14, width = 40, height = 40 }
        , label ( 38, 68 ) "fractalNoise"
        , label ( 112, 68 ) "turbulence"
        ]


offsetSvg : String
offsetSvg =
    let
        region =
            Evg.objectBoundingBox { x = -0.2, y = -0.2, width = 1.5, height = 1.5 }

        ghost =
            Filter.compositeIn
                (Filter.floodStr "#999")
                (Filter.sourceGraphic |> Filter.offset 6 6)

        ghostFilter =
            Filter.compositeOver Filter.sourceGraphic ghost
    in
    docImage { width = 150, height = 80 }
        [ Evg.rect
            [ Evg.fillStr "teal"
            , Evg.cornerRadius 6
            , Evg.filterWithCoordinates region ghostFilter
            ]
            { x = 55, y = 18, width = 40, height = 40 }
        ]


tileSvg : String
tileSvg =
    -- Left raw: the tile's repeating unit needs an absolute pixel subregion
    -- (primitiveUnits="userSpaceOnUse", x/y/width/height in px). The library's
    -- `withinSubregion` only expresses the subregion as percentages of the
    -- filter region, which does not reproduce the exact 25x16 pixel tile.
    """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 150 80" width="300" height="160">
  <defs>
    <filter id="tile" filterUnits="userSpaceOnUse" primitiveUnits="userSpaceOnUse" x="25" y="8" width="100" height="64">
      <feOffset dx="0" dy="0" x="25" y="8" width="25" height="16" result="corner"/>
      <feTile in="corner"/>
    </filter>
  </defs>
  <g filter="url(#tile)">
    <circle cx="33" cy="15" r="6" fill="darkorange"/>
    <circle cx="42" cy="17" r="6" fill="royalblue" fill-opacity="0.8"/>
  </g>
  <rect x="25" y="8" width="25" height="16" fill="none" stroke="#555" stroke-width="1" stroke-dasharray="3 2"/>
</svg>"""


convolveSvg : String
convolveSvg =
    let
        emboss =
            Filter.sourceGraphic
                |> Filter.convolve
                    [ Filter.divisor 1, Filter.bias 0.5 ]
                    [ [ 1, 0, 0 ]
                    , [ 0, 0, 0 ]
                    , [ 0, 0, -1 ]
                    ]

        panel xRect xText attrs =
            Evg.group attrs
                [ Evg.rect [ Evg.fillStr "#ddd" ]
                    { x = xRect, y = 10, width = 48, height = 46 }
                , Evg.text
                    [ Evg.fontFamily "sans-serif"
                    , Evg.fontSize 34
                    , Evg.fillStr "navy"
                    , Evg.style "font-weight: bold"
                    ]
                    { x = xText, y = 46, anchor = Evg.Middle }
                    "E"
                ]
    in
    docImage { width = 150, height = 80 }
        [ panel 14 38 []
        , panel 88
            112
            [ Evg.filterWithCoordinates
                (Evg.objectBoundingBox { x = 0, y = 0, width = 1, height = 1 })
                emboss
            ]
        , label ( 38, 70 ) "original"
        , label ( 112, 70 ) "embossed"
        ]


subregionSvg : String
subregionSvg =
    let
        region =
            Evg.objectBoundingBox { x = -0.5, y = -0.5, width = 2, height = 2 }

        freeBlur =
            Filter.sourceGraphic |> Filter.gaussianBlur 4

        clippedBlur =
            Filter.sourceGraphic
                |> Filter.gaussianBlur 4
                |> Filter.withinSubregion
                    { x = 0.3125, y = 0.3125, width = 0.375, height = 0.375 }
    in
    docImage { width = 150, height = 80 }
        [ Evg.circle
            [ Evg.fillStr "rebeccapurple"
            , Evg.filterWithCoordinates region freeBlur
            ]
            { r = 16, center = ( 38, 40 ) }
        , Evg.circle
            [ Evg.fillStr "rebeccapurple"
            , Evg.filterWithCoordinates region clippedBlur
            ]
            { r = 16, center = ( 112, 40 ) }
        , Evg.rect
            [ Evg.fillStr "none"
            , Evg.strokeStr "#555"
            , Evg.strokeWidth 1
            , Evg.dashPattern [ 3, 2 ]
            ]
            { x = 100, y = 28, width = 24, height = 24 }
        ]


compositeSvg : String
compositeSvg =
    -- The remaining images below stay as raw SVG strings: their multi-panel
    -- layouts rely on hand-coordinated absolute subregion coordinates
    -- (userSpaceOnUse filter regions and feFlood/light positions per panel)
    -- that read more clearly as literal SVG than as library calls.
    """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 324 64" width="648" height="128">
  <defs>
    <filter id="comp-in" filterUnits="userSpaceOnUse" x="3" y="2" width="50" height="46">
      <feFlood flood-color="gold" x="23" y="18" width="22" height="22" result="sq"/>
      <feComposite in="SourceGraphic" in2="sq" operator="in"/>
    </filter>
    <filter id="comp-out" filterUnits="userSpaceOnUse" x="57" y="2" width="50" height="46">
      <feFlood flood-color="gold" x="77" y="18" width="22" height="22" result="sq"/>
      <feComposite in="SourceGraphic" in2="sq" operator="out"/>
    </filter>
    <filter id="comp-atop" filterUnits="userSpaceOnUse" x="111" y="2" width="50" height="46">
      <feFlood flood-color="gold" x="131" y="18" width="22" height="22" result="sq"/>
      <feComposite in="SourceGraphic" in2="sq" operator="atop"/>
    </filter>
    <filter id="comp-over" filterUnits="userSpaceOnUse" x="165" y="2" width="50" height="46">
      <feFlood flood-color="gold" x="185" y="18" width="22" height="22" result="sq"/>
      <feComposite in="SourceGraphic" in2="sq" operator="over"/>
    </filter>
    <filter id="comp-xor" filterUnits="userSpaceOnUse" x="219" y="2" width="50" height="46">
      <feFlood flood-color="gold" x="239" y="18" width="22" height="22" result="sq"/>
      <feComposite in="SourceGraphic" in2="sq" operator="xor"/>
    </filter>
    <filter id="comp-arith" filterUnits="userSpaceOnUse" x="273" y="2" width="50" height="46">
      <feFlood flood-color="gold" x="293" y="18" width="22" height="22" result="sq"/>
      <feComposite in="SourceGraphic" in2="sq" operator="arithmetic" k1="0" k2="0.5" k3="0.5" k4="0"/>
    </filter>
  </defs>
  <circle cx="23" cy="24" r="13" fill="royalblue" filter="url(#comp-in)"/>
  <circle cx="77" cy="24" r="13" fill="royalblue" filter="url(#comp-out)"/>
  <circle cx="131" cy="24" r="13" fill="royalblue" filter="url(#comp-atop)"/>
  <circle cx="185" cy="24" r="13" fill="royalblue" filter="url(#comp-over)"/>
  <circle cx="239" cy="24" r="13" fill="royalblue" filter="url(#comp-xor)"/>
  <circle cx="293" cy="24" r="13" fill="royalblue" filter="url(#comp-arith)"/>
  <text x="27" y="58" font-family="sans-serif" font-size="10" text-anchor="middle" fill="#555">in</text>
  <text x="81" y="58" font-family="sans-serif" font-size="10" text-anchor="middle" fill="#555">out</text>
  <text x="135" y="58" font-family="sans-serif" font-size="10" text-anchor="middle" fill="#555">atop</text>
  <text x="189" y="58" font-family="sans-serif" font-size="10" text-anchor="middle" fill="#555">over</text>
  <text x="243" y="58" font-family="sans-serif" font-size="10" text-anchor="middle" fill="#555">xor</text>
  <text x="297" y="58" font-family="sans-serif" font-size="10" text-anchor="middle" fill="#555">arithmetic</text>
</svg>"""


blendSvg : String
blendSvg =
    """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 280 64" width="560" height="128">
  <defs>
    <filter id="blend-normal" filterUnits="userSpaceOnUse" x="4" y="2" width="50" height="46">
      <feFlood flood-color="gold" x="24" y="18" width="22" height="22" result="sq"/>
      <feBlend in="SourceGraphic" in2="sq" mode="normal"/>
    </filter>
    <filter id="blend-multiply" filterUnits="userSpaceOnUse" x="60" y="2" width="50" height="46">
      <feFlood flood-color="gold" x="80" y="18" width="22" height="22" result="sq"/>
      <feBlend in="SourceGraphic" in2="sq" mode="multiply"/>
    </filter>
    <filter id="blend-screen" filterUnits="userSpaceOnUse" x="116" y="2" width="50" height="46">
      <feFlood flood-color="gold" x="136" y="18" width="22" height="22" result="sq"/>
      <feBlend in="SourceGraphic" in2="sq" mode="screen"/>
    </filter>
    <filter id="blend-darken" filterUnits="userSpaceOnUse" x="172" y="2" width="50" height="46">
      <feFlood flood-color="gold" x="192" y="18" width="22" height="22" result="sq"/>
      <feBlend in="SourceGraphic" in2="sq" mode="darken"/>
    </filter>
    <filter id="blend-lighten" filterUnits="userSpaceOnUse" x="228" y="2" width="50" height="46">
      <feFlood flood-color="gold" x="248" y="18" width="22" height="22" result="sq"/>
      <feBlend in="SourceGraphic" in2="sq" mode="lighten"/>
    </filter>
  </defs>
  <circle cx="24" cy="24" r="13" fill="tomato" filter="url(#blend-normal)"/>
  <circle cx="80" cy="24" r="13" fill="tomato" filter="url(#blend-multiply)"/>
  <circle cx="136" cy="24" r="13" fill="tomato" filter="url(#blend-screen)"/>
  <circle cx="192" cy="24" r="13" fill="tomato" filter="url(#blend-darken)"/>
  <circle cx="248" cy="24" r="13" fill="tomato" filter="url(#blend-lighten)"/>
  <text x="28" y="58" font-family="sans-serif" font-size="10" text-anchor="middle" fill="#555">normal</text>
  <text x="84" y="58" font-family="sans-serif" font-size="10" text-anchor="middle" fill="#555">multiply</text>
  <text x="140" y="58" font-family="sans-serif" font-size="10" text-anchor="middle" fill="#555">screen</text>
  <text x="196" y="58" font-family="sans-serif" font-size="10" text-anchor="middle" fill="#555">darken</text>
  <text x="252" y="58" font-family="sans-serif" font-size="10" text-anchor="middle" fill="#555">lighten</text>
</svg>"""


hueRotateSvg : String
hueRotateSvg =
    """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 150 80" width="300" height="160">
  <defs>
    <filter id="hr0"><feColorMatrix type="hueRotate" values="0"/></filter>
    <filter id="hr90"><feColorMatrix type="hueRotate" values="90"/></filter>
    <filter id="hr180"><feColorMatrix type="hueRotate" values="180"/></filter>
  </defs>
  <g filter="url(#hr0)">
    <circle cx="18" cy="30" r="10" fill="red"/>
    <circle cx="32" cy="30" r="10" fill="green" fill-opacity="0.85"/>
    <circle cx="25" cy="42" r="10" fill="blue" fill-opacity="0.85"/>
  </g>
  <g filter="url(#hr90)">
    <circle cx="68" cy="30" r="10" fill="red"/>
    <circle cx="82" cy="30" r="10" fill="green" fill-opacity="0.85"/>
    <circle cx="75" cy="42" r="10" fill="blue" fill-opacity="0.85"/>
  </g>
  <g filter="url(#hr180)">
    <circle cx="118" cy="30" r="10" fill="red"/>
    <circle cx="132" cy="30" r="10" fill="green" fill-opacity="0.85"/>
    <circle cx="125" cy="42" r="10" fill="blue" fill-opacity="0.85"/>
  </g>
  <text x="25" y="68" font-family="sans-serif" font-size="10" text-anchor="middle" fill="#555">0&#176;</text>
  <text x="75" y="68" font-family="sans-serif" font-size="10" text-anchor="middle" fill="#555">90&#176;</text>
  <text x="125" y="68" font-family="sans-serif" font-size="10" text-anchor="middle" fill="#555">180&#176;</text>
</svg>"""


luminanceToAlphaSvg : String
luminanceToAlphaSvg =
    """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 150 80" width="300" height="160">
  <defs>
    <linearGradient id="lum-grad" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="white"/>
      <stop offset="1" stop-color="black"/>
    </linearGradient>
    <filter id="lum-alpha" x="0%" y="0%" width="100%" height="100%">
      <feColorMatrix type="luminanceToAlpha"/>
    </filter>
  </defs>
  <g>
    <rect x="12" y="18" width="56" height="44" fill="url(#lum-grad)"/>
    <circle cx="40" cy="40" r="12" fill="tomato"/>
  </g>
  <rect x="82" y="18" width="56" height="44" fill="teal"/>
  <g filter="url(#lum-alpha)">
    <rect x="82" y="18" width="56" height="44" fill="url(#lum-grad)"/>
    <circle cx="110" cy="40" r="12" fill="tomato"/>
  </g>
</svg>"""


componentTransferSvg : String
componentTransferSvg =
    """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 288 56" width="576" height="112">
  <defs>
    <linearGradient id="ct-grad" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="white"/>
      <stop offset="1" stop-color="black"/>
    </linearGradient>
    <filter id="ct-table" x="0%" y="0%" width="100%" height="100%">
      <feComponentTransfer>
        <feFuncR type="table" tableValues="0 1 0"/>
        <feFuncG type="table" tableValues="0 1 0"/>
        <feFuncB type="table" tableValues="0 1 0"/>
      </feComponentTransfer>
    </filter>
    <filter id="ct-discrete" x="0%" y="0%" width="100%" height="100%">
      <feComponentTransfer>
        <feFuncR type="discrete" tableValues="0 .25 .5 .75 1"/>
        <feFuncG type="discrete" tableValues="0 .25 .5 .75 1"/>
        <feFuncB type="discrete" tableValues="0 .25 .5 .75 1"/>
      </feComponentTransfer>
    </filter>
    <filter id="ct-linear" x="0%" y="0%" width="100%" height="100%">
      <feComponentTransfer>
        <feFuncR type="linear" slope="0.5" intercept="0.25"/>
        <feFuncG type="linear" slope="0.5" intercept="0.25"/>
        <feFuncB type="linear" slope="0.5" intercept="0.25"/>
      </feComponentTransfer>
    </filter>
    <filter id="ct-gamma" x="0%" y="0%" width="100%" height="100%">
      <feComponentTransfer>
        <feFuncR type="gamma" amplitude="1" exponent="2.2" offset="0"/>
        <feFuncG type="gamma" amplitude="1" exponent="2.2" offset="0"/>
        <feFuncB type="gamma" amplitude="1" exponent="2.2" offset="0"/>
      </feComponentTransfer>
    </filter>
  </defs>
  <rect x="8" y="10" width="58" height="20" fill="url(#ct-grad)" filter="url(#ct-table)"/>
  <rect x="80" y="10" width="58" height="20" fill="url(#ct-grad)" filter="url(#ct-discrete)"/>
  <rect x="152" y="10" width="58" height="20" fill="url(#ct-grad)" filter="url(#ct-linear)"/>
  <rect x="224" y="10" width="58" height="20" fill="url(#ct-grad)" filter="url(#ct-gamma)"/>
  <text x="37" y="46" font-family="sans-serif" font-size="10" text-anchor="middle" fill="#555">table</text>
  <text x="109" y="46" font-family="sans-serif" font-size="10" text-anchor="middle" fill="#555">discrete</text>
  <text x="181" y="46" font-family="sans-serif" font-size="10" text-anchor="middle" fill="#555">linear</text>
  <text x="253" y="46" font-family="sans-serif" font-size="10" text-anchor="middle" fill="#555">gamma</text>
</svg>"""


lightingSvg : String
lightingSvg =
    """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 150 80" width="300" height="160">
  <defs>
    <filter id="light-spec" x="0%" y="0%" width="100%" height="100%">
      <feTurbulence type="fractalNoise" baseFrequency="0.05" numOctaves="2" seed="5" result="noise"/>
      <feSpecularLighting in="noise" surfaceScale="3" specularConstant="1" specularExponent="20" lighting-color="white" result="spec">
        <fePointLight x="40" y="20" z="40"/>
      </feSpecularLighting>
      <feComposite in="spec" in2="SourceGraphic" operator="over"/>
    </filter>
    <filter id="light-diff" x="0%" y="0%" width="100%" height="100%">
      <feTurbulence type="fractalNoise" baseFrequency="0.05" numOctaves="2" seed="5" result="noise"/>
      <feDiffuseLighting in="noise" surfaceScale="12" diffuseConstant="1" lighting-color="white">
        <fePointLight x="109" y="20" z="15"/>
      </feDiffuseLighting>
    </filter>
  </defs>
  <rect x="12" y="10" width="58" height="44" fill="#223" filter="url(#light-spec)"/>
  <rect x="80" y="10" width="58" height="44" fill="#223" filter="url(#light-diff)"/>
  <text x="41" y="68" font-family="sans-serif" font-size="10" text-anchor="middle" fill="#555">specular</text>
  <text x="109" y="68" font-family="sans-serif" font-size="10" text-anchor="middle" fill="#555">diffuse</text>
</svg>"""
