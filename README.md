
# module::ResolverExtra [![status](https://github.com/Wandalen/wResolverExtra/workflows/publish/badge.svg)](https://github.com/Wandalen/wResolverExtra/actions?query=workflow%3Apublish) [![experimental](https://img.shields.io/badge/stability-experimental-orange.svg)](https://github.com/emersion/stability-badges#experimental)

Collection of cross-platform routines to resolve complex data structures. It takes a complex data structure, traverses it and resolves all strings having inlined special substrings. Use the module to resolve your templates.

## Sample

```js

let _ = require( 'wresolverextra' );

var src =
{
  dir :
  {
    val1 : 'Hello'
  },
  val2 : 'here',
}

let resolved = _.resolverAdv.resolve( src, '{::dir/val1} from {::val2}!' );
console.log( resolved );

/*
log : `Hello from here!`
*/

```

## Try out

```
npm install
node sample/trivial/Sample.s
```

## To add to your project
```
npm add 'wresolverextra@alpha'
```

