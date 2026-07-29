module RenderBench exposing (benchmarks)

{-| Benchmarks for the construct + render pipeline. These exist to detect
regressions from internal representation changes (e.g. the data-first
refactor enabling `Evg.toString`).

We measure the full path a view function exercises on every update:
building the Evg tree and lowering it to a VirtualDom node.

-}

import Bench exposing (Benchmark)
import Evg exposing (Evg)
import Evg.Internal as Internal
import Evg.Transform as Transform
import Fuzz exposing (Fuzzer)


benchmarks : List Benchmark
benchmarks =
    [ Bench.compareFuzz "200-shape scatter" (Fuzz.listOfLength 200 pointFuzzer)
        ( "construct only", \points -> scatter points |> always () )
        ( "construct + toNode", \points -> scatter points |> Internal.toNode |> always () )
        |> Bench.skipEqualityCheck
    , Bench.compareFuzz "50-group transformed tree" (Fuzz.listOfLength 50 pointFuzzer)
        ( "construct only", \points -> transformedGroups points |> always () )
        ( "construct + toNode", \points -> transformedGroups points |> Internal.toNode |> always () )
        |> Bench.skipEqualityCheck
    ]


pointFuzzer : Fuzzer ( Float, Float )
pointFuzzer =
    Fuzz.pair (Fuzz.floatRange 0 500) (Fuzz.floatRange 0 500)


{-| A typical chart-like scene: many small independent shapes with a few
attributes each.
-}
scatter : List ( Float, Float ) -> Evg msg
scatter points =
    Evg.group []
        (List.map
            (\( x, y ) ->
                Evg.circle
                    [ Evg.fillStr "steelblue"
                    , Evg.strokeStr "white"
                    , Evg.opacity 0.7
                    ]
                    { r = 4, center = ( x, y ) }
            )
            points
        )


{-| A nested scene exercising the transform/matrix path: groups with
transforms containing shapes and labels.
-}
transformedGroups : List ( Float, Float ) -> Evg msg
transformedGroups points =
    Evg.group []
        (List.map
            (\( x, y ) ->
                Evg.group
                    [ Transform.translate x y
                    , Transform.rotate (x / 10)
                    ]
                    [ Evg.rect [ Evg.fillStr "coral" ]
                        { x = -10, y = -10, width = 20, height = 20 }
                    , Evg.text
                        [ Evg.fillStr "black", Evg.fontSize 8 ]
                        { x = 0, y = 0, anchor = Evg.Middle }
                        "x"
                    ]
            )
            points
        )
