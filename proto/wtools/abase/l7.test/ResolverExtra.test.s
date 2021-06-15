( function _ResolverExtra_test_s_()
{

'use strict';

if( typeof module !== 'undefined' )
{

  const _ = require( '../../../node_modules/Tools' );

  _.include( 'wTesting' );
  // _.include( 'wLogger' );
  _.include( 'wStringer' );

  require( '../l7/ResolverExtra.s' );

}

const _global = _global_;
const _ = _global_.wTools;

// --
// tests
// --

function selectorParse( test )
{
  let self = this;
  // let r = _.resolverAdv;
  let r = _.resolverAdv.Seeker;

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
  // let r = _.resolverAdv;
  let r = _.resolverAdv.Seeker;

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
  var got = _.resolverAdv.resolve( src, [ '::b/b2', { a : 'c', b : '::a/map' } ] );
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
  var it = _.resolverAdv.resolve.head( _.resolverAdv.resolve, [ src, [ '::b/b2', { a : 'c', b : '::a/map' } ] ] );
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
  var got = _.resolverAdv.resolve
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
  var got = _.resolverAdv.resolve
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
  var got = _.resolverAdv.resolve( src, '{::dir/val1} from {::val2}!' );
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
  var got = _.resolverAdv.resolve
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
  var got = _.resolverAdv.resolve
  ({
    src,
    selector : '{result::dir/userX} !',
  });
  test.identical( got, exp );
  console.log( got );

  /* */

}

//

function globTrivial( test )
{

  /* */

  test.case = 'trivial';
  var src =
  {
    val1 : 'Hello',
    val2 : 'here',
  }
  var got = _.resolverAdv.resolve
  ({
    src,
    selector : '*',
    prefixlessAction : 'default',
  });
  var exp = [ 'Hello', 'here' ];
  test.identical( got, exp );
  console.log( got );

  /* */

}

//

function optionMissingAction( test )
{

  /* */

  test.case = `control`;

  var src =
  {
    k1 : '1'
  }
  var got = _.resolverAdv.resolve
  ({
    src,
    selector : '{k1::.}',
  });
  var exp = '1';
  test.identical( got, exp );
  var exp =
  {
    k1 : '1'
  }
  test.identical( src, exp );

  /* */

  act({ missingAction : 'ignore' });
  act({ missingAction : 'undefine' });
  act({ missingAction : 'error' });
  act({ missingAction : 'throw' });

  /* - */

  function act( env )
  {

    /* */

    test.case = `${_.entity.exportStringSolo( env )}, basic`;
    try
    {
      var errorMessage =
`
Failed to resolve {k2::.}
Cant select k2::. from {- Map.polluted with 1 elements -}
because k2::. does not exist
fall at "/"
`;

      var src =
      {
        k1 : '1'
      }
      var iterator =
      {
        src,
        selector : '{k2::.}',
        missingAction : env.missingAction,
      }
      _.debugger = 1;
      var got = _.resolverAdv.resolve( iterator );
      var exp = undefined;
      if( env.missingAction === 'error' )
      {
        test.true( _.errIs( got ) );
        test.true( got instanceof _.looker.SeekingError );
        test.identical( got.SeekingError, true );
        test.identical( got.ResolvingError, true );
        test.equivalent( _.ct.strip( got.originalMessage ), errorMessage );
        test.true( got === iterator.error );
      }
      else
      {
        test.identical( got, exp );
      }
      test.nil( env.missingAction, 'throw' );

    }
    catch( got )
    {
      test.true( _.errIs( got ) );
      test.identical( env.missingAction, 'throw' );
      test.true( got instanceof _.looker.SeekingError );
      test.identical( got.SeekingError, true );
      test.identical( got.ResolvingError, true );
      test.equivalent( _.ct.strip( got.originalMessage ), errorMessage );
      test.true( got === iterator.error );
      if( env.missingAction !== 'throw' )
      throw got;
    }

    var exp =
    {
      k1 : '1'
    }
    test.identical( src, exp );

    /* */

  }

}

//

function resolveUndefined( test )
{

  act({ missingAction : 'ignore' });
  act({ missingAction : 'undefine' });
  act({ missingAction : 'error' });
  act({ missingAction : 'throw' });

  /* - */

  function act( env )
  {

    /* */

    test.case = `${_.entity.exportStringSolo( env )}, map, key, undefined`;
    var src =
    {
      k1 : undefined,
    }
    var iterator =
    {
      src,
      selector : 'k1::.',
      missingAction : env.missingAction,
    }
    var got = _.resolverAdv.resolve( iterator );
    var exp = undefined;
    test.identical( got, exp );
    test.identical( iterator.error, null );

    /* */

    if( env.missingAction !== 'throw' )
    {
      test.case = `${_.entity.exportStringSolo( env )}, map, key, nothing`;
      var src =
      {
        k1 : undefined,
      }
      var iterator =
      {
        src,
        selector : 'k2::.',
        missingAction : env.missingAction,
      }
      var got = _.resolverAdv.resolve( iterator );
      var exp = undefined;
      if( env.missingAction === 'error' )
      {
        test.true( _.errIs( got ) );
        test.true( _.errIs( iterator.error ) );
        var exp =
`
Failed to resolve k2::.
Cant select k2::. from {- Map.polluted with 1 elements -}
because k2::. does not exist
fall at "/"
`
        test.equivalent( _.ct.strip( iterator.error.originalMessage ), exp );
      }
      else
      {
        test.identical( got, exp );
        test.identical( iterator.error, true );
      }
    }

    /* */

    test.case = `${_.entity.exportStringSolo( env )}, map, cardinal`;
    var src =
    {
      k1 : undefined,
    }
    var iterator =
    {
      src,
      selector : '#0::.',
      missingAction : env.missingAction,
    }
    var got = _.resolverAdv.resolve( iterator );
    var exp = undefined;
    test.identical( got, exp );
    test.identical( iterator.error, null );

    /* */

    if( env.missingAction !== 'throw' )
    {
      test.case = `${_.entity.exportStringSolo( env )}, map, cardinal, nothing`;
      var src =
      {
        k1 : undefined,
      }
      var iterator =
      {
        src,
        selector : '#1::.',
        missingAction : env.missingAction,
      }
      var got = _.resolverAdv.resolve( iterator );
      var exp = undefined;
      if( env.missingAction === 'error' )
      {
        test.true( _.errIs( got ) );
        test.true( _.errIs( iterator.error ) );
        var exp =
`
Failed to resolve #1::.
Cant select #1::. from {- Map.polluted with 1 elements -}
because #1::. does not exist
fall at "/"
`
        test.equivalent( _.ct.strip( iterator.error.originalMessage ), exp );
      }
      else
      {
        test.identical( got, exp );
        test.identical( iterator.error, true );
      }
    }

    /* */

    test.case = `${_.entity.exportStringSolo( env )}, long, cardinal, undefined`;
    var src = [ undefined ];
    var iterator =
    {
      src,
      selector : '#0::.',
      missingAction : env.missingAction,
    }
    var got = _.resolverAdv.resolve( iterator );
    var exp = undefined;
    test.identical( got, exp );
    test.identical( iterator.error, null );

    /* */

    if( env.missingAction !== 'throw' )
    {
      test.case = `${_.entity.exportStringSolo( env )}, long, cardinal, nothing`;
      var src = [ undefined ];
      var iterator =
      {
        src,
        selector : '#1::.',
        missingAction : env.missingAction,
      }
      var got = _.resolverAdv.resolve( iterator );
      var exp = undefined;
      if( env.missingAction === 'error' )
      {
        test.true( _.errIs( got ) );
        test.true( _.errIs( iterator.error ) );
        var exp =
`
Failed to resolve #1::.
Cant select #1::. from {- Array with 1 elements -}
because #1::. does not exist
fall at "/"
`
        test.equivalent( _.ct.strip( iterator.error.originalMessage ), exp );
      }
      else
      {
        test.identical( got, exp );
        test.identical( iterator.error, true );
      }
    }

    /* */

    test.case = `${_.entity.exportStringSolo( env )}, set, cardinal, undefined`;
    var src = new Set([ undefined ]);
    var iterator =
    {
      src,
      selector : '#0::.',
      missingAction : env.missingAction,
    }
    var got = _.resolverAdv.resolve( iterator );
    var exp = undefined;
    test.identical( got, exp );
    test.identical( iterator.error, null );

    /* */

    if( env.missingAction !== 'throw' )
    {
      test.case = `${_.entity.exportStringSolo( env )}, set, cardinal, nothing`;
      var src = new Set([ undefined ]);
      var iterator =
      {
        src,
        selector : '#1::.',
        missingAction : env.missingAction,
      }
      var got = _.resolverAdv.resolve( iterator );
      var exp = undefined;
      if( env.missingAction === 'error' )
      {
        test.true( _.errIs( got ) );
        test.true( _.errIs( iterator.error ) );
        var exp =
`
Failed to resolve #1::.
Cant select #1::. from {- Set with 1 elements -}
because #1::. does not exist
fall at "/"
`
        test.equivalent( _.ct.strip( iterator.error.originalMessage ), exp );
      }
      else
      {
        test.identical( got, exp );
        test.identical( iterator.error, true );
      }
    }

    /* */

    test.case = `${_.entity.exportStringSolo( env )}, hash, key, undefined`;
    var src = new HashMap([ [ 'k1', undefined ] ]);
    var iterator =
    {
      src,
      selector : 'k1::.',
      missingAction : env.missingAction,
    }
    var got = _.resolverAdv.resolve( iterator );
    var exp = undefined;
    test.identical( got, exp );
    test.identical( iterator.error, null );

    /* */

    if( env.missingAction !== 'throw' )
    {
      test.case = `${_.entity.exportStringSolo( env )}, hash, key, nothing`;
      var src = new HashMap([ [ 'k1', undefined ] ]);
      var iterator =
      {
        src,
        selector : 'k2::.',
        missingAction : env.missingAction,
      }
      var got = _.resolverAdv.resolve( iterator );
      var exp = undefined;
      if( env.missingAction === 'error' )
      {
        test.true( _.errIs( got ) );
        test.true( _.errIs( iterator.error ) );
        var exp =
`
Failed to resolve k2::.
Cant select k2::. from {- HashMap with 1 elements -}
because k2::. does not exist
fall at "/"
`
        test.equivalent( _.ct.strip( iterator.error.originalMessage ), exp );
      }
      else
      {
        test.identical( got, exp );
        test.identical( iterator.error, true );
      }
    }

    /* */

    test.case = `${_.entity.exportStringSolo( env )}, hash, cardinal`;
    var src = new HashMap([ [ 'k1', undefined ] ]);
    var iterator =
    {
      src,
      selector : '#0::.',
      missingAction : env.missingAction,
    }
    var got = _.resolverAdv.resolve( iterator );
    var exp = undefined;
    test.identical( got, exp );
    test.identical( iterator.error, null );

    /* */

    if( env.missingAction !== 'throw' )
    {
      test.case = `${_.entity.exportStringSolo( env )}, hash, cardinal, nothing`;
      var src = new HashMap([ [ 'k1', undefined ] ]);
      var iterator =
      {
        src,
        selector : '#1::.',
        missingAction : env.missingAction,
      }
      var got = _.resolverAdv.resolve( iterator );
      var exp = undefined;
      if( env.missingAction === 'error' )
      {
        test.true( _.errIs( got ) );
        test.true( _.errIs( iterator.error ) );
        var exp =
`
Failed to resolve #1::.
Cant select #1::. from {- HashMap with 1 elements -}
because #1::. does not exist
fall at "/"
`
        test.equivalent( _.ct.strip( iterator.error.originalMessage ), exp );
      }
      else
      {
        test.identical( got, exp );
        test.identical( iterator.error, true );
      }
    }

    /* */

  }

}

// --
// declare
// --

const Proto =
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
    globTrivial,
    optionMissingAction,
    resolveUndefined,

  }

}

const Self = wTestSuite( Proto );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
