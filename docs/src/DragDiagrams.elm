module DragDiagrams exposing (svgs)

{-| Generates documentation images for the Evg.Drag module.

Each picture is a strip of moments from a drag. The in-between frames are
produced by the same blending code the library runs while dragging, so they
show exactly what a user would see.

-}

import Evg exposing (Evg)
import Evg.Drag as Drag
import Evg.Internal.Layered as Layered
import Evg.Transform as Transform


type alias DocSvg =
    { name : String, body : String }


svgs : List DocSvg
svgs =
    [ { name = "drag-between.svg", body = betweenSvg }
    , { name = "drag-closest.svg", body = closestSvg }
    , { name = "drag-floating.svg", body = floatingSvg }
    , { name = "drag-vary.svg", body = varySvg }
    ]


{-| Lay out frames side by side, each with a caption underneath and, when
given, a pointer drawn where the finger or mouse is.
-}
strip : { width : Float, height : Float } -> List { caption : String, pointer : Maybe ( Float, Float ), drawing : Evg Never } -> String
strip frame frames =
    let
        count =
            toFloat (List.length frames)

        totalWidth =
            frame.width * count
    in
    Evg.toString []
        { width = totalWidth, height = frame.height + 30 }
        (List.indexedMap
            (\i f ->
                Evg.group [ Transform.translate (toFloat i * frame.width) 0 ]
                    [ Evg.rect [ Evg.fillStr "#f8f9fa", Evg.strokeStr "#dee2e6", Evg.cornerRadius 6 ]
                        { x = 4, y = 4, width = frame.width - 8, height = frame.height - 8 }
                    , f.drawing
                    , case f.pointer of
                        Just p ->
                            cursor p

                        Nothing ->
                            Evg.none
                    , Evg.text [ Evg.fontSize 13, Evg.fontFamily "sans-serif", Evg.fillStr "#495057" ]
                        { x = frame.width / 2, y = frame.height + 18, anchor = Evg.Middle }
                        f.caption
                    ]
            )
            frames
        )


{-| A hand-drawn arrow cursor with its tip at the point.
-}
cursor : ( Float, Float ) -> Evg msg
cursor ( x, y ) =
    Evg.polygon [ Evg.fillStr "#212529", Evg.strokeStr "white", Evg.strokeWidth 1.5, Transform.translate x y ]
        [ ( 0, 0 ), ( 0, 17 ), ( 4.5, 13 ), ( 7.5, 20 ), ( 10, 19 ), ( 7, 12 ), ( 12.5, 12 ) ]


layered : Maybe String -> Evg Never -> Layered.Layered Never
layered =
    Layered.fromEvg


draw : Layered.Layered Never -> Evg Never
draw =
    Layered.toEvg [] []



-- BETWEEN


toggle : Bool -> Evg Never
toggle on =
    Evg.group [ Transform.translate 30 30 ]
        [ Evg.rect
            [ Evg.cornerRadius 30
            , Evg.fillStr
                (if on then
                    "#40c057"

                 else
                    "#ced4da"
                )
            ]
            { x = 0, y = 0, width = 120, height = 60 }
        , Evg.circle [ Evg.fillStr "white", Evg.strokeStr "#868e96", Drag.key "knob" ]
            { r = 26
            , center =
                if on then
                    ( 90, 30 )

                else
                    ( 30, 30 )
            }
        ]


{-| The toggle knob a third and two thirds of the way across. Not only the
knob moves: the track's colour is blended too.
-}
betweenSvg : String
betweenSvg =
    let
        at t =
            draw (Layered.blend t (layered Nothing (toggle False)) (layered Nothing (toggle True)))
    in
    strip { width = 180, height = 120 }
        [ { caption = "grab", pointer = Just ( 66, 66 ), drawing = toggle False }
        , { caption = "drag…", pointer = Just ( 86, 66 ), drawing = at (1 / 3) }
        , { caption = "…further", pointer = Just ( 106, 66 ), drawing = at (2 / 3) }
        , { caption = "drop", pointer = Nothing, drawing = toggle True }
        ]



-- CLOSEST AND FLOATING


list : List String -> Evg Never
list items =
    Evg.group [ Transform.translate 20 20 ]
        (List.indexedMap
            (\i item ->
                Evg.group [ Drag.key item, Transform.translate 0 (toFloat i * 34) ]
                    [ Evg.rect [ Evg.fillStr (colour item), Evg.cornerRadius 4 ] { x = 0, y = 0, width = 120, height = 28 }
                    , Evg.text [ Evg.fontSize 13, Evg.fontFamily "sans-serif", Evg.fillStr "white" ] { x = 10, y = 19, anchor = Evg.Start } item
                    ]
            )
            items
        )


colour : String -> String
colour item =
    case item of
        "Apples" ->
            "#e8590c"

        "Bread" ->
            "#1c7ed6"

        "Cheese" ->
            "#2f9e44"

        _ ->
            "#7048e8"


{-| With `closest` the drawing jumps from one reordering to the next as the
pointer moves down.
-}
closestSvg : String
closestSvg =
    strip { width = 160, height = 170 }
        [ { caption = "grab", pointer = Just ( 80, 34 ), drawing = list [ "Apples", "Bread", "Cheese", "Dates" ] }
        , { caption = "nearest: 2nd", pointer = Just ( 80, 68 ), drawing = list [ "Bread", "Apples", "Cheese", "Dates" ] }
        , { caption = "nearest: 3rd", pointer = Just ( 80, 102 ), drawing = list [ "Bread", "Cheese", "Apples", "Dates" ] }
        ]


{-| With `withFloating` the grabbed row stays under the pointer while the
others show where it would land.
-}
floatingSvg : String
floatingSvg =
    let
        floating pointerY items =
            let
                l =
                    layered (Just "Apples") (list items)
            in
            case Layered.position "Apples" ( 0, 0 ) l of
                Just ( x, y ) ->
                    draw (Layered.floatLayer "Apples" ( 20 - x + 8, pointerY - 14 - y ) Nothing l)

                Nothing ->
                    draw l
    in
    strip { width = 160, height = 170 }
        [ { caption = "grab", pointer = Just ( 80, 34 ), drawing = list [ "Apples", "Bread", "Cheese", "Dates" ] }
        , { caption = "floating", pointer = Just ( 88, 62 ), drawing = floating 62 [ "Bread", "Apples", "Cheese", "Dates" ] }
        , { caption = "floating", pointer = Just ( 88, 110 ), drawing = floating 110 [ "Bread", "Cheese", "Apples", "Dates" ] }
        , { caption = "drop", pointer = Nothing, drawing = list [ "Bread", "Cheese", "Apples", "Dates" ] }
        ]



-- VARY


arm : Float -> Float -> Evg Never
arm shoulder elbow =
    Evg.group [ Transform.translate 90 110 ]
        [ Evg.group [ Transform.rotate shoulder ]
            [ Evg.line [ Evg.strokeStr "#adb5bd", Evg.strokeWidth 10, Evg.linecapRound ] ( 0, 0 ) ( 55, 0 )
            , Evg.group [ Transform.translate 55 0, Transform.rotate elbow ]
                [ Evg.line [ Evg.strokeStr "#adb5bd", Evg.strokeWidth 10, Evg.linecapRound ] ( 0, 0 ) ( 45, 0 )
                , Evg.circle [ Evg.fillStr "#f08c00" ] { r = 8, center = ( 45, 0 ) }
                ]
            , Evg.circle [ Evg.fillStr "#1c7ed6" ] { r = 6, center = ( 55, 0 ) }
            ]
        , Evg.circle [ Evg.fillStr "#343a40" ] { r = 6, center = ( 0, 0 ) }
        ]


{-| Following the hand with `vary`: the library finds both joint angles for
each pointer position.
-}
varySvg : String
varySvg =
    let
        -- Two-link inverse kinematics, only to place the pictures.
        pose ( px, py ) =
            let
                tx =
                    px - 90

                ty =
                    py - 110

                d =
                    clamp 11 99 (sqrt (tx * tx + ty * ty))

                elbow =
                    acos (clamp -1 1 ((d * d - 55 * 55 - 45 * 45) / (2 * 55 * 45)))

                shoulder =
                    atan2 ty tx - atan2 (45 * sin elbow) (55 + 45 * cos elbow)
            in
            arm (shoulder * 180 / pi) (elbow * 180 / pi)
    in
    strip { width = 180, height = 150 }
        (List.map
            (\( caption, p ) -> { caption = caption, pointer = Just p, drawing = pose p })
            [ ( "grab the hand", ( 172, 92 ) ), ( "up…", ( 120, 30 ) ), ( "…round", ( 30, 60 ) ), ( "…and in", ( 110, 130 ) ) ]
        )
