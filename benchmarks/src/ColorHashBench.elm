module ColorHashBench exposing (benchmarks)

import Bench exposing (Benchmark)
import Bitwise
import Color exposing (Color)
import Fuzz exposing (Fuzzer)


benchmarks : List Benchmark
benchmarks =
    [ Bench.compareFuzz "color: toCssString vs toRgba floats" colorFuzzer
        ( "mixString (toCssString c)", \color -> hashColorViaCssString color )
        ( "mixFloat (r,g,b,a)", \color -> hashColorViaFloats color )
        |> Bench.skipEqualityCheck
    , Bench.compareFuzz "gradient stop: string vs float hashing" stopsFuzzer
        ( "String-based stop", \s -> hashStopViaString s )
        ( "Float-based stop", \s -> hashStopViaFloats s )
        |> Bench.skipEqualityCheck
    , Bench.compareFuzz "gradient (5 stops): string vs float" gradientFuzzer
        ( "String-based gradient", \g -> hashGradientViaString g )
        ( "Float-based gradient", \g -> hashGradientViaFloats g )
        |> Bench.skipEqualityCheck
    ]


type alias GradientInput =
    { x1 : Float, y1 : Float, x2 : Float, y2 : Float, stops : List StopInput }


type alias StopInput =
    { offset : Float, color : Color, opacity : Float }


colorFuzzer : Fuzzer Color
colorFuzzer =
    Fuzz.map4 Color.rgba
        (Fuzz.floatRange 0 1)
        (Fuzz.floatRange 0 1)
        (Fuzz.floatRange 0 1)
        (Fuzz.floatRange 0 1)


stopsFuzzer : Fuzzer StopInput
stopsFuzzer =
    Fuzz.map3 StopInput
        (Fuzz.floatRange 0 1)
        colorFuzzer
        (Fuzz.floatRange 0 1)


gradientFuzzer : Fuzzer GradientInput
gradientFuzzer =
    Fuzz.map5 GradientInput
        (Fuzz.floatRange 0 1)
        (Fuzz.floatRange 0 1)
        (Fuzz.floatRange 0 1)
        (Fuzz.floatRange 0 1)
        (Fuzz.listOfLength 5 stopsFuzzer)



-- Approach 1: Hash color via toCssString (current)


hashColorViaCssString : Color -> Int
hashColorViaCssString color =
    mixString (Color.toCssString color) 5381


hashStopViaString : StopInput -> Int
hashStopViaString { offset, color, opacity } =
    5381
        |> mixFloat offset
        |> mixString (Color.toCssString color)
        |> mixFloat opacity


hashGradientViaString : GradientInput -> Int
hashGradientViaString { x1, y1, x2, y2, stops } =
    let
        base =
            5381
                |> mixFloat x1
                |> mixFloat y1
                |> mixFloat x2
                |> mixFloat y2
    in
    List.foldl
        (\{ offset, color, opacity } acc ->
            acc
                |> mixFloat offset
                |> mixString (Color.toCssString color)
                |> mixFloat opacity
        )
        base
        stops



-- Approach 2: Hash color via toRgba floats (proposed)


hashColorViaFloats : Color -> Int
hashColorViaFloats color =
    let
        { red, green, blue, alpha } =
            Color.toRgba color
    in
    5381
        |> mixFloat red
        |> mixFloat green
        |> mixFloat blue
        |> mixFloat alpha


hashStopViaFloats : StopInput -> Int
hashStopViaFloats { offset, color, opacity } =
    let
        { red, green, blue, alpha } =
            Color.toRgba color
    in
    5381
        |> mixFloat offset
        |> mixFloat red
        |> mixFloat green
        |> mixFloat blue
        |> mixFloat alpha
        |> mixFloat opacity


hashGradientViaFloats : GradientInput -> Int
hashGradientViaFloats { x1, y1, x2, y2, stops } =
    let
        base =
            5381
                |> mixFloat x1
                |> mixFloat y1
                |> mixFloat x2
                |> mixFloat y2
    in
    List.foldl
        (\{ offset, color, opacity } acc ->
            let
                { red, green, blue, alpha } =
                    Color.toRgba color
            in
            acc
                |> mixFloat offset
                |> mixFloat red
                |> mixFloat green
                |> mixFloat blue
                |> mixFloat alpha
                |> mixFloat opacity
        )
        base
        stops



-- Helpers (copied from Internal to keep benchmark self-contained)


mixInt : Int -> Int -> Int
mixInt value acc =
    Bitwise.xor (acc * 31) value


mixFloat : Float -> Int -> Int
mixFloat value acc =
    Bitwise.xor (acc * 31) (round (value * 1000))


mixString : String -> Int -> Int
mixString str acc =
    String.foldl (\c a -> Bitwise.xor (a * 31) (Char.toCode c)) acc str
