module DragTest exposing (suite)

import Evg exposing (Evg)
import Evg.Advanced as Advanced
import Evg.Animate as Animate
import Evg.Drag as Drag
import Evg.Internal as Internal
import Evg.Internal.Interpolation as Interpolation
import Evg.Internal.Layered as Layered
import Evg.Internal.Lerp as Lerp
import Evg.Internal.Optimize as Optimize
import Evg.Transform as Transform
import Expect exposing (Expectation, FloatingPointTolerance(..))
import Fuzz exposing (Fuzzer)
import Html.Attributes
import Json.Encode as Encode
import Test exposing (Test, describe, fuzz, fuzz2, test)
import Test.Html.Event as Event
import Test.Html.Query as Query
import Test.Html.Selector as Selector


suite : Test
suite =
    describe "Evg.Drag"
        [ lerpTests
        , interpolationTests
        , optimizeTests
        , layeredTests
        , engineTests
        ]



-- VALUE BLENDING


lerpTests : Test
lerpTests =
    describe "blending attribute values"
        [ test "numbers inside strings blend" <|
            \_ ->
                Lerp.attribute "d" 0.5 (Just "M0 0 L10 20") (Just "M10 10 L30 40")
                    |> Expect.equal (Just "M5 5 L20 30")
        , test "compact path syntax with signs and decimals" <|
            \_ ->
                Lerp.attribute "d" 0.5 (Just "M0-2.5L.5 4") (Just "M2-4.5L1.5 8")
                    |> Expect.equal (Just "M1-3.5L1 6")
        , test "different shapes snap at the halfway point" <|
            \_ ->
                ( Lerp.attribute "d" 0.4 (Just "M0 0 L1 1") (Just "M0 0 C1 1 2 2 3 3")
                , Lerp.attribute "d" 0.6 (Just "M0 0 L1 1") (Just "M0 0 C1 1 2 2 3 3")
                )
                    |> Expect.equal ( Just "M0 0 L1 1", Just "M0 0 C1 1 2 2 3 3" )
        , test "named and hex colours blend through rgba" <|
            \_ ->
                Lerp.attribute "fill" 0.5 (Just "black") (Just "#ffffff")
                    |> Expect.equal (Just "rgba(50%,50%,50%,1)")
        , test "elm-color strings blend" <|
            \_ ->
                Lerp.attribute "fill" 0.25 (Just "rgba(100%,0%,0%,1)") (Just "rgba(0%,0%,100%,1)")
                    |> Expect.equal (Just "rgba(75%,0%,25%,1)")
        , test "a colour fades to none through its own transparent version" <|
            \_ ->
                Lerp.attribute "fill" 0.5 (Just "red") (Just "none")
                    |> Expect.equal (Just "rgba(100%,0%,0%,0.5)")
        , test "names and references don't blend" <|
            \_ ->
                ( Lerp.attribute "class" 0.3 (Just "item-1") (Just "item-3")
                , Lerp.attribute "fill" 0.3 (Just "url(#e1)") (Just "url(#e3)")
                )
                    |> Expect.equal ( Just "item-1", Just "url(#e1)" )
        , test "a missing opacity counts as 1" <|
            \_ ->
                Lerp.attribute "opacity" 0.5 Nothing (Just "0")
                    |> Expect.equal (Just "0.5")
        , test "transforms with the same functions blend argument by argument" <|
            \_ ->
                Lerp.transform 0.5 "rotate(0 50 50)" "rotate(90 50 50)"
                    |> Expect.equal "rotate(45 50 50)"
        , test "translate and rotate blend independently" <|
            \_ ->
                Lerp.transform 0.5 "translate(0 0) rotate(10)" "translate(20 -10) rotate(30)"
                    |> Expect.equal "translate(10 -5) rotate(20)"
        , fuzz2 matrixFuzzer (Fuzz.floatRange 0 1) "differing transforms blend through a decomposition that reproduces both ends" <|
            \( a, b ) t ->
                let
                    strA =
                        "translate(" ++ String.fromFloat a ++ " 3) rotate(" ++ String.fromFloat b ++ ")"

                    strB =
                        "scale(2) translate(" ++ String.fromFloat b ++ " " ++ String.fromFloat a ++ ")"

                    atEnd tEnd =
                        Lerp.transformToMatrix (Lerp.transform tEnd strA strB)

                    close x y =
                        abs (x - y) < 1.0e-3
                in
                if t < 0 then
                    Expect.pass

                else
                    let
                        m0 =
                            atEnd 1.0e-9

                        mA =
                            Lerp.transformToMatrix strA

                        m1 =
                            atEnd (1 - 1.0e-9)

                        mB =
                            Lerp.transformToMatrix strB
                    in
                    expectTrue "ends match"
                        (List.all identity
                            [ close m0.a mA.a, close m0.b mA.b, close m0.c mA.c, close m0.d mA.d, close m0.e mA.e, close m0.f mA.f ]
                            && List.all identity
                                [ close m1.a mB.a, close m1.b mB.b, close m1.c mB.c, close m1.d mB.d, close m1.e mB.e, close m1.f mB.f ]
                        )
        , test "transform strings parse to the same matrices Evg.Transform builds" <|
            \_ ->
                let
                    m =
                        Lerp.transformToMatrix "rotate(90 10 0)"
                in
                -- Rotating (20, 0) a quarter turn about (10, 0) lands on (10, 10).
                ( round (m.a * 20 + m.e), round (m.b * 20 + m.f) )
                    |> Expect.equal ( 10, 10 )
        ]


matrixFuzzer : Fuzzer ( Float, Float )
matrixFuzzer =
    Fuzz.pair (Fuzz.floatRange -50 50) (Fuzz.floatRange -170 170)



-- INTERPOLATION


pointFuzzer : Fuzzer ( Float, Float )
pointFuzzer =
    Fuzz.pair (Fuzz.floatRange 0 100) (Fuzz.floatRange 0 100)


sumWeights : Interpolation.Weights -> Float
sumWeights w =
    List.sum (List.map Tuple.second w.weights)


reconstruct : List ( Float, Float ) -> Interpolation.Weights -> ( Float, Float )
reconstruct points w =
    List.foldl
        (\( i, wi ) ( ax, ay ) ->
            case List.head (List.drop i points) of
                Just ( x, y ) ->
                    ( ax + wi * x, ay + wi * y )

                Nothing ->
                    ( ax, ay )
        )
        ( 0, 0 )
        w.weights


square : List ( Float, Float )
square =
    [ ( 0, 0 ), ( 100, 0 ), ( 100, 100 ), ( 0, 100 ), ( 40, 60 ) ]


interpolationTests : Test
interpolationTests =
    describe "between weights"
        [ fuzz pointFuzzer "barycentric weights sum to one and reproduce the point inside the hull" <|
            \q ->
                let
                    w =
                        Interpolation.weights Interpolation.Barycentric square q

                    ( rx, ry ) =
                        reconstruct square w
                in
                Expect.all
                    [ \_ -> sumWeights w |> Expect.within (Absolute 1.0e-6) 1
                    , \_ -> rx |> Expect.within (Absolute 1.0e-4) (Tuple.first q)
                    , \_ -> ry |> Expect.within (Absolute 1.0e-4) (Tuple.second q)
                    , \_ -> w.gap |> Expect.within (Absolute 1.0e-9) 0
                    ]
                    ()
        , fuzz pointFuzzer "natural neighbour weights sum to one and reproduce the point" <|
            \q ->
                let
                    w =
                        Interpolation.weights Interpolation.NaturalNeighbor square q

                    ( rx, ry ) =
                        reconstruct square w
                in
                Expect.all
                    [ \_ -> sumWeights w |> Expect.within (Absolute 1.0e-6) 1
                    , \_ -> rx |> Expect.within (Absolute 1.0e-3) (Tuple.first q)
                    , \_ -> ry |> Expect.within (Absolute 1.0e-3) (Tuple.second q)
                    ]
                    ()
        , test "outside the hull, the point slides onto its edge" <|
            \_ ->
                let
                    w =
                        Interpolation.weights Interpolation.Barycentric square ( 50, -30 )
                in
                Expect.all
                    [ \_ -> w.gap |> Expect.within (Absolute 1.0e-6) 30
                    , \_ -> reconstruct square w |> Tuple.first |> Expect.within (Absolute 1.0e-6) 50
                    ]
                    ()
        , test "two targets interpolate along their line" <|
            \_ ->
                Interpolation.weights Interpolation.Barycentric [ ( 0, 0 ), ( 100, 0 ) ] ( 25, 10 )
                    |> Expect.equal { weights = [ ( 0, 0.75 ), ( 1, 0.25 ) ], gap = 10 }
        , test "collinear targets are ordered along the line" <|
            \_ ->
                Interpolation.weights Interpolation.Barycentric [ ( 0, 0 ), ( 100, 0 ), ( 50, 0 ) ] ( 75, 0 )
                    |> .weights
                    |> List.sortBy Tuple.first
                    |> Expect.equal [ ( 1, 0.5 ), ( 2, 0.5 ) ]
        , test "coincident targets: the first one stands in" <|
            \_ ->
                Interpolation.weights Interpolation.Barycentric [ ( 10, 10 ), ( 10, 10 ) ] ( 0, 10 )
                    |> Expect.equal { weights = [ ( 0, 1 ) ], gap = 10 }
        , fuzz (Fuzz.listOfLengthBetween 3 12 pointFuzzer) "triangles from a random point set cover each point" <|
            \points ->
                let
                    indexed =
                        List.indexedMap Tuple.pair points

                    used =
                        Interpolation.triangulate indexed
                            |> List.concatMap (\( a, b, c ) -> [ a, b, c ])
                in
                -- Points that coincide or all lie in a line need not appear.
                if List.isEmpty used then
                    Expect.pass

                else
                    List.length (List.filter (\( i, _ ) -> List.member i used) indexed)
                        |> Expect.atLeast 3
        ]



-- OPTIMIZER


optimizeTests : Test
optimizeTests =
    describe "least squares"
        [ test "solves a linear problem in a step or two" <|
            \_ ->
                Optimize.leastSquares { maxIterations = 10 }
                    (\ps ->
                        case ps of
                            [ x, y ] ->
                                [ 2 * x + y - 5, x - y - 1 ]

                            _ ->
                                []
                    )
                    [ 0, 0 ]
                    |> List.map (\v -> toFloat (round (v * 1000)) / 1000)
                    |> Expect.equal [ 2, 1 ]
        , test "finds the angle that puts a point on a circle closest to a target" <|
            \_ ->
                Optimize.leastSquares { maxIterations = 30 }
                    (\ps ->
                        case ps of
                            [ a ] ->
                                [ 50 * cos a, 50 * sin a - 80 ]

                            _ ->
                                []
                    )
                    [ 0.3 ]
                    |> List.map (\a -> toFloat (round (a * 1000)) / 1000)
                    |> Expect.equal [ toFloat (round (pi / 2 * 1000)) / 1000 ]
        ]



-- LAYERED DRAWINGS


layeredTests : Test
layeredTests =
    describe "layers"
        [ test "a keyed element's position accounts for its ancestors' transforms" <|
            \_ ->
                Evg.group [ Transform.translate 10 20 ]
                    [ Evg.group [ Transform.scale 2 2 ]
                        [ Evg.circle [ Drag.key "dot", Transform.translate 5 5 ] { r = 1, center = ( 0, 0 ) } ]
                    ]
                    |> Layered.fromEvg Nothing
                    |> Layered.position "dot" ( 1, 0 )
                    |> Expect.equal (Just ( 22, 30 ))
        , test "locate agrees with position" <|
            \_ ->
                Evg.group [ Transform.translate 10 20 ]
                    [ Evg.group [ Transform.rotate 90 ]
                        [ Evg.circle [ Drag.key "dot" ] { r = 1, center = ( 0, 0 ) } ]
                    ]
                    |> Layered.locate "dot" ( 3, 0 )
                    |> Maybe.map (\( x, y ) -> ( round x, round y ))
                    |> Expect.equal (Just ( 10, 23 ))
        , test "keyed elements keep inherited presentation attributes when lifted out" <|
            \_ ->
                Evg.group [ Advanced.customAttribute "fill" "red", Evg.opacity 0.5 ]
                    [ Evg.circle [ Drag.key "dot" ] { r = 1, center = ( 0, 0 ) } ]
                    |> drawLayered
                    |> Expect.all
                        [ String.contains "fill=\"red\"" >> expectTrue "inherits fill"
                        , String.contains "opacity=\"0.5\"" >> expectTrue "inherits opacity"
                        ]
        , test "blending a drawing with itself changes nothing" <|
            \_ ->
                let
                    l =
                        Layered.fromEvg Nothing sample
                in
                Layered.blend 0.37 l l
                    |> Layered.toEvg [] []
                    |> List.singleton
                    |> Evg.toString [] { width = 100, height = 100 }
                    |> Expect.equal (drawLayered sample)
        , test "a keyed element moves between parents" <|
            \_ ->
                let
                    inPile x =
                        Evg.group [ Transform.translate x 0 ]
                            [ Evg.rect [ Drag.key "card" ] { x = 0, y = 0, width = 10, height = 10 } ]

                    a =
                        Layered.fromEvg Nothing (Evg.group [] [ inPile 0, Evg.group [] [] ])

                    b =
                        Layered.fromEvg Nothing (Evg.group [] [ Evg.group [] [], inPile 100 ])
                in
                Layered.blend 0.5 a b
                    |> Layered.position "card" ( 0, 0 )
                    |> Expect.equal (Just ( 50, 0 ))
        , test "elements only in one drawing fade" <|
            \_ ->
                let
                    a =
                        Layered.fromEvg Nothing (Evg.group [] [ Evg.circle [ Drag.key "x" ] { r = 1, center = ( 0, 0 ) } ])

                    b =
                        Layered.fromEvg Nothing (Evg.group [] [])
                in
                Layered.blend 0.75 a b
                    |> Layered.toEvg [] []
                    |> List.singleton
                    |> Evg.toString [] { width = 10, height = 10 }
                    |> String.contains "opacity=\"0.25\""
                    |> expectTrue "faded to a quarter"
        ]


sample : Evg msg
sample =
    Evg.group [ Advanced.customAttribute "fill" "navy" ]
        [ Evg.rect [ Drag.key "a", Transform.translate 3 4 ] { x = 0, y = 0, width = 10, height = 10 }
        , Evg.circle [] { r = 5, center = ( 50, 50 ) }
        , Evg.text [] { x = 10, y = 90, anchor = Evg.Start } "hello"
        ]


drawLayered : Evg msg -> String
drawLayered evg =
    Evg.toString [] { width = 100, height = 100 } [ Layered.toEvg [] [] (Layered.fromEvg Nothing evg) ]



-- THE ENGINE, DRIVEN BY POINTER EVENTS


type alias Toggle =
    { on : Bool }


toggleView : Drag.View Toggle Msg
toggleView ctx s =
    Evg.group []
        [ Evg.rect [] { x = 0, y = 0, width = 120, height = 60 }
        , Evg.circle
            [ Drag.onDrag ctx "knob" (\() -> Drag.between [ { on = False }, { on = True } ]) ]
            { r = 26
            , center =
                if s.on then
                    ( 90, 30 )

                else
                    ( 30, 30 )
            }
        ]


type alias Slider =
    { value : Float }


sliderView : Drag.View Slider Msg
sliderView ctx s =
    Evg.group []
        [ Evg.circle
            [ Drag.onDrag ctx
                "thumb"
                (\() ->
                    Drag.vary s.value (\v -> { value = v })
                        |> Drag.constrain (\st -> Drag.inOrder [ 0, st.value, 100 ])
                )
            , Transform.translate (s.value * 2) 0
            ]
            { r = 5, center = ( 0, 0 ) }
        ]


type alias Lst =
    { items : List String }


listView : Drag.View Lst Msg
listView ctx s =
    Evg.group []
        (List.indexedMap
            (\i item ->
                Evg.rect
                    [ Drag.onDrag ctx
                        item
                        (\() ->
                            Drag.closest
                                (List.map (\j -> { items = moveItem i j s.items }) (List.range 0 (List.length s.items - 1)))
                                |> Drag.withFloating
                        )
                    , Transform.translate 0 (toFloat i * 30)
                    ]
                    { x = 0, y = 0, width = 100, height = 20 }
            )
            s.items
        )


moveItem : Int -> Int -> List a -> List a
moveItem from to list =
    case List.head (List.drop from list) of
        Just item ->
            let
                without =
                    List.take from list ++ List.drop (from + 1) list
            in
            List.take to without ++ [ item ] ++ List.drop to without

        Nothing ->
            list


type alias Slots =
    { at : Int }


{-| A token that can only ever step to a neighbouring slot. Reaching a slot
two steps away in one gesture needs chaining.
-}
slotsView : Bool -> Drag.View Slots Msg
slotsView chained ctx s =
    let
        step st =
            Drag.between (List.filter (\o -> o.at >= 0 && o.at <= 3) [ st, { at = st.at + 1 }, { at = st.at - 1 } ])
                |> Drag.withSnapRadius 1
                |> (if chained then
                        Drag.chain step

                    else
                        identity
                   )
    in
    Evg.group []
        [ Evg.circle [ Drag.onDrag ctx "token" (\() -> step s) ] { r = 10, center = ( toFloat s.at * 50, 0 ) } ]


type Msg
    = ToggleMsg (Drag.Msg Toggle)
    | SlotsMsg (Drag.Msg Slots)
    | SliderMsg (Drag.Msg Slider)
    | ListMsg (Drag.Msg Lst)


pointerJson : String -> ( Float, Float ) -> Encode.Value
pointerJson kind ( x, y ) =
    Encode.object
        [ ( "offsetX", Encode.float x )
        , ( "offsetY", Encode.float y )
        , ( "clientX", Encode.float x )
        , ( "clientY", Encode.float y )
        , ( "pointerType", Encode.string kind )
        , ( "pointerId", Encode.int 7 )
        , ( "isPrimary", Encode.bool True )
        , ( "button", Encode.int 0 )
        , ( "shiftKey", Encode.bool False )
        , ( "ctrlKey", Encode.bool False )
        , ( "altKey", Encode.bool False )
        , ( "metaKey", Encode.bool False )
        ]


{-| Press on the element with the given key, move a finger through the points
and lift it at the last one.
-}
touchDrag :
    (Drag.Msg state -> Msg)
    -> (Msg -> Maybe (Drag.Msg state))
    -> Drag.View state Msg
    -> String
    -> ( Float, Float )
    -> List ( Float, Float )
    -> Drag.Model state
    -> Result String (Drag.Model state)
touchDrag wrap unwrap draggable dragKey start path model =
    let
        apply eventName point selector m =
            Evg.svg [] { width = 300, height = 300 } [ Drag.view wrap draggable m ]
                |> Query.fromHtml
                |> Query.find selector
                |> Event.simulate (Event.custom eventName (pointerJson "touch" point))
                |> Event.toResult
                |> Result.andThen
                    (\msg ->
                        case unwrap msg of
                            Just dragMsg ->
                                Ok (Drag.update draggable dragMsg m)

                            Nothing ->
                                Err "unexpected message"
                    )

        onElement =
            [ Selector.attribute (Html.Attributes.attribute "data-drag-key" dragKey) ]

        onRoot =
            [ Selector.attribute (Html.Attributes.attribute "style" "user-select: none; -webkit-user-select: none") ]

        lastIndex =
            List.length path - 1
    in
    List.foldl
        (\( i, p ) acc ->
            Result.andThen
                (apply
                    (if i == lastIndex then
                        "pointerup"

                     else
                        "pointermove"
                    )
                    p
                    onRoot
                )
                acc
        )
        (apply "pointerdown" start onElement model)
        (List.indexedMap Tuple.pair path)


engineTests : Test
engineTests =
    describe "dragging"
        [ test "a toggle knob dropped past the middle switches on" <|
            \_ ->
                Drag.init { on = False }
                    |> touchDrag ToggleMsg unwrapToggle toggleView "knob" ( 30, 30 ) [ ( 50, 30 ), ( 75, 32 ), ( 75, 32 ) ]
                    |> Result.map Drag.state
                    |> Expect.equal (Ok { on = True })
        , test "a toggle knob dropped before the middle stays off" <|
            \_ ->
                Drag.init { on = False }
                    |> touchDrag ToggleMsg unwrapToggle toggleView "knob" ( 30, 30 ) [ ( 50, 30 ), ( 45, 30 ) ]
                    |> Result.map Drag.state
                    |> Expect.equal (Ok { on = False })
        , test "preview reports where the drag is heading" <|
            \_ ->
                Drag.init { on = False }
                    |> touchDrag ToggleMsg unwrapToggle toggleView "knob" ( 30, 30 ) [ ( 80, 30 ), ( 80, 30 ) ]
                    |> Result.map (\m -> ( Drag.isDragging m, Drag.state m ))
                    |> Expect.equal (Ok ( False, { on = True } ))
        , test "vary finds the value under the pointer" <|
            \_ ->
                Drag.init { value = 0 }
                    |> touchDrag SliderMsg unwrapSlider sliderView "thumb" ( 0, 0 ) [ ( 60, 3 ), ( 120, 0 ), ( 120, 0 ) ]
                    |> Result.map (Drag.state >> .value >> round)
                    |> Expect.equal (Ok 60)
        , test "vary respects constraints" <|
            \_ ->
                Drag.init { value = 50 }
                    |> touchDrag SliderMsg unwrapSlider sliderView "thumb" ( 100, 0 ) [ ( 250, 0 ), ( 400, 0 ), ( 400, 0 ) ]
                    |> Result.map (Drag.state >> .value >> round)
                    |> Expect.equal (Ok 100)
        , test "closest with floating reorders a list" <|
            \_ ->
                Drag.init { items = [ "a", "b", "c" ] }
                    |> touchDrag ListMsg unwrapList listView "a" ( 10, 10 ) [ ( 10, 40 ), ( 10, 70 ), ( 10, 70 ) ]
                    |> Result.map (Drag.state >> .items)
                    |> Expect.equal (Ok [ "b", "c", "a" ])
        , test "chaining lets one gesture make several moves" <|
            \_ ->
                Drag.init { at = 0 }
                    |> touchDrag SlotsMsg unwrapSlots (slotsView True) "token" ( 0, 0 ) [ ( 25, 0 ), ( 50, 0 ), ( 75, 0 ), ( 100, 0 ), ( 100, 0 ) ]
                    |> Result.map (Drag.state >> .at)
                    |> Expect.equal (Ok 2)
        , test "without chaining the same gesture makes only one move" <|
            \_ ->
                Drag.init { at = 0 }
                    |> touchDrag SlotsMsg unwrapSlots (slotsView False) "token" ( 0, 0 ) [ ( 25, 0 ), ( 50, 0 ), ( 75, 0 ), ( 100, 0 ), ( 100, 0 ) ]
                    |> Result.map (Drag.state >> .at)
                    |> Expect.equal (Ok 1)
        , test "easings follow the same curves as Evg.Animate" <|
            \_ ->
                Expect.all
                    [ \_ -> Internal.easingFunction Animate.easeLinear 0.3 |> Expect.within (Absolute 1.0e-6) 0.3
                    , \_ -> Internal.easingFunction Animate.easeInOut 0.5 |> Expect.within (Absolute 1.0e-6) 0.5
                    , \_ -> Internal.easingFunction Animate.easeOut 0.5 |> Expect.atLeast 0.6
                    , \_ -> Internal.easingFunction (Animate.cubicBezier 0.34 1.56 0.64 1) 0.6 |> Expect.atLeast 1
                    , \_ -> Internal.easingFunction Animate.easeIn 1 |> Expect.within (Absolute 1.0e-9) 1
                    ]
                    ()
        , test "the floating element follows the pointer" <|
            \_ ->
                let
                    pressed =
                        Drag.init { items = [ "a", "b", "c" ] }
                            |> touchDrag ListMsg unwrapList listView "a" ( 10, 10 ) [ ( 13, 47 ) ]
                in
                case pressed of
                    Ok _ ->
                        Expect.pass

                    Err e ->
                        Expect.fail e
        ]


unwrapToggle : Msg -> Maybe (Drag.Msg Toggle)
unwrapToggle msg =
    case msg of
        ToggleMsg m ->
            Just m

        _ ->
            Nothing


unwrapSlots : Msg -> Maybe (Drag.Msg Slots)
unwrapSlots msg =
    case msg of
        SlotsMsg m ->
            Just m

        _ ->
            Nothing


unwrapSlider : Msg -> Maybe (Drag.Msg Slider)
unwrapSlider msg =
    case msg of
        SliderMsg m ->
            Just m

        _ ->
            Nothing


unwrapList : Msg -> Maybe (Drag.Msg Lst)
unwrapList msg =
    case msg of
        ListMsg m ->
            Just m

        _ ->
            Nothing


expectTrue : String -> Bool -> Expectation
expectTrue message ok =
    if ok then
        Expect.pass

    else
        Expect.fail message
