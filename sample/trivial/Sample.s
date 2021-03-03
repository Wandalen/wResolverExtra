
let _ = require( 'wresolverextra' );

var src =
{
  dir :
  {
    val1 : 'Hello'
  },
  val2 : 'here',
}

let resolved = _.resolver2.resolve( src, '{::dir/val1} from {::val2}!' );
console.log( resolved );

/*
log : `Hello from here!`
*/
