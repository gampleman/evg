module SvgToString exposing (toStaticString)

{-| Utility for serializing SVG to strings for documentation generation.

Since VirtualDom nodes can't be directly serialized to strings in Elm,
we use a manual approach: doc modules produce SVG strings directly.

This module provides a helper for wrapping raw SVG content with the
proper XML namespace declaration.

-}


{-| Wraps SVG body content with the proper svg root element and namespace.
-}
toStaticString : { width : Float, height : Float } -> String -> String
toStaticString { width, height } body =
    "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 "
        ++ String.fromFloat width
        ++ " "
        ++ String.fromFloat height
        ++ "\" width=\""
        ++ String.fromFloat width
        ++ "\" height=\""
        ++ String.fromFloat height
        ++ "\">\n"
        ++ body
        ++ "\n</svg>"
