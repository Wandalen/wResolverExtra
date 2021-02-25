( function _ResolverExtra_test_s_()
{

'use strict';

if( typeof module !== 'undefined' )
{

  let _ = require( '../../../wtools/Tools.s' );

  _.include( 'wTesting' );
  _.include( 'wLogger' );

  require( '../l7/ResolverExtra.s' );

}

let _global = _global_;
let _ = _global_.wTools;

// --
// tests
// --

function selectorParse( test )
{
  let self = this;
  let r = _.resolver2;

  test.case = 'single inline, single split';
  var expected = [ [ [ 'a', '::', 'b' ] ] ]
  var got = r.selectorParse( '{a::b}' );
  test.identical( got, expected );

  test.case = 'implicit inline, single split';
  var expected = [ [ [ 'a', '::', 'b' ] ] ]
  var got = r.selectorParse( 'a::b' );
  test.identical( got, expected );

  test.case = 'single inline, several splits';
  var expected =
  [
    [
      [ 'a', '::', 'b' ],
      [ 'c', '::', 'd' ]
    ],
  ]
  var got = r.selectorParse( '{a::b/c::d}' );
  test.identical( got, expected );

  test.case = 'implicit inline, several splits';
  var expected =
  [
    [
      [ 'a', '::', 'b' ],
      [ 'c', '::', 'd' ]
    ],
  ]
  var got = r.selectorParse( 'a::b/c::d' );
  test.identical( got, expected );

  test.case = 'single inline, several splits, non-selector sides';
  var expected =
  [
    'x',
    [
      [ 'a', '::', 'b' ],
      [ 'c', '::', 'd' ]
    ],
    'y'
  ]
  var got = r.selectorParse( 'x{a::b/c::d}y' );
  test.identical( got, expected );

  test.case = 'several inlines';
  var expected =
  [
    'x',
    [
      [ 'a', '::', 'b' ],
      [ 'c', '::', 'd' ]
    ],
    'y',
    [
      [ 'ee', '::', 'ff' ],
      [ 'gg', '::', 'hhh' ]
    ],
    'z',
  ]
  var got = r.selectorParse( 'x{a::b/c::d}y{ee::ff/gg::hhh}z' );
  test.identical( got, expected );

  test.case = 'several inlines, split without ::';
  var expected =
  [
    'x',
    [
      [ 'a', '::', 'b' ],
      [ '', '', 'mid' ],
      [ 'c', '::', 'd' ]
    ],
    'y',
    [
      [ 'ee', '::', 'ff' ],
      [ 'gg', '::', 'hhh' ]
    ],
    'z',
  ]
  var got = r.selectorParse( 'x{a::b/mid/c::d}y{ee::ff/gg::hhh}z' );
  test.identical( got, expected );

  test.case = 'critical, no ::';
  var expected = [ 'x{mid}y{}z' ]
  var got = r.selectorParse( 'x{mid}y{}z' );
  test.identical( got, expected );

  test.case = 'critical, empty side';
  var expected =
  [
    'x',
    [ [ 'aa', '::', '' ] ],
    'y',
    [ [ '', '::', 'bb' ] ],
    'z',
    [ [ '', '::', '' ] ]
  ]
  var got = r.selectorParse( 'x{aa::}y{::bb}z{::}' );
  test.identical( got, expected );

}

//

function selectorNormalize( test )
{
  let self = this;
  let r = _.resolver2;

  test.case = 'single inline, single split';
  var expected = '{a::b}';
  var got = r.selectorNormalize( '{a::b}' );
  test.identical( got, expected );

  test.case = 'implicit inline, single split';
  var expected = '{a::b}'
  var got = r.selectorNormalize( 'a::b' );
  test.identical( got, expected );

  test.case = 'single inline, several splits';
  var expected = '{a::b/c::d}';
  var got = r.selectorNormalize( '{a::b/c::d}' );
  test.identical( got, expected );

  test.case = 'implicit inline, several splits';
  var expected = '{a::b/c::d}';
  var got = r.selectorNormalize( 'a::b/c::d' );
  test.identical( got, expected );

  test.case = 'single inline, several splits, non-selector sides';
  var expected = 'x{a::b/c::d}y';
  var got = r.selectorNormalize( 'x{a::b/c::d}y' );
  test.identical( got, expected );

  test.case = 'several inlines';
  var expected = 'x{a::b/c::d}y{ee::ff/gg::hhh}z';
  var got = r.selectorNormalize( 'x{a::b/c::d}y{ee::ff/gg::hhh}z' );
  test.identical( got, expected );

  test.case = 'several inlines, split without ::';
  var expected = 'x{a::b/mid/c::d}y{ee::ff/gg::hhh}z';
  var got = r.selectorNormalize( 'x{a::b/mid/c::d}y{ee::ff/gg::hhh}z' );
  test.identical( got, expected );

  test.case = 'critical, no ::';
  var expected = 'x{mid}y{}z';
  var got = r.selectorNormalize( 'x{mid}y{}z' );
  test.identical( got, expected );

  test.case = 'critical, empty side';
  var expected = 'x{aa::}y{::bb}z{::}';
  var got = r.selectorNormalize( 'x{aa::}y{::bb}z{::}' );
  test.identical( got, expected );

}

//

function iteratorResult( test )
{

  var src =
  {
    a : { map : { name : 'name1' }, value : 13 },
    b : { b1 : 1, b2 : 'b2' },
    c : { c1 : 1, c2 : 'c2' },
  }

  /* */

  test.case = 'control';
  var expected = [ 'b2', { a : 'c', b : 'name1' } ];
  var got = _.resolver2.resolveQualified( src, [ '::b/b2', { a : 'c', b : '::a/map' } ] );
  test.identical( got, expected );
  test.true( got[ 0 ] === src.b.b2 );

  var expected =
  {
    a : { map : { name : 'name1' }, value : 13 },
    b : { b1 : 1, b2 : 'b2' },
    c : { c1 : 1, c2 : 'c2' },
  }
  test.identical( src, expected );

  /* */

  test.case = 'iterator.result';
  var expected = [ 'b2', { a : 'c', b : 'name1' } ];
  var it = _.resolver2.resolveQualified.head( _.resolver2.resolveQualified, [ src, [ '::b/b2', { a : 'c', b : '::a/map' } ] ] );
  var got = it.perform();
  test.true( got === it );
  test.identical( it.result, expected );
  var got = it.result;
  test.identical( got, expected );
  test.true( got[ 0 ] === src.b.b2 );

  var expected =
  {
    a : { map : { name : 'name1' }, value : 13 },
    b : { b1 : 1, b2 : 'b2' },
    c : { c1 : 1, c2 : 'c2' },
  }
  test.identical( src, expected );

  /* - */

}

//

function trivialResolve( test )
{

  /* */

  test.case = 'trivial';
  var src =
  {
    dir :
    {
      val1 : 'Hello'
    },
    val2 : 'here',
  }
  var exp = 'here';
  var got = _.resolver2.resolveQualified
  ({
    src,
    selector : '::val2',
  });
  test.identical( got, exp );

  /* */

  test.case = 'composite';
  var src =
  {
    dir :
    {
      val1 : 'Hello'
    },
    val2 : 'here',
  }
  var exp = 'Hello from here!';
  var got = _.resolver2.resolveQualified
  ({
    src,
    selector : '{::dir/val1} from {::val2}!',
  });
  test.identical( got, exp );

  /* */

  test.case = 'implicit';
  var src =
  {
    dir :
    {
      val1 : 'Hello'
    },
    val2 : 'here',
  }
  var exp = 'Hello from here!';
  var got = _.resolver2.resolveQualified( src, '{::dir/val1} from {::val2}!' );
  test.identical( got, exp );

  /* */

}

//

function qualifiedResolve( test )
{

  /* */

  test.case = 'trivial';
  var src =
  {
    dir :
    {
      val1 : 'Hello'
    },
    val2 : 'here',
  }
  var exp = 'Hello from here!';
  var got = _.resolver2.resolveQualified
  ({
    src,
    selector : '{dir::val1} from {val2::.}!',
  });
  test.identical( got, exp );
  console.log( got );

  /* */

  test.case = 'deep, implicit';
  var src =
  {
    var :
    {
      dir :
      {
        x : 13,
      }
    },
    about :
    {
      user : 'user1',
    },
    result :
    {
      dir :
      {
        userX : '{about::user} - {var::dir/x}'
      }
    },
  }
  var exp = 'user1 - 13 !';
  var got = _.resolver2.resolveQualified
  ({
    src,
    selector : '{result::dir/userX} !',
  });
  test.identical( got, exp );
  console.log( got );

  /* */

}

// --
// declare
// --

let Self =
{

  name : 'Tools.l7.ResolverExtra',
  silencing : 1,

  context :
  {
  },

  tests :
  {

    selectorParse,
    selectorNormalize,
    iteratorResult,
    trivialResolve,
    qualifiedResolve,

  }

}

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
