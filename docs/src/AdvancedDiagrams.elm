module AdvancedDiagrams exposing (svgs)

{-| Generates documentation images for the Evg.Advanced module.

These are produced with `Evg.toString` itself, so the pictures in the docs
are guaranteed to show what the library actually renders.

-}

import Evg
import Evg.Advanced as Advanced


type alias DocSvg =
    { name : String, body : String }


svgs : List DocSvg
svgs =
    [ { name = "not-supported.svg", body = notSupportedSvg }
    ]


{-| The placeholder shown at two different shapes, so readers can see that the
box fills whatever area it is given while the lettering stays readable.
-}
notSupportedSvg : String
notSupportedSvg =
    Evg.toString
        [ Advanced.viewBox 0 0 260 120 ]
        { width = 520, height = 240 }
        [ Evg.group []
            [ Advanced.nestedSvg []
                { x = 10, y = 10, width = 150, height = 60 }
                [ Advanced.notSupported ]
            , Advanced.nestedSvg []
                { x = 180, y = 10, width = 70, height = 100 }
                [ Advanced.notSupported ]
            ]
        ]
