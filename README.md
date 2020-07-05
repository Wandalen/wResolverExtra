
# module::ResolverExtra [![Status](https://github.com/Wandalen/wResolverExtra/workflows/Test/badge.svg)](https://github.com/Wandalen/wResolverExtra}/actions?query=workflow%3ATest)

Collection of routines to resolve complex data structures. It takes a complex data structure, traverses it and resolves all strings having inlined special substrings. Use the module to resolve your templates.

## Sample

```js

var _ = require( 'wresolverextra' );

var src =
{
  dir :
  {
    val1 : 'Hello'
  },
  val2 : 'here',
}

let resolved = _.resolver.resolveQualified( src, '{::dir/val1} from {::val2}!' );
console.log( resolved );

/*
log : `Hello from here!`
*/

```

## Try out

```
npm install
node sample/Sample.js
```
