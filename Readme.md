
# module::ResolverExtra [![status](https://github.com/Wandalen/wResolverExtra/actions/workflows/StandardPublish.yml/badge.svg)](https://github.com/Wandalen/wResolverExtra/actions/workflows/StandardPublish.yml) [![experimental](https://img.shields.io/badge/stability-experimental-orange.svg)](https://github.com/emersion/stability-badges#experimental)

Collection of cross-platform routines to resolve complex data structures. It takes a complex data structure, traverses it and resolves all strings having inlined special substrings. Use the module to resolve your templates.

### Try out from the repository

```
git clone https://github.com/Wandalen/wResolverExtra
cd wResolverExtra
will .npm.install
node sample/trivial/Sample.s
```

Make sure you have utility `willbe` installed. To install willbe: `npm i -g willbe@stable`. Willbe is required to build of the module.

### To add to your project

```
npm add 'wresolverextra@stable'
```

`Willbe` is not required to use the module in your project as submodule.

### Sample

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
