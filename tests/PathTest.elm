module PathTest exposing (measurementTests, roundTripTests, segmentConversionTests, suite, toStringTests)

import Evg.Path exposing (Path(..), PathSegment(..), Segment(..))
import Expect
import Fuzz exposing (Fuzzer)
import Test exposing (Test, describe, fuzz, test)


suite : Test
suite =
    describe "Evg.Path"
        [ toStringTests
        , segmentConversionTests
        , roundTripTests
        , measurementTests
        , smoothCurveTests
        ]


measurementTests : Test
measurementTests =
    describe "measurement and endpoints"
        [ test "endPoint resolves a relative moveto against the previous stroke" <|
            \_ ->
                Evg.Path.endPoint
                    [ M ( 10, 10 ) [ L ( 50, 10 ) ]
                    , Evg.Path.m ( 5, 5 ) [ Evg.Path.l ( 10, 0 ) ]
                    ]
                    |> Expect.equal ( 65, 15 )
        , test "endPoint of a closed stroke is the stroke's start" <|
            \_ ->
                Evg.Path.endPoint [ M ( 10, 20 ) [ L ( 50, 20 ), L ( 50, 50 ), Z ] ]
                    |> Expect.equal ( 10, 20 )
        , test "pathLength includes the closing line of a Z" <|
            \_ ->
                -- A 3-4-5 right triangle: 30 across, 40 down, 50 back.
                Evg.Path.pathLength [ M ( 0, 0 ) [ L ( 30, 0 ), L ( 30, 40 ), Z ] ]
                    |> Expect.within (Expect.Absolute 0.001) 120
        , test "pathLength of a semicircular arc is close to pi * r" <|
            \_ ->
                -- A half circle of radius 40: length should be ~125.66, where
                -- the old chord approximation would give 80.
                Evg.Path.pathLength [ M ( 0, 0 ) [ A 40 40 0 False True ( 80, 0 ) ] ]
                    |> Expect.within (Expect.Absolute 0.5) (pi * 40)
        , test "interpolate at 0.5 of a semicircular arc is the arc's apex, not the chord midpoint" <|
            \_ ->
                -- sweep = True draws in the positive-angle (clockwise on
                -- screen) direction, so this arc bulges upward: the halfway
                -- point is the apex (40, -40), not the chord midpoint (40, 0).
                let
                    ( x, y ) =
                        Evg.Path.interpolate [ M ( 0, 0 ) [ A 40 40 0 False True ( 80, 0 ) ] ] 0.5
                in
                ( x, y )
                    |> Expect.all
                        [ \( px, _ ) -> Expect.within (Expect.Absolute 0.5) 40 px
                        , \( _, py ) -> Expect.within (Expect.Absolute 0.5) -40 py
                        ]
        ]


toStringTests : Test
toStringTests =
    describe "toString"
        [ test "simple line" <|
            \_ ->
                M ( 10, 20 ) [ L ( 30, 40 ) ]
                    |> Evg.Path.toString
                    |> Expect.equal "M10 20L30 40"
        , test "relative commands use lowercase" <|
            \_ ->
                M ( 0, 0 ) [ Evg.Path.l ( 50, 0 ), Evg.Path.v 30, Evg.Path.h -50, Z ]
                    |> Evg.Path.toString
                    |> Expect.equal "M0 0l50 0v30h-50Z"
        , test "MRelative uses lowercase m" <|
            \_ ->
                MRelative ( 10, 20 ) [ Evg.Path.l ( 5, 5 ) ]
                    |> Evg.Path.toString
                    |> Expect.equal "m10 20l5 5"
        , test "cubic bezier" <|
            \_ ->
                M ( 0, 0 ) [ C ( 10, 10 ) ( 20, 20 ) ( 30, 30 ) ]
                    |> Evg.Path.toString
                    |> Expect.equal "M0 0C10 10 20 20 30 30"
        , test "arc with flags" <|
            \_ ->
                M ( 0, 0 ) [ A 50 50 0 True False ( 100, 0 ) ]
                    |> Evg.Path.toString
                    |> Expect.equal "M0 0A50 50 0 1 0 100 0"
        , test "multiple subpaths concatenate" <|
            \_ ->
                [ M ( 0, 0 ) [ L ( 50, 50 ) ], M ( 100, 100 ) [ L ( 150, 150 ) ] ]
                    |> List.map Evg.Path.toString
                    |> String.concat
                    |> Expect.equal "M0 0L50 50M100 100L150 150"
        ]


segmentConversionTests : Test
segmentConversionTests =
    describe "toSegments / fromSegments"
        [ test "line path produces Line segment" <|
            \_ ->
                Evg.Path.toSegments [ M ( 10, 20 ) [ L ( 50, 60 ) ] ]
                    |> Expect.equal [ Line { from = ( 10, 20 ), to = ( 50, 60 ) } ]
        , test "H and V produce Line segments with correct points" <|
            \_ ->
                Evg.Path.toSegments [ M ( 10, 20 ) [ H 80, V 90 ] ]
                    |> Expect.equal
                        [ Line { from = ( 10, 20 ), to = ( 80, 20 ) }
                        , Line { from = ( 80, 20 ), to = ( 80, 90 ) }
                        ]
        , test "cubic bezier produces Cubic segment" <|
            \_ ->
                Evg.Path.toSegments [ M ( 0, 0 ) [ C ( 10, 20 ) ( 30, 40 ) ( 50, 60 ) ] ]
                    |> Expect.equal [ Cubic { from = ( 0, 0 ), controlPoint1 = ( 10, 20 ), controlPoint2 = ( 30, 40 ), to = ( 50, 60 ) } ]
        , test "quadratic bezier produces Quadratic segment" <|
            \_ ->
                Evg.Path.toSegments [ M ( 5, 5 ) [ Q ( 25, 50 ) ( 45, 5 ) ] ]
                    |> Expect.equal [ Quadratic { from = ( 5, 5 ), controlPoint = ( 25, 50 ), to = ( 45, 5 ) } ]
        , test "arc produces Arc segment" <|
            \_ ->
                Evg.Path.toSegments [ M ( 0, 0 ) [ A 40 40 0 True False ( 80, 0 ) ] ]
                    |> Expect.equal [ Arc { from = ( 0, 0 ), rx = 40, ry = 40, rotation = 0, largeArc = True, sweep = False, to = ( 80, 0 ) } ]
        , test "Z becomes an explicit closing Line back to the stroke start" <|
            \_ ->
                Evg.Path.toSegments [ M ( 0, 0 ) [ L ( 50, 0 ), L ( 50, 50 ), Z ] ]
                    |> Expect.equal
                        [ Line { from = ( 0, 0 ), to = ( 50, 0 ) }
                        , Line { from = ( 50, 0 ), to = ( 50, 50 ) }
                        , Line { from = ( 50, 50 ), to = ( 0, 0 ) }
                        ]
        , test "Z with the pen already at the start adds no segment" <|
            \_ ->
                Evg.Path.toSegments [ M ( 0, 0 ) [ L ( 50, 0 ), L ( 0, 0 ), Z ] ]
                    |> List.length
                    |> Expect.equal 2
        , test "relative l resolves to absolute Line" <|
            \_ ->
                Evg.Path.toSegments [ M ( 10, 20 ) [ Evg.Path.l ( 30, 40 ) ] ]
                    |> Expect.equal [ Line { from = ( 10, 20 ), to = ( 40, 60 ) } ]
        , test "relative commands chain correctly" <|
            \_ ->
                Evg.Path.toSegments [ M ( 0, 0 ) [ Evg.Path.l ( 10, 0 ), Evg.Path.l ( 0, 10 ), Evg.Path.l ( -10, 0 ) ] ]
                    |> Expect.equal
                        [ Line { from = ( 0, 0 ), to = ( 10, 0 ) }
                        , Line { from = ( 10, 0 ), to = ( 10, 10 ) }
                        , Line { from = ( 10, 10 ), to = ( 0, 10 ) }
                        ]
        , test "multiple subpaths produce segments from each" <|
            \_ ->
                Evg.Path.toSegments
                    [ M ( 0, 0 ) [ L ( 50, 0 ) ]
                    , M ( 100, 100 ) [ L ( 150, 100 ) ]
                    ]
                    |> Expect.equal
                        [ Line { from = ( 0, 0 ), to = ( 50, 0 ) }
                        , Line { from = ( 100, 100 ), to = ( 150, 100 ) }
                        ]
        , test "fromSegments with continuous segments produces one path" <|
            \_ ->
                Evg.Path.fromSegments
                    [ Line { from = ( 0, 0 ), to = ( 50, 0 ) }
                    , Line { from = ( 50, 0 ), to = ( 50, 50 ) }
                    ]
                    |> Expect.equal [ M ( 0, 0 ) [ L ( 50, 0 ), L ( 50, 50 ) ] ]
        , test "fromSegments with discontinuity produces multiple paths" <|
            \_ ->
                Evg.Path.fromSegments
                    [ Line { from = ( 0, 0 ), to = ( 50, 0 ) }
                    , Line { from = ( 100, 100 ), to = ( 150, 100 ) }
                    ]
                    |> Expect.equal
                        [ M ( 0, 0 ) [ L ( 50, 0 ) ]
                        , M ( 100, 100 ) [ L ( 150, 100 ) ]
                        ]
        , test "fromSegments empty list produces empty list" <|
            \_ ->
                Evg.Path.fromSegments []
                    |> Expect.equal []
        ]


roundTripTests : Test
roundTripTests =
    describe "round-trip (toSegments >> fromSegments)"
        [ test "simple line round-trips" <|
            \_ ->
                let
                    original =
                        [ M ( 10, 20 ) [ L ( 50, 60 ), L ( 90, 20 ) ] ]

                    roundTripped =
                        Evg.Path.toSegments original |> Evg.Path.fromSegments
                in
                roundTripped |> Expect.equal original
        , test "cubic bezier round-trips" <|
            \_ ->
                let
                    original =
                        [ M ( 0, 0 ) [ C ( 10, 20 ) ( 30, 40 ) ( 50, 0 ) ] ]

                    roundTripped =
                        Evg.Path.toSegments original |> Evg.Path.fromSegments
                in
                roundTripped |> Expect.equal original
        , test "multiple subpaths round-trip" <|
            \_ ->
                let
                    original =
                        [ M ( 0, 0 ) [ L ( 50, 0 ), L ( 50, 50 ) ]
                        , M ( 100, 100 ) [ L ( 150, 100 ) ]
                        ]

                    roundTripped =
                        Evg.Path.toSegments original |> Evg.Path.fromSegments
                in
                roundTripped |> Expect.equal original
        , fuzz segmentListFuzzer "fuzz: continuous segments round-trip through toSegments >> fromSegments" <|
            \segments ->
                let
                    paths =
                        Evg.Path.fromSegments segments

                    backToSegments =
                        Evg.Path.toSegments paths
                in
                backToSegments |> Expect.equal segments
        , fuzz absolutePathFuzzer "fuzz: path -> segments -> path preserves geometry" <|
            \paths ->
                let
                    segments =
                        Evg.Path.toSegments paths

                    backToPaths =
                        Evg.Path.fromSegments segments

                    backToSegments =
                        Evg.Path.toSegments backToPaths
                in
                backToSegments |> Expect.equal segments
        , fuzz absolutePathFuzzer "fuzz: the round trip preserves path length" <|
            -- `fromSegments` writes every control point out explicitly, so a
            -- second pass must measure the same curve. This checks the two
            -- conversions agree with each other; the test below is what
            -- checks they agree with the specification.
            \paths ->
                let
                    original =
                        Evg.Path.pathLength paths

                    roundTripped =
                        Evg.Path.pathLength
                            (Evg.Path.fromSegments (Evg.Path.toSegments paths))
                in
                roundTripped
                    |> Expect.within (Expect.Relative 1.0e-6) original
        , fuzz shorthandPathFuzzer "fuzz: shorthand curves measure the same as spelled-out ones" <|
            -- The real test of the smooth shorthands. Each S or T is replaced
            -- by the C or Q it stands for, with the implied control point
            -- worked out here rather than by the code under test, and the two
            -- paths must have the same length. A shorthand resolved to the
            -- wrong control point describes a different curve, so its length
            -- differs.
            --
            -- Round-tripping cannot check this: `pathLength` is defined in
            -- terms of `toSegments`, so it appears on both sides of a
            -- round-trip property and any error it makes cancels out.
            \paths ->
                Evg.Path.pathLength (List.map Tuple.second paths)
                    |> Expect.within (Expect.Relative 1.0e-6)
                        (Evg.Path.pathLength (List.map Tuple.first paths))
        ]


pointFuzzer : Fuzzer ( Float, Float )
pointFuzzer =
    Fuzz.map2 Tuple.pair
        (Fuzz.floatRange -200 200)
        (Fuzz.floatRange -200 200)


segmentFuzzer : ( Float, Float ) -> Fuzzer Segment
segmentFuzzer from =
    Fuzz.oneOf
        [ Fuzz.map (\to -> Line { from = from, to = to }) pointFuzzer
        , Fuzz.map2 (\cp to -> Quadratic { from = from, controlPoint = cp, to = to })
            pointFuzzer
            pointFuzzer
        , Fuzz.map3 (\cp1 cp2 to -> Cubic { from = from, controlPoint1 = cp1, controlPoint2 = cp2, to = to })
            pointFuzzer
            pointFuzzer
            pointFuzzer
        , Fuzz.map4
            (\rx ry to sweep -> Arc { from = from, rx = abs rx + 1, ry = abs ry + 1, rotation = 0, largeArc = False, sweep = sweep, to = to })
            (Fuzz.floatRange 1 50)
            (Fuzz.floatRange 1 50)
            pointFuzzer
            Fuzz.bool
        ]


segmentListFuzzer : Fuzzer (List Segment)
segmentListFuzzer =
    pointFuzzer
        |> Fuzz.andThen
            (\start ->
                Fuzz.listOfLengthBetween 1 5 (segmentFuzzer start)
                    |> Fuzz.map (makeContinuous start)
            )


makeContinuous : ( Float, Float ) -> List Segment -> List Segment
makeContinuous start segments =
    let
        go current remaining acc =
            case remaining of
                [] ->
                    List.reverse acc

                seg :: rest ->
                    let
                        fixed =
                            setFrom current seg

                        next =
                            segmentToPoint fixed
                    in
                    go next rest (fixed :: acc)
    in
    go start segments []


setFrom : ( Float, Float ) -> Segment -> Segment
setFrom from seg =
    case seg of
        Line r ->
            Line { r | from = from }

        Quadratic r ->
            Quadratic { r | from = from }

        Cubic r ->
            Cubic { r | from = from }

        Arc r ->
            Arc { r | from = from }


segmentToPoint : Segment -> ( Float, Float )
segmentToPoint seg =
    case seg of
        Line { to } ->
            to

        Quadratic { to } ->
            to

        Cubic { to } ->
            to

        Arc { to } ->
            to


{-| Paths mixing absolute and relative commands, and both kinds of subpath
start, since the two are resolved by different code.
-}
absolutePathFuzzer : Fuzzer (List Path)
absolutePathFuzzer =
    Fuzz.listOfLengthBetween 1
        3
        (Fuzz.map3
            (\relativeStart start segs ->
                if relativeStart then
                    MRelative start segs

                else
                    M start segs
            )
            Fuzz.bool
            pointFuzzer
            (Fuzz.listOfLengthBetween 1 4 pathSegmentFuzzer)
        )


{-| Either an absolute command or its relative counterpart.
-}
pathSegmentFuzzer : Fuzzer PathSegment
pathSegmentFuzzer =
    Fuzz.oneOf
        [ absolutePathSegmentFuzzer
        , relativePathSegmentFuzzer
        ]


relativePathSegmentFuzzer : Fuzzer PathSegment
relativePathSegmentFuzzer =
    Fuzz.oneOf
        [ Fuzz.map Evg.Path.l pointFuzzer
        , Fuzz.map Evg.Path.h (Fuzz.floatRange -100 100)
        , Fuzz.map Evg.Path.v (Fuzz.floatRange -100 100)
        , Fuzz.map2 Evg.Path.q pointFuzzer pointFuzzer
        , Fuzz.map3 Evg.Path.c pointFuzzer pointFuzzer pointFuzzer
        , Fuzz.map2 Evg.Path.s pointFuzzer pointFuzzer
        , Fuzz.map Evg.Path.t pointFuzzer
        , Fuzz.map4
            (\rx ry to sweep -> Evg.Path.a (abs rx + 1) (abs ry + 1) 0 False sweep to)
            (Fuzz.floatRange 1 50)
            (Fuzz.floatRange 1 50)
            pointFuzzer
            Fuzz.bool
        ]


absolutePathSegmentFuzzer : Fuzzer PathSegment
absolutePathSegmentFuzzer =
    Fuzz.oneOf
        [ Fuzz.map L pointFuzzer
        , Fuzz.map2 (\cp to -> Q cp to) pointFuzzer pointFuzzer
        , Fuzz.map3 (\cp1 cp2 to -> C cp1 cp2 to) pointFuzzer pointFuzzer pointFuzzer

        -- The smooth shorthands matter here: their control points are implied
        -- by the preceding segment, so they are the ones most likely to be
        -- resolved wrongly.
        , Fuzz.map2 (\cp2 to -> S cp2 to) pointFuzzer pointFuzzer
        , Fuzz.map T pointFuzzer
        , Fuzz.map4
            (\rx ry to sweep -> A (abs rx + 1) (abs ry + 1) 0 False sweep to)
            (Fuzz.floatRange 1 50)
            (Fuzz.floatRange 1 50)
            pointFuzzer
            Fuzz.bool
        ]


smoothCurveTests : Test
smoothCurveTests =
    describe "smooth curve control point reflection"
        [ test "S reflects the previous cubic's second control point" <|
            -- Spec example: M100,200 C100,100 250,100 250,200 S400,300 400,200
            -- The implied cp1 is (250,100) mirrored through (250,200).
            \_ ->
                Evg.Path.toSegments
                    [ M ( 100, 200 )
                        [ C ( 100, 100 ) ( 250, 100 ) ( 250, 200 )
                        , S ( 400, 300 ) ( 400, 200 )
                        ]
                    ]
                    |> List.drop 1
                    |> Expect.equal
                        [ Cubic
                            { from = ( 250, 200 )
                            , controlPoint1 = ( 250, 300 )
                            , controlPoint2 = ( 400, 300 )
                            , to = ( 400, 200 )
                            }
                        ]
        , test "T reflects the previous quadratic's control point" <|
            -- Spec example: M200,300 Q400,50 600,300 T1000,300
            \_ ->
                Evg.Path.toSegments
                    [ M ( 200, 300 )
                        [ Q ( 400, 50 ) ( 600, 300 )
                        , T ( 1000, 300 )
                        ]
                    ]
                    |> List.drop 1
                    |> Expect.equal
                        [ Quadratic
                            { from = ( 600, 300 )
                            , controlPoint = ( 800, 550 )
                            , to = ( 1000, 300 )
                            }
                        ]
        , test "S after a non-curve uses the current point" <|
            \_ ->
                Evg.Path.toSegments
                    [ M ( 0, 0 ) [ L ( 10, 0 ), S ( 20, 10 ) ( 30, 0 ) ] ]
                    |> List.drop 1
                    |> Expect.equal
                        [ Cubic
                            { from = ( 10, 0 )
                            , controlPoint1 = ( 10, 0 )
                            , controlPoint2 = ( 20, 10 )
                            , to = ( 30, 0 )
                            }
                        ]
        , test "S does not chain off a quadratic" <|
            -- Smooth cubics only continue cubics, so this falls back rather
            -- than reflecting the quadratic's control point.
            \_ ->
                Evg.Path.toSegments
                    [ M ( 0, 0 ) [ Q ( 5, 5 ) ( 10, 0 ), S ( 20, 10 ) ( 30, 0 ) ] ]
                    |> List.drop 1
                    |> Expect.equal
                        [ Cubic
                            { from = ( 10, 0 )
                            , controlPoint1 = ( 10, 0 )
                            , controlPoint2 = ( 20, 10 )
                            , to = ( 30, 0 )
                            }
                        ]
        , test "consecutive T commands keep reflecting" <|
            \_ ->
                Evg.Path.toSegments
                    [ M ( 0, 0 ) [ Q ( 10, -10 ) ( 20, 0 ), T ( 40, 0 ), T ( 60, 0 ) ] ]
                    |> List.map
                        (\seg ->
                            case seg of
                                Quadratic { controlPoint } ->
                                    controlPoint

                                _ ->
                                    ( 0, 0 )
                        )
                    |> Expect.equal [ ( 10, -10 ), ( 30, 10 ), ( 50, -10 ) ]
        , test "the relative s reflects too" <|
            \_ ->
                Evg.Path.toSegments
                    [ M ( 100, 200 )
                        [ C ( 100, 100 ) ( 250, 100 ) ( 250, 200 )
                        , Evg.Path.s ( 150, 100 ) ( 150, 0 )
                        ]
                    ]
                    |> List.drop 1
                    |> Expect.equal
                        [ Cubic
                            { from = ( 250, 200 )
                            , controlPoint1 = ( 250, 300 )
                            , controlPoint2 = ( 400, 300 )
                            , to = ( 400, 200 )
                            }
                        ]
        ]


{-| Pairs of paths that must describe the same shape: the first uses the
smooth shorthands `S` and `T`, the second spells out the `C` and `Q` they
stand for. The implied control point is computed here, so the pair is built
independently of the code being tested.
-}
shorthandPathFuzzer : Fuzzer (List ( Path, Path ))
shorthandPathFuzzer =
    Fuzz.listOfLengthBetween 1
        3
        (Fuzz.map2
            (\start steps ->
                let
                    ( shorthand, expanded ) =
                        buildShorthandPair start steps
                in
                ( M start shorthand, M start expanded )
            )
            pointFuzzer
            (Fuzz.listOfLengthBetween 1 5 curveStepFuzzer)
        )


{-| One step of a smooth-curve chain: either an explicit curve, or the
shorthand that continues it.
-}
type CurveStep
    = ExplicitCubic ( Float, Float ) ( Float, Float ) ( Float, Float )
    | ExplicitQuadratic ( Float, Float ) ( Float, Float )
    | StraightLine ( Float, Float )
    | SmoothCubic ( Float, Float ) ( Float, Float )
    | SmoothQuadratic ( Float, Float )


curveStepFuzzer : Fuzzer CurveStep
curveStepFuzzer =
    Fuzz.oneOf
        [ Fuzz.map3 ExplicitCubic pointFuzzer pointFuzzer pointFuzzer
        , Fuzz.map2 ExplicitQuadratic pointFuzzer pointFuzzer
        , Fuzz.map StraightLine pointFuzzer
        , Fuzz.map2 SmoothCubic pointFuzzer pointFuzzer
        , Fuzz.map SmoothQuadratic pointFuzzer
        ]


{-| Turn the steps into the shorthand form and the spelled-out form at once,
tracking the pen position and the control point a shorthand would mirror.
-}
buildShorthandPair : ( Float, Float ) -> List CurveStep -> ( List PathSegment, List PathSegment )
buildShorthandPair start steps =
    let
        -- The previous control point is only mirrored when the previous
        -- command was a curve of the *same* family: cubics continue cubics,
        -- quadratics continue quadratics. Otherwise the implied control point
        -- sits on the current point.
        go current lastCubic lastQuad remaining shortAcc longAcc =
            case remaining of
                [] ->
                    ( List.reverse shortAcc, List.reverse longAcc )

                step :: rest ->
                    let
                        ( cx, cy ) =
                            current

                        mirror maybeControl =
                            case maybeControl of
                                Just ( px, py ) ->
                                    ( 2 * cx - px, 2 * cy - py )

                                Nothing ->
                                    current
                    in
                    case step of
                        ExplicitCubic cp1 cp2 to ->
                            go to (Just cp2) Nothing rest (C cp1 cp2 to :: shortAcc) (C cp1 cp2 to :: longAcc)

                        ExplicitQuadratic cp to ->
                            go to Nothing (Just cp) rest (Q cp to :: shortAcc) (Q cp to :: longAcc)

                        StraightLine to ->
                            -- Breaks both chains: a following shorthand has no
                            -- matching curve to continue.
                            go to Nothing Nothing rest (L to :: shortAcc) (L to :: longAcc)

                        SmoothCubic cp2 to ->
                            go to (Just cp2) Nothing rest (S cp2 to :: shortAcc) (C (mirror lastCubic) cp2 to :: longAcc)

                        SmoothQuadratic to ->
                            let
                                implied =
                                    mirror lastQuad
                            in
                            go to Nothing (Just implied) rest (T to :: shortAcc) (Q implied to :: longAcc)
    in
    go start Nothing Nothing steps [] []
