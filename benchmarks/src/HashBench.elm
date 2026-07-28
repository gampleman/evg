module HashBench exposing (benchmarks)

{-| Benchmarks comparing different approaches to content hashing.

We need to generate unique IDs from element content. The current approach
uses String concatenation + a final hash. Alternatives:

1. String concat → hash at the end (current)
2. Incremental Int hash using Bitwise (no intermediate strings)
3. List of strings → String.join → hash
4. Accumulate Int hash at each step (fully streaming)

-}

import Bench exposing (Benchmark)
import Bitwise
import Fuzz exposing (Fuzzer)


benchmarks : List Benchmark
benchmarks =
    [ Bench.compareFuzz "100 rects: string concat vs bitwise" (Fuzz.listOfLength 100 rectFuzzer)
        ( "String concat", \rects -> List.foldl (\{ x, y, w, h, fill } acc -> acc + elementHashStringConcatF x y w h fill) 0 rects )
        ( "Bitwise streaming", \rects -> List.foldl (\{ x, y, w, h, fill } acc -> acc + elementHashBitwiseF x y w h fill) 0 rects )
        |> Bench.skipEqualityCheck
    , Bench.compareFuzz "100 rects: bitwise vs precomputed" (Fuzz.listOfLength 100 rectFuzzer)
        ( "Bitwise streaming", \rects -> List.foldl (\{ x, y, w, h, fill } acc -> acc + elementHashBitwiseF x y w h fill) 0 rects )
        ( "Bitwise precomputed", \rects -> List.foldl (\{ x, y, w, h, fill } acc -> acc + elementHashPrecomputedF x y w h fill) 0 rects )
        |> Bench.skipEqualityCheck
    , Bench.compareFuzz "100 attrs: string fold vs precomputed Int" attrBatchFuzzer
        ( "Bitwise fold strings", \{ strBatches } -> List.foldl (\strs acc -> acc + attrHashBitwise strs) 0 strBatches )
        ( "Precomputed Int fold", \{ intBatches } -> List.foldl (\ints acc -> acc + attrHashPrecomputed ints) 0 intBatches )
        |> Bench.skipEqualityCheck
    , Bench.compareFuzz "Deep tree (100 children): string vs precomputed" (Fuzz.listOfLength 100 treeFuzzer)
        ( "String concat", \batches -> List.foldl (\children acc -> acc + treeHashStringConcatF children) 0 batches )
        ( "Bitwise precomputed", \batches -> List.foldl (\children acc -> acc + treeHashPrecomputedF children) 0 batches )
        |> Bench.skipEqualityCheck
    ]


type alias AttrBatchInput =
    { strBatches : List (List String), intBatches : List (List Int) }


attrBatchFuzzer : Fuzzer AttrBatchInput
attrBatchFuzzer =
    Fuzz.listOfLength 100 attrListFuzzer
        |> Fuzz.map (\batches -> { strBatches = batches, intBatches = List.map (List.map hashStringToInt) batches })




type alias RectInput =
    { x : Float, y : Float, w : Float, h : Float, fill : String }


rectFuzzer : Fuzzer RectInput
rectFuzzer =
    Fuzz.map5 RectInput
        (Fuzz.floatRange 0 500)
        (Fuzz.floatRange 0 500)
        (Fuzz.floatRange 1 200)
        (Fuzz.floatRange 1 200)
        (Fuzz.oneOfValues [ "red", "blue", "#ff8800", "rgb(10,20,30)", "navy", "transparent" ])


type alias ShapeInput =
    { tag : String, x : Float, y : Float, size : Float, fill : String }


sceneFuzzer : Fuzzer (List ShapeInput)
sceneFuzzer =
    Fuzz.listOfLength 5
        (Fuzz.map5 ShapeInput
            (Fuzz.oneOfValues [ "rect", "circle", "ellipse", "path", "polygon" ])
            (Fuzz.floatRange 0 500)
            (Fuzz.floatRange 0 500)
            (Fuzz.floatRange 1 100)
            (Fuzz.oneOfValues [ "red", "blue", "#ff8800", "rgb(10,20,30)", "navy" ])
        )


attrListFuzzer : Fuzzer (List String)
attrListFuzzer =
    Fuzz.listOfLength 8
        (Fuzz.oneOfValues
            [ "fill:red", "fill:blue", "fill:#aabbcc", "stroke:black", "stroke:none"
            , "sw:1", "sw:2", "sw:3.5", "o:0.5", "o:1", "rx:5", "rx:10", "rx:0"
            , "fs:12", "fs:16", "fs:24", "ff:Arial", "transform:rotate(45)"
            ]
        )


treeFuzzer : Fuzzer (List { cx : Float, cy : Float, r : Float, fill : String })
treeFuzzer =
    Fuzz.listOfLength 10
        (Fuzz.map4 (\cx cy r fill -> { cx = cx, cy = cy, r = r, fill = fill })
            (Fuzz.floatRange 0 200)
            (Fuzz.floatRange 0 200)
            (Fuzz.floatRange 1 50)
            (Fuzz.oneOfValues [ "red", "green", "blue", "#123456", "orange" ])
        )



-- Fuzzed implementations


elementHashStringConcatF : Float -> Float -> Float -> Float -> String -> Int
elementHashStringConcatF x y w h fill =
    hashStringToInt
        ("rect"
            ++ String.fromFloat x
            ++ ","
            ++ String.fromFloat y
            ++ ","
            ++ String.fromFloat w
            ++ ","
            ++ String.fromFloat h
            ++ "fill:"
            ++ fill
        )


elementHashBitwiseF : Float -> Float -> Float -> Float -> String -> Int
elementHashBitwiseF x y w h fill =
    5381
        |> mixString "rect"
        |> mixFloat x
        |> mixFloat y
        |> mixFloat w
        |> mixFloat h
        |> mixString fill


sceneHashStringConcatF : List ShapeInput -> Int
sceneHashStringConcatF shapes =
    let
        shapeStr { tag, x, y, size, fill } =
            tag ++ String.fromFloat x ++ "," ++ String.fromFloat y ++ "," ++ String.fromFloat size ++ "fill:" ++ fill
    in
    hashStringToInt ("g{" ++ String.join "," (List.map shapeStr shapes) ++ "}")


sceneHashBitwiseF : List ShapeInput -> Int
sceneHashBitwiseF shapes =
    let
        shapeHash { tag, x, y, size, fill } =
            5381
                |> mixString tag
                |> mixFloat x
                |> mixFloat y
                |> mixFloat size
                |> mixString fill
    in
    List.foldl (\s acc -> mixInt (shapeHash s) acc) (mixString "g" 5381) shapes


attrHashStringConcat : List String -> Int
attrHashStringConcat attrs =
    hashStringToInt (String.join "|" attrs)


attrHashBitwise : List String -> Int
attrHashBitwise attrs =
    List.foldl mixString 5381 attrs


treeHashStringConcatF : List { cx : Float, cy : Float, r : Float, fill : String } -> Int
treeHashStringConcatF children =
    let
        childStr { cx, cy, r, fill } =
            "circle" ++ String.fromFloat cx ++ "," ++ String.fromFloat cy ++ "," ++ String.fromFloat r ++ "fill:" ++ fill
    in
    hashStringToInt ("g{" ++ String.join "," (List.map childStr children) ++ "}")


treeHashBitwiseF : List { cx : Float, cy : Float, r : Float, fill : String } -> Int
treeHashBitwiseF children =
    let
        childHash { cx, cy, r, fill } =
            5381
                |> mixString "circle"
                |> mixFloat cx
                |> mixFloat cy
                |> mixFloat r
                |> mixString fill
    in
    List.foldl (\child acc -> mixInt (childHash child) acc) (mixString "g" 5381) children



-- Precomputed static hash constants
-- These simulate what we'd get if the Attribute type carried Int and
-- constructors like `fillStr` precomputed their hash contribution.


rectTagHash : Int
rectTagHash =
    hashStringToInt "rect"


circleTagHash : Int
circleTagHash =
    hashStringToInt "circle"


fillPrefixHash : Int
fillPrefixHash =
    hashStringToInt "fill:"


gTagHash : Int
gTagHash =
    hashStringToInt "g"


elementHashPrecomputedF : Float -> Float -> Float -> Float -> String -> Int
elementHashPrecomputedF x y w h fill =
    rectTagHash
        |> mixFloat x
        |> mixFloat y
        |> mixFloat w
        |> mixFloat h
        |> mixInt fillPrefixHash
        |> mixString fill


sceneHashPrecomputedF : List ShapeInput -> Int
sceneHashPrecomputedF shapes =
    let
        tagHash tag =
            case tag of
                "rect" ->
                    rectTagHash

                "circle" ->
                    circleTagHash

                _ ->
                    hashStringToInt tag

        shapeHash { tag, x, y, size, fill } =
            tagHash tag
                |> mixFloat x
                |> mixFloat y
                |> mixFloat size
                |> mixInt fillPrefixHash
                |> mixString fill
    in
    List.foldl (\s acc -> mixInt (shapeHash s) acc) gTagHash shapes


attrHashPrecomputed : List Int -> Int
attrHashPrecomputed ints =
    List.foldl mixInt 5381 ints


treeHashPrecomputedF : List { cx : Float, cy : Float, r : Float, fill : String } -> Int
treeHashPrecomputedF children =
    let
        childHash { cx, cy, r, fill } =
            circleTagHash
                |> mixFloat cx
                |> mixFloat cy
                |> mixFloat r
                |> mixInt fillPrefixHash
                |> mixString fill
    in
    List.foldl (\child acc -> mixInt (childHash child) acc) gTagHash children



-- Approach 1: String concatenation (current approach)


hashViaStringConcat5 : Int
hashViaStringConcat5 =
    let
        h =
            "fill:red"
                ++ "|stroke:black"
                ++ "|sw:2"
                ++ "|o:0.5"
                ++ "|rx:10"
    in
    hashStringToInt h


hashStringToInt : String -> Int
hashStringToInt str =
    String.foldl (\c acc -> Bitwise.xor (acc * 31) (Char.toCode c)) 5381 str



-- Approach 2: Bitwise streaming (never builds intermediate string)


hashViaBitwise5 : Int
hashViaBitwise5 =
    5381
        |> mixInt 1
        |> mixFloat 1.0
        |> mixInt 2
        |> mixFloat 0.5
        |> mixFloat 10.0


mixInt : Int -> Int -> Int
mixInt value acc =
    Bitwise.xor (acc * 31) value


mixFloat : Float -> Int -> Int
mixFloat value acc =
    Bitwise.xor (acc * 31) (round (value * 1000))



-- Approach 3: List of strings then join


hashViaListJoin5 : Int
hashViaListJoin5 =
    let
        h =
            String.join "|"
                [ "fill:red"
                , "stroke:black"
                , "sw:2"
                , "o:0.5"
                , "rx:10"
                ]
    in
    hashStringToInt h



-- Approach 4: Bitwise hash of strings (hash each string individually, combine)


hashViaBitwiseStrings5 : Int
hashViaBitwiseStrings5 =
    5381
        |> mixString "fill:red"
        |> mixString "stroke:black"
        |> mixString "sw:2"
        |> mixString "o:0.5"
        |> mixString "rx:10"


mixString : String -> Int -> Int
mixString str acc =
    String.foldl (\c a -> Bitwise.xor (a * 31) (Char.toCode c)) acc str



-- Element hashing benchmarks


elementHashStringConcat : Int
elementHashStringConcat =
    let
        h =
            "rect"
                ++ String.fromFloat 10.0
                ++ ","
                ++ String.fromFloat 20.0
                ++ ","
                ++ String.fromFloat 100.0
                ++ ","
                ++ String.fromFloat 80.0
                ++ "fill:red|stroke:black|sw:2|o:0.5|rx:10"
    in
    hashStringToInt h


elementHashBitwise : Int
elementHashBitwise =
    5381
        |> mixString "rect"
        |> mixFloat 10.0
        |> mixFloat 20.0
        |> mixFloat 100.0
        |> mixFloat 80.0
        |> mixInt 1
        |> mixFloat 1.0
        |> mixInt 2
        |> mixFloat 0.5
        |> mixFloat 10.0


elementHashBitwiseFold : Int
elementHashBitwiseFold =
    5381
        |> mixString "rect"
        |> mixFloat 10.0
        |> mixFloat 20.0
        |> mixFloat 100.0
        |> mixFloat 80.0
        |> mixString "fill:red"
        |> mixString "stroke:black"
        |> mixString "sw:2"
        |> mixString "o:0.5"
        |> mixString "rx:10"



-- Tree hashing benchmarks


treeHashStringConcat : Int
treeHashStringConcat =
    let
        childHash i =
            "circle"
                ++ String.fromFloat (toFloat i * 20)
                ++ ","
                ++ String.fromFloat 50.0
                ++ ","
                ++ String.fromFloat 10.0
                ++ "fill:red|o:0.8"

        treeStr =
            "g{"
                ++ String.join "," (List.map (\i -> childHash i) (List.range 0 9))
                ++ "}"
    in
    hashStringToInt treeStr


treeHashBitwise : Int
treeHashBitwise =
    let
        childHash i =
            5381
                |> mixString "circle"
                |> mixFloat (toFloat i * 20)
                |> mixFloat 50.0
                |> mixFloat 10.0
                |> mixString "fill:red"
                |> mixString "o:0.8"

        treeHash =
            List.foldl
                (\i acc -> mixInt (childHash i) acc)
                (mixString "g" 5381)
                (List.range 0 9)
    in
    treeHash



-- Scene hashing: simulates a realistic clip/mask scenario


sceneHashStringConcat : Int
sceneHashStringConcat =
    let
        rectHash x y w h fill =
            "rect" ++ String.fromFloat x ++ "," ++ String.fromFloat y ++ "," ++ String.fromFloat w ++ "," ++ String.fromFloat h ++ "fill:" ++ fill

        circleHash cx cy r fill =
            "circle" ++ String.fromFloat cx ++ "," ++ String.fromFloat cy ++ "," ++ String.fromFloat r ++ "fill:" ++ fill

        scene =
            "g{"
                ++ rectHash 0 0 100 100 "navy"
                ++ ","
                ++ circleHash 50 50 30 "red"
                ++ ","
                ++ rectHash 10 10 80 80 "#eee"
                ++ ","
                ++ circleHash 75 75 20 "green"
                ++ ","
                ++ rectHash 20 20 60 60 "blue"
                ++ "}"
    in
    hashStringToInt scene


sceneHashBitwise : Int
sceneHashBitwise =
    let
        rectHash x y w h fill =
            5381
                |> mixString "rect"
                |> mixFloat x
                |> mixFloat y
                |> mixFloat w
                |> mixFloat h
                |> mixString fill

        circleHash cx cy r fill =
            5381
                |> mixString "circle"
                |> mixFloat cx
                |> mixFloat cy
                |> mixFloat r
                |> mixString fill

        scene =
            5381
                |> mixString "g"
                |> mixInt (rectHash 0 0 100 100 "navy")
                |> mixInt (circleHash 50 50 30 "red")
                |> mixInt (rectHash 10 10 80 80 "#eee")
                |> mixInt (circleHash 75 75 20 "green")
                |> mixInt (rectHash 20 20 60 60 "blue")
    in
    scene
