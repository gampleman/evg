# Elm Vector Graphics (evg)

> The API is a bit wonky
>
> -- [elm/svg](https://package.elm-lang.org/packages/elm/svg/latest/)

A vector graphics library. It aims to have significantly better DX than similar Elm libraries (i.e. not a _wonky API_) while maintaining appropriate type safety and maintaining the expressivity of the underlying SVG spec.
What that means is we want very high developer ergonomics while _not_ being a ["toy library"](https://package.elm-lang.org/packages/evancz/elm-playground/latest/Playground).

We achieve this by using several important principles:

1. In practice, SVG programming requires certain attributes to be present. So we make them required positional arguments:

   ```elm
   Evg.line [] (startX, startY) (endX, endY)

   -- vs
   Svg.line
       [ Svg.Attribute.x1 startX
       , Svg.Attribute.y1 startY
       , Svg.Attribute.x2 endX
       , Scg.Attribute.y2 endY
       ]
       []
   ```

2. We make things take real types rather than just strings:

   ```elm
   Evg.rect [ Evg.cornerRadius 4 ]
       { x = startX
       , y = startY
       , width = 50
       , height = startY - 40
       }

   -- vs
   Svg.rect
       [ Svg.Attribute.x (String.fromFloat startX)
       , Svg.Attribute.y (String.fromFloat startY)
       , Svg.Attribute.width "50"
       , Svg.Attribute.height (String.fromFloat (startY - 40))
       , Svg.Attribute.rx "4"
       ]
       []
   ```

3. We omit the children argument from most shapes, since it's rarely needed. For the few things that do need it, we just allow you to mix it in with the attributes:

   ```elm
   Evg.line
        [ Evg.title "A nice line"
        , Evg.desc "This line will change your life"
        , Evg.stroke (Evg.Paint.solid Color.gray)
        ]
        (startX, startY)
        (endX, endY)

   -- vs
   TypedSvg.line
        [ TypedSvg.Attributes.stroke (TypedSvg.Types.Paint Color.gray)
        , TypedSvg.Attributes.InPx.x1 startX
        , TypedSvg.Attributes.InPx.y1 startY
        , TypedSvg.Attributes.InPx.x2 endX
        , TypedSvg.Attributes.InPx.y2 endY
        ]
        [ TypedSvg.title [] [ TypedSvg.Core.text "A nice line"]
        , TypedSvg.desc []
            [ TypedSvg.Core.text "This line will change your life"
            ]
        ]
   ```

4. We avoid IDs like the plague. SVG is essentially a functional program serialized as XML, and so to have references between different elements, it needs
   to name them. However, we are using an actual programming language to construct it, so we already have first class references! So having to invent stringified
   ones is a waste (and it also tends to kill IDE like functionality like Go to defintion). But a worse sin is that IDs can kill composition. IDs need to be globally
   unique for the references to work properly, so if you have a function that relies on IDs for it to work, you can't just call it willy-nilly. You have to ensure
   that the IDs get properly generated. That can also enable spooky action at a distance, since changing an ID in one place in your codebase can make it accidentally
   collide with an ID somewhere else. We avoid this by simply not exposing IDs in the source language at all (and we use fast content-hashing under the hood to generate
   unique IDs).

   ```elm
   splashText  =
      let
          bottomSplash =
              Filter.sourceAlpha
                  |> Filter.gaussianBlur 6.5
                  |> Filter.displacementMap [] { scale = 420 }
                      (Filter.fractalNoise
                          { baseFrequency = 0.05
                          , numOctaves = 1
                          , seed = 1
                          }
                      )
                  |> Filter.compositeIn (Filter.floodStr "#16B5FF")

          filter =
              bottomSplash
                  |> Filter.gaussianBlur 2
                  |> Filter.specularLighting
                      { surfaceScale = 5
                      , specularConstant = 0.75
                      , specularExponent = 30
                      , lightingColor = "white"
                      , light = Filter.pointLight { x = -50,  y = -100, z = 400 }
                      }

      in
      Evg.text
          [ Evg.fillStr "#16B5FF"
          , Evg.filter [] filter
          ]
          Evg.Start
          "Hello"

   -- vs
   splashText  =
      Svg.g []
         [ Svg.defs []
           [ Svg.filter
               [ Svg.Attributes.id "my-filter" -- better hope that's unique
               ]
               [ Svg.feFlood [ Svg.Attributes.floodColor "#16B5FF", Svg.Attributes.result "COLOR-blue" ] []
               , Svg.feTurbulence
                   [ Svg.Attributes.baseFrequency "0.05"
                   , Svg.Attributes.type_ "fractalNoise"
                   , Svg.Attributes.numOctaves "1"
                   , Svg.Attributes.seed "1"
                   , Svg.Attributes.result "BOTTOM-SPLASH_10"
                   ]
                   []
               , Svg.feGaussianBlur
                   [ Svg.Attributes.stdDeviation "6.5"
                   , Svg.Attributes.in_ "SourceAlpha"
                   , Svg.Attributes.result "BOTTOM-SPLASH_20"
                   ]
                   []
               , Svg.feDisplacementMap
                   [ Svg.Attributes.scale "420"
                   , Svg.Attributes.in_ "BOTTOM-SPLASH_20"
                   , Svg.Attributes.in2 "BOTTOM-SPLASH_10"
                   , Svg.Attributes.result "BOTTOM-SPLASH_30"
                   ]
                   []
               , Svg.feComposite
                   [ Svg.Attributes.operator "in"
                   , Svg.Attributes.in_ "COLOR-blue"
                   , Svg.Attributes.in2 "BOTTOM-SPLASH_30"
                   , Svg.Attributes.result "BOTTOM-SPLASH_40"
                   ]
                   []
               , Svg.feGaussianBlur
                   [ Svg.Attributes.stdDeviation "2"
                   , Svg.Attributes.in_ "BOTTOM-SPLASH_40"
                   , Svg.Attributes.result "LIGHT-EFFECTS_30"
                   ]
                   []
               , Svg.feSpecularLighting
                   [ Svg.Attributes.surfaceScale "5"
                   , Svg.Attributes.specularConstant ".75"
                   , Svg.Attributes.specularExponent "30"
                   , Svg.Attributes.lightingColor "#white"
                   , Svg.Attributes.in_ "LIGHT-EFFECTS_30"
                   , Svg.Attributes.result "LIGHT-EFFECTS_40"
                   ]
                   [ Svg.fePointLight
                       [ Svg.Attributes.x "-50"
                       , Svg.Attributes.y "-100"
                       , Svg.Attributes.z "400"
                       ]
                       []
                   ]
               ]
           ]
       , Svg.text_
           [ Svg.Attributes.fontSize "160px"
           , Svg.Attributes.x "320"
           , Svg.Attributes.y "170"
           , Svg.Attributes.textAnchor "middle"
           , Svg.Attributes.fill "#16B5FF"
           , Svg.Attributes.filter "url(#my-filter)"
           ]
           [ Svg.text "Evg" ]
       ]

   ```

   As you can see, SVG filters particularly benefit from this, since it enables writing them in pipeline style. This makes them much easier to understand and use!

5. We provide convenience when it's handy. This means we have short cut methods for very common operations, such as `Evg.strokeStr "#000"` vs the more flexible `Evg.stroke (Evg.Paint.solid (Color.rgb 0 0 0))` or `Evg.Filter.gaussianBlur 5` vs `Evg.Filter.gaussianBlurXY 5 5` and so on.

6. Modules are task oriented rather than syntactic. Other libraries tend to follow the elements/attributes/events/lazy model in organizing their modules, which often means that for even simple tasks you need to import nearly all of them. We tend to have everything you need for a simple graphic
   available right in `Evg`. Do you need to add masking? Import `Evg.Mask`. Animation? Import `Evg.Animate`, and so on.

7. Documentation. Other libraries assumes you have perfect knowledge of SVG and all you want from the library docs is to understand the Elm layer on top of it. Our documentation aims to explain how to actually use the stuff provided, so you don't have to be constantly cross-referencing MDN when using it (and instead just get docs straight in your IDE).

8. Our job doesn't just end with just generating XML. We provide a number of handy features above and beyond what other libraries provide, such as:
   - `Evg.toString`: sometimes you want to turn your drawing into a downloadable format
   - `Evg.Animate.keyframes`: an animation engine built in that allows you to set up complex animation that get turned into low level SMIL automatically.
   - `Evg.Path` helpers: a whole suite of helpers to help do path related computations, such as length, interpolation and so on.
   - `Evg.Events` include complex decoders that ensure you get the coordinates in a format that is usable for common graphics interation such as drags, pinches, etc.

As you can see, we take ergonomics very seriously. Browse our [comparison page](https://code.gampleman.eu/evg/) to see how code in Evg compares to other popular libraries.

## When not to use this

elm/svg has one great usecase for which this library is _not_ optimized: it is often a handy way to include icons and other assets created in graphics programs for renderin in Elm applications. There tooling can mechanically convert from XML code to elm/svg with no trouble, since it's an extremely mechanical conversion. This library is intended more for _graphics programming_, where images are generated dynamically and the code will need to be read, understood and maintained - not just an export format to be overwritten.

## License

MIT (c) Jakub Hampl 2026
