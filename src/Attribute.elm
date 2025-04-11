module Attribute exposing (..)


type Attribute extend contract msg
    = Builtin msg
    | Custom (extend -> extend)


type Supported
    = Supported


attr : (extend -> extend) -> Attribute extend contract msg
attr f =
    Custom f


foo : String -> Attribute { extend | foo : String } { contract | foo : Supported } msg
foo value =
    attr
        (\extend ->
            { extend
                | foo = value
            }
        )
