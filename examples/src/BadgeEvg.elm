module BadgeEvg exposing (main)

{-| A notification badge icon with a drop shadow filter.
Implemented with gampleman/evg.
-}

import Evg
import Evg.Filter as Filter
import Evg.Path exposing (Path(..), PathSegment(..))
import Html exposing (Html)


main : Html msg
main =
    let
        dropShadow =
            Filter.sourceAlpha
                |> Filter.gaussianBlur 2
                |> Filter.offset 1.5 2
                |> Filter.compositeOver Filter.sourceGraphic
    in
    Evg.svg [ Evg.style "width: 200px; height: 200px" ] { width = 100, height = 100 }
        [ -- Bell body with drop shadow
          Evg.path [ Evg.fillStr "#ffc107", Evg.filter dropShadow ]
            [ M ( 50, 20 )
                [ C ( 35, 20 ) ( 25, 32 ) ( 25, 45 )
                , L ( 25, 60 )
                , L ( 20, 65 )
                , L ( 80, 65 )
                , L ( 75, 60 )
                , L ( 75, 45 )
                , C ( 75, 32 ) ( 65, 20 ) ( 50, 20 )
                ]
            ]

        , -- Bell clapper
          Evg.circle [ Evg.fillStr "#ff8f00" ] { r = 5, center = ( 50, 72 ) }

        , -- Bell top
          Evg.circle [ Evg.fillStr "#ffc107" ] { r = 3, center = ( 50, 18 ) }

        , -- Notification dot
          Evg.circle [ Evg.fillStr "#f44336", Evg.strokeStr "white", Evg.strokeWidth 2 ]
            { r = 10, center = ( 68, 28 ) }

        , -- Number in dot
          Evg.text [ Evg.fillStr "white", Evg.fontSize 11 ]
            { x = 68, y = 32, anchor = Evg.Middle }
            "3"
        ]
