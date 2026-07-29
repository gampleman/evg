module Benchmarks exposing (suite)

import Bench exposing (Benchmark)
import ColorHashBench
import HashBench
import RenderBench


suite : Benchmark
suite =
    Bench.describe "Evg"
        [ Bench.describe "Hashing"
            (HashBench.benchmarks ++ ColorHashBench.benchmarks)
        , Bench.describe "Rendering"
            RenderBench.benchmarks
        ]
