module Benchmarks exposing (suite)

import Bench exposing (Benchmark)
import ColorHashBench
import HashBench


suite : Benchmark
suite =
    Bench.describe "Hashing"
        (HashBench.benchmarks ++ ColorHashBench.benchmarks)
