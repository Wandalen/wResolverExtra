
# wResolverExtra [![Build Status](https://travis-ci.org/Wandalen/wResolverExtra.svg?branch=master)](https://travis-ci.org/Wandalen/wResolverExtra)

Collection of routines to resolve complex data structures. It takes a complex data structure, traverses it and resolves all strings having inlined special substrings. Use the module to resolve your templates.

## Sample

```
var _ = require( 'wresolverextra' );
var src =
{
  dir :
  {
    val1 : 'Hello'
  },
  val2 : 'here',
}

let resolved = _.Resolver.resolve
({
  src : src,
  selector : '{::dir/val1} from {::val2}!',
});

console.log( resolved );

/*
`Hello from here!`
*/
```

## Try out

```
npm install
node sample/Sample.js
```
