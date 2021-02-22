( function _ResolverExtra_s_( )
{

'use strict';

/**
 * Collection of cross-platform routines to resolve complex data structures. It takes a complex data structure, traverses it and resolves all strings having inlined special substrings. Use the module to resolve your templates.
  @module Tools/base/ResolverExtra
*/

/**
 *  */

/**
 * Collection of cross-platform routines to resolve complex data structures.
 * @namespace Tools.ResolverExtra
 * @memberof module:Tools/base/resolver
 */

/* qqq implement please :

- detect of recursion
  for example :
    path :
      in : '.'
      out : 'out'
      export : '{path::export}/**'


*/

if( typeof module !== 'undefined' )
{

  let _ = require( '../../../wtools/Tools.s' );
  _.include( 'wLooker' );
  _.include( 'wSelector' );
  _.include( 'wResolver' );

}

let _global = _global_;
let _ = _global_.wTools;
let Parent = _.Selector;
_.resolver = _.resolver || Object.create( null );

// --
// declare looker
// --

let Defaults =
{

  src : null,
  selector : null,
  defaultResourceKind : null,
  prefixlessAction : 'resolved',
  missingAction : 'throw',
  visited : null,
  singleUnwrapping : 1,
  mapValsUnwrapping : 1,
  mapFlattening : 1,
  arrayWrapping : 0,
  arrayFlattening : 1,
  preservingIteration : 0,

  Looker : null,
  Resolver : null, /* xxx : remove */

  // iteratorExtension : null,
  // iterationExtension : null,
  // iterationPreserve : null,

}

// --
// parser
// --

function strRequestParse( srcStr )
{
  let resolver = this;

  if( resolver._selectorIs( srcStr ) )
  {
    let left, right;
    let splits = _.strSplit( srcStr );

    if( splits.length > 1 )
    debugger;

    for( let s = splits.length - 1 ; s >= 0 ; s-- )
    {
      let split = splits[ s ];
      if( resolver._selectorIs( split ) )
      {
        left = splits.slice( 0, s+1 ).join( ' ' );
        right = splits.slice( s+1 ).join( ' ' );
      }
    }
    let result = _.strRequestParse( right );
    result.subject = left + result.subject;
    result.subjects = [ result.subject ];
    return result;
  }

  let result = _.strRequestParse( srcStr );
  return result;
}

//

function _selectorIs( selector )
{
  if( !_.strIs( selector ) )
  return false;
  if( !_.strHas( selector, '::' ) )
  return false;
  return true;
}

//

function selectorIs( selector )
{
  if( _.arrayIs( selector ) )
  {
    for( let s = 0 ; s < selector.length ; s++ )
    if( this.selectorIs( selector[ s ] ) )
    return true;
  }
  return this._selectorIs( selector );
}

//

function selectorIsComposite( selector )
{

  if( !this.selectorIs( selector ) )
  return false;

  if( _.arrayIs( selector ) )
  {
    for( let s = 0 ; s < selector.length ; s++ )
    if( isComposite( selector[ s ] ) )
    return true;
  }
  else
  {
    return isComposite( selector );
  }

  /* */

  function isComposite( selector )
  {

    let splits = _.strSplitFast
    ({
      src : selector,
      delimeter : [ '{', '}' ],
    });

    if( splits.length < 5 )
    return false;

    splits = _.strSplitsCoupledGroup({ splits, prefix : '{', postfix : '}' });

    if( !splits.some( ( split ) => _.arrayIs( split ) ) )
    return false;

    return true;
  }

}

//

function _selectorShortSplit( selector )
{
  _.assert( !_.strHas( selector, '/' ) );
  let result = _.strIsolateLeftOrNone( selector, '::' );
  _.assert( result.length === 3 );
  result[ 1 ] = result[ 1 ] || '';
  return result;
}

//

function selectorShortSplit( o )
{
  let result;

  _.assertRoutineOptions( selectorShortSplit, o );
  _.assert( arguments.length === 1 );
  _.assert( !_.strHas( o.selector, '/' ) );
  _.sure( _.strIs( o.selector ) || _.strsAreAll( o.selector ), 'Expects string, but got', _.entity.strType( o.selector ) );

  let splits = this._selectorShortSplit( o.selector );

  if( !splits[ 0 ] && o.defaultResourceKind )
  {
    splits = [ o.defaultResourceKind, '::', o.selector ];
  }

  return splits;
}

var defaults = selectorShortSplit.defaults = Object.create( null )
defaults.selector = null
defaults.defaultResourceKind = null;

//

function selectorLongSplit( o )
{
  let result = [];

  if( _.strIs( o ) )
  o = { selector : o }

  _.routineOptions( selectorLongSplit, o );
  _.assert( arguments.length === 1 );
  _.sure( _.strIs( o.selector ) || _.strsAreAll( o.selector ), 'Expects string, but got', _.entity.strType( o.selector ) );

  let selectors = o.selector.split( '/' );

  selectors.forEach( ( selector ) =>
  {
    let o2 = _.mapExtend( null, o );
    o2.selector = selector;
    result.push( this.selectorShortSplit( o2 ) );
  });

  return result;
}

var defaults = selectorLongSplit.defaults = Object.create( null )
defaults.selector = null
defaults.defaultResourceKind = null;

//

function selectorParse( o )
{
  let resolver = this;
  let result = [];

  if( _.strIs( o ) )
  o = { selector : o }

  _.routineOptions( selectorParse, o );
  _.assert( arguments.length === 1 );
  _.sure( _.strIs( o.selector ) || _.strsAreAll( o.selector ), 'Expects string, but got', _.entity.strType( o.selector ) );

  let splits = _.strSplitFast
  ({
    src : o.selector,
    delimeter : [ '{', '}' ],
  });

  splits = _.strSplitsCoupledGroup({ splits, prefix : '{', postfix : '}' });

  if( splits[ 0 ] === '' )
  splits.splice( 0, 1 );
  if( splits[ splits.length-1 ] === '' )
  splits.splice( splits.length-1, 1 );

  splits = splits.map( ( split ) =>
  {
    if( !_.arrayIs( split ) )
    return split;
    _.assert( split.length === 3 )
    if( !this.selectorIs( split[ 1 ] ) )
    return split.join( '' );

    let o2 = _.mapExtend( null, o );
    o2.selector = split[ 1 ];
    return this.selectorLongSplit( o2 );
  });

  splits = _.strSplitsUngroupedJoin( splits );

  if( splits.length === 1 && _.strIs( splits[ 0 ] ) && resolver.selectorIs( splits[ 0 ] ) )
  {
    let o2 = _.mapExtend( null, o );
    o2.selector = splits[ 0 ];
    splits[ 0 ] = resolver.selectorLongSplit( o2 );
  }

  return splits;
}

var defaults = selectorParse.defaults = Object.create( null )
defaults.selector = null
defaults.defaultResourceKind = null;

//

function selectorStr( parsedSelector )
{
  let resolver = this;

  if( _.strIs( parsedSelector ) )
  return parsedSelector;

  let result = '';

  for( let i = 0 ; i < parsedSelector.length ; i++ )
  {
    let inline = parsedSelector[ i ];
    if( _.strIs( inline ) )
    {
      result += inline;
    }
    else
    {
      _.arrayIs( inline )
      result += '{';
      for( let s = 0 ; s < inline.length ; s++ )
      {
        let split = inline[ s ];
        _.assert( _.arrayIs( split ) && split.length === 3 );
        if( s > 0 )
        result += '/';
        result += split.join( '' );
      }
      result += '}';
    }
  }

  return result;
}

//

function selectorNormalize( src )
{
  let resolver = this;

  if( !resolver.selectorIs( src ) )
  return src;

  let parsed = resolver.selectorParse( src );
  let result = resolver.selectorStr( parsed );

  return result;
}

// --
// iterator methods
// --

function _onSelectorReplicate( o )
{
  let it = this;
  // debugger;
  let rop = it.resolveExtraOptions;
  let resolver = rop.Resolver;
  let selector = o.selector;

  if( !_.strIs( selector ) )
  return;

  if( resolver._selectorIs( selector ) )
  return resolver._onSelectorReplicateComposite.call( it, o );

  if( o.counter > 0 )
  return;

  if( rop.prefixlessAction === 'default' && !it.composite )
  {
    return selector;
  }
  else if( rop.prefixlessAction === 'resolved' || rop.prefixlessAction === 'default' )
  {
    return;
  }
  else if( rop.prefixlessAction === 'throw' || rop.prefixlessAction === 'error' )
  {
    debugger;
    it.iterator.continue = false;
    let err = resolver.errResolving
    ({
      selector,
      rop,
      err : _.ErrorLooking( 'Resource selector should have prefix' ),
    });
    if( rop.prefixlessAction === 'throw' )
    throw err;
    it.dst = err;
    return;
  }
  else _.assert( 0 );

}

let _onSelectorReplicateComposite = _.resolver.functor.onSelectorReplicateComposite
({
  prefix : '{',
  postfix : '}',
  isStrippedSelector : 1,
  rewrapping : 0,
});

//

function _onSelectorDown()
{
  let it = this;
  // debugger;
  let rop = it.resolveExtraOptions;
  let resolver = rop.Resolver;

  resolver._arrayFlatten.call( it );

  if( it.continue && _.arrayIs( it.dst ) && it.src.composite === _.resolver.composite )
  {

    for( let d = 0 ; d < it.dst.length ; d++ )
    if( _.errIs( it.dst[ d ] ) )
    throw it.dst[ d ];

    it.dst = _.strJoin( it.dst );

  }

}

//

function _onUpBegin()
{
  let it = this;
  // debugger;
  let rop = it.resolveExtraOptions ? it.resolveExtraOptions : it.replicateIteration.resolveExtraOptions;
  let resolver = rop.Resolver;
  let doing = true;

  if( !it.dstWritingDown )
  return;

  resolver._queryParse.call( it );
  resolver._resourceMapSelect.call( it );

  let recursing = _.strIs( it.dst ) && resolver._selectorIs( it.dst );
  if( recursing )
  {

    debugger;
    let o2 = _.mapOnly( it, resolver.resolve.defaults );
    o2.selector = it.dst;
    o2.src = it.iterator.src;
    it.src = resolver.resolve( o2 ); /* zzz : write result of selection to dst, never to src? */

  }

}

//

function _onUpEnd()
{
  let it = this;
  debugger;
  let rop = it.resolveExtraOptions ? it.resolveExtraOptions : it.replicateIteration.resolveExtraOptions;
  let resolver = rop.Resolver;

  if( !it.dstWritingDown )
  return;

}

//

function _onDownEnd()
{
  let it = this;
  // debugger;
  let rop = it.resolveExtraOptions ? it.resolveExtraOptions : it.replicateIteration.resolveExtraOptions;
  let resolver = rop.Resolver;

  if( !it.dstWritingDown )
  return;

  resolver._functionStringsJoinDown.call( it );

  resolver._mapsFlatten.call( it );
  resolver._mapValsUnwrap.call( it );
  resolver._arrayFlatten.call( it );
  resolver._singleUnwrap.call( it );

}

//

function _onQuantitativeFail( err )
{
  let it = this;
  debugger;
  let rop = it.resolveExtraOptions ? it.resolveExtraOptions : it.replicateIteration.resolveExtraOptions;
  let resolver = rop.Resolver;

  debugger;

  let result = it.dst;
  if( _.mapIs( result ) )
  result = _.mapVals( result );
  if( _.arrayIs( result ) )
  {
    let isString = 1;
    if( result.every( ( e ) => _.strIs( e ) ) )
    isString = 1;
    else
    result = result.map( ( e ) =>
    {
      if( _.strIs( e ) )
      return e;
      if( _.strIs( e.qualifiedName ) )
      return e.qualifiedName;
      isString = 0
    });

    if( isString )
    if( result.length )
    err = _.err( err, '\n', 'Found : ' + result.join( ', ' ) );
    else
    err = _.err( err, '\n', 'Found nothing' );
  }

  throw err;
}

//

function _arrayFlatten()
{
  let it = this;
  // debugger;
  let rop = it.resolveExtraOptions ? it.resolveExtraOptions : it.replicateIteration.resolveExtraOptions;
  let resolver = rop.Resolver;
  let currentModule = it.currentModule;

  _.assert( _.mapIs( rop ) );

  if( !rop.arrayFlattening || !_.arrayIs( it.dst ) )
  return;

  it.dst = _.arrayFlattenDefined( it.dst );

}

//

function _arrayWrap( result )
{
  let it = this;
  // debugger;
  let rop = it.resolveExtraOptions ? it.resolveExtraOptions : it.replicateIteration.resolveExtraOptions;
  let resolver = rop.Resolver;

  if( !rop.arrayWrapping )
  return;

  if( !_.mapIs( it.dst ) )
  it.dst = _.arrayAs( it.dst );

}

//

function _mapsFlatten()
{
  let it = this;
  // debugger;
  let rop = it.resolveExtraOptions ? it.resolveExtraOptions : it.replicateIteration.resolveExtraOptions;
  let resolver = rop.Resolver;

  if( !rop.mapFlattening || !_.mapIs( it.dst ) )
  return;

  it.dst = _.mapsFlatten([ it.dst ]);

}

//

function _mapValsUnwrap()
{
  let it = this;
  let rop = it.resolveExtraOptions ? it.resolveExtraOptions : it.replicateIteration.resolveExtraOptions;
  let resolver = rop.Resolver;

  if( !rop.mapValsUnwrapping )
  return;
  if( !_.mapIs( it.dst ) )
  return;
  if( !_.all( it.dst, ( e ) => _.instanceIs( e ) || _.primitiveIs( e ) ) )
  return;

  it.dst = _.mapVals( it.dst );
}

//

function _singleUnwrap()
{
  let it = this;
  // debugger;
  let rop = it.resolveExtraOptions ? it.resolveExtraOptions : it.replicateIteration.resolveExtraOptions;
  let resolver = rop.Resolver;

  if( !rop.singleUnwrapping )
  return;

  if( _.any( it.dst, ( e ) => _.mapIs( e ) || _.arrayIs( e ) ) )
  return;

  if( _.mapIs( it.dst ) )
  {
    if( _.mapKeys( it.dst ).length === 1 )
    it.dst = _.mapVals( it.dst )[ 0 ];
  }
  else if( _.arrayIs( it.dst ) )
  {
    if( it.dst.length === 1 )
    it.dst = it.dst[ 0 ];
  }

}

//

function _queryParse()
{
  let it = this;
  // debugger;
  // let rop = it.resolveExtraOptions;
  let rop = it.resolveExtraOptions ? it.resolveExtraOptions : it.replicateIteration.resolveExtraOptions;
  let resolver = rop.Resolver;

  if( !it.selector )
  return;

  let splits = resolver.selectorShortSplit
  ({
    selector : it.selector,
    defaultResourceKind : rop.defaultResourceKind,
  });

  it.parsedSelector = Object.create( null );
  it.parsedSelector.kind = splits[ 0 ];

  if( !it.parsedSelector.kind )
  {
    if( splits[ 1 ] !== undefined )
    it.parsedSelector.kind = null;
  }

  it.parsedSelector.full = splits.join( '' );
  it.selector = it.parsedSelector.name = splits[ 2 ];

}

//

function _resourceMapSelect()
{
  let it = this;
  debugger;
  let rop = it.resolveExtraOptions ? it.resolveExtraOptions : it.replicateIteration.resolveExtraOptions;
  let resolver = rop.Resolver;

  if( it.selector === undefined || it.selector === null )
  return;

  let kind = it.parsedSelector.kind;
  if( kind === '' || kind === null )
  {
  }
  else if( kind === 'f' )
  {

    debugger; /* xxx qqq : cover */
    it.isFunction = it.selector;
    if( it.selector === 'strings.join' )
    {
      resolver._functionStringsJoinUp.call( it );
    }
    else _.sure( 0, 'Unknown function', it.parsedSelector.full );

  }
  else
  {
    debugger; /* xxx */
    let root = it.root || it;
    it.src = it.iterator.src[ kind ];
    if( it.selector === '.' )
    it.src = { '.' : it.src }
    it.iterable = null;
    it.srcChanged();
  }

}

// --
// function
// --

function _functionStringsJoinUp()
{
  let it = this;
  debugger;
  let rop = it.resolveExtraOptions ? it.resolveExtraOptions : it.replicateIteration.resolveExtraOptions;

  _.sure( !!it.down, () => it.parsedSelector.full + ' expects context to join it' );

  it.src = [ it.src ]; /* xxx : write result of selection to dst, never to src */
  it.src[ functionSymbol ] = it.selector;

  it.isFunction = it.selector;
  it.selector = 0;

  it.iterable = null;
  it.iterationSelectorChanged();
  it.srcChanged();

}

//

function _functionStringsJoinDown()
{
  let it = this;
  debugger;
  let rop = it.resolveExtraOptions ? it.resolveExtraOptions : it.replicateIteration.resolveExtraOptions;

  if( !_.arrayIs( it.src ) || !it.src[ functionSymbol ] )
  return;

  debugger;
  if( _.arrayIs( it.dst ) && it.dst.every( ( e ) => _.arrayIs( e ) ) )
  {
    it.dst = it.dst.map( ( e ) => e.join( ' ' ) );
  }
  else
  {
    _.assert( _.routineIs( it.dst.join ) );
    it.dst = it.dst.join( ' ' );
  }

}

// --
// err
// --

function errResolving( o )
{
  let resolver = this;
  _.assertRoutineOptions( errResolving, arguments );
  _.assert( arguments.length === 1 );
  debugger;
  return _.err( 'Failed to resolve', _.color.strFormat( o.selector, 'path' ), '\n', o.err );
}

errResolving.defaults =
{
  selector : null,
  rop : null,
  err : null,
}

//

function errResolvingThrow( o )
{
  let resolver = this;
  _.assertRoutineOptions( errResolvingThrow, arguments );
  _.assert( arguments.length === 1 );
  if( o.missingAction === 'undefine' )
  return;

  debugger;

  let err = resolver.errResolving
  ({
    selector : o.selector,
    rop : o.rop,
    err : o.err,
  });

  if( o.missingAction === 'throw' )
  throw err;
  else
  return err;

}

errResolvingThrow.defaults =
{
  missingAction : null,
  selector : null,
  rop : null,
  err : null,
}

// --
// resolve
// --

function resolveQualified_head( routine, args )
{
  if( args.length === 2 )
  args = [ { src : args[ 0 ], selector : args[ 1 ] } ]
  let o = args[ 0 ];

  _.routineOptions( routine, args );

  if( o.visited === null )
  o.visited = [];

  if( o.Resolver === null )
  o.Resolver = _.resolver; /* xxx */

  _.assert( arguments.length === 2 );
  _.assert( args.length === 1 || args.length === 2 );
  _.assert( _.longHas( [ 'undefine', 'throw', 'error' ], o.missingAction ), 'Unknown value of option missing action', o.missingAction );
  _.assert( _.longHas( [ 'default', 'resolved', 'throw', 'error' ], o.prefixlessAction ), 'Unknown value of option prefixless action', o.prefixlessAction );
  _.assert( _.arrayIs( o.visited ) );
  _.assert( !o.defaultResourceKind || !_.strHas( o.defaultResourceKind, '*' ), () => 'Expects non glob {-defaultResourceKind-}, but got ' + _.strQuote( o.defaultResourceKind ) );

  return o;
}

//

function resolveQualified_body( o )
{
  let resolver = this;

  _.assert( !!resolver._resolveQualifiedAct );

  let result = resolver._resolveQualifiedAct( o );

  if( result === undefined )
  {
    result = resolver.errResolving
    ({
      selector : o.selector,
      rop : o,
      err : _.ErrorLooking( o.selector, 'was not found' ),
    })
  }

  if( _.errIs( result ) )
  {
    return resolver.errResolvingThrow
    ({
      missingAction : o.missingAction,
      selector : o.selector,
      rop : o,
      err : result,
    });

  }

  let it =
  {
    dst : result,
    resolveExtraOptions : o,
  }

  resolver._mapsFlatten.call( it );
  resolver._mapValsUnwrap.call( it );
  resolver._singleUnwrap.call( it );
  resolver._arrayWrap.call( it );

  return it.dst;
}

resolveQualified_body.defaults = Defaults;

let resolveQualified = _.routineUnite( resolveQualified_head, resolveQualified_body );
let resolveQualifiedMaybe = _.routineUnite( resolveQualified_head, resolveQualified_body );

var defaults = resolveQualifiedMaybe.defaults;
defaults.missingAction = 'undefine';

//

function _resolveQualifiedAct( o )
{
  let resolver = this;
  let result;

  _.assert( arguments.length === 1 );
  _.assert( _.arrayIs( o.visited ) );
  _.assert( !!_.Resolver );

  /* */

  try
  {

    let iterator = Object.create( null );
    // if( iterator.isFunction === undefined )
    iterator.resolveExtraOptions = o; /* xxx */

    let iterationPreserve = Object.create( null );
    if( iterationPreserve.isFunction === undefined )
    iterationPreserve.isFunction = null;

    o.Looker = _.looker.make({ iterationPreserve, iterator, parent : o.Looker || _.Resolver, name : 'ResolverExtra' });

    // o.iteratorExtension = iterator
    // o.iterationExtension = o.iterationExtension || Object.create( null );
    // o.iterationPreserve = iterationPreserve;

    // o.iteratorExtension = o.iteratorExtension || Object.create( null );
    // if( o.iteratorExtension.isFunction === undefined )
    // o.iteratorExtension.resolveExtraOptions = o;
    //
    // o.iterationExtension = o.iterationExtension || Object.create( null );
    //
    // o.iterationPreserve = o.iterationPreserve || Object.create( null );
    // if( o.iterationPreserve.isFunction === undefined )
    // o.iterationPreserve.isFunction = null;

    result = _.resolve
    ({

      Looker : o.Looker,

      src : o.src,
      selector : o.selector,
      preservingIteration : o.preservingIteration,
      missingAction : o.missingAction,
      recursive : 32,

      onSelectorReplicate : resolver._onSelectorReplicate,
      onSelectorDown : resolver._onSelectorDown,
      onUpBegin : resolver._onUpBegin,
      onUpEnd : resolver._onUpEnd,
      onDownEnd : resolver._onDownEnd,
      onQuantitativeFail : resolver._onQuantitativeFail,

      // iteratorExtension : o.iteratorExtension,
      // iterationExtension : o.iterationExtension,
      // iterationPreserve : o.iterationPreserve,

    });

  }
  catch( err )
  {
    throw resolver.errResolving
    ({
      selector : o.selector,
      rop : o,
      err,
    });
  }

  return result;
}

var defaults = _resolveQualifiedAct.defaults = Defaults;

// --
// declare
// --

let functionSymbol = Symbol.for( 'function' );
let ResolverExtension =
{

  name : 'resolver',
  shortName : 'resolver',

  // parser

  strRequestParse,

  _selectorIs,
  selectorIs,
  selectorIsComposite,
  _selectorShortSplit,
  selectorShortSplit,
  selectorLongSplit,
  selectorParse,
  selectorStr,
  selectorNormalize,

  // handler

  _onSelectorReplicate,
  _onSelectorReplicateComposite,
  _onSelectorDown,
  _onUpBegin,
  _onUpEnd,
  _onDownEnd,
  _onQuantitativeFail,

  //

  _arrayFlatten,
  _arrayWrap,
  _mapsFlatten,
  _mapValsUnwrap,
  _singleUnwrap,

  _queryParse,
  _resourceMapSelect,

  // function

  _functionStringsJoinUp,
  _functionStringsJoinDown,

  // err

  errResolving,
  errResolvingThrow,

  // resolve

  resolveQualified,
  resolveQualifiedMaybe,
  _resolveQualifiedAct,

}

let SupplementTools =
{

  ResolverExtra : _.Resolver,
  resolveQualified,
  resolveQualifiedMaybe,

}

_.mapSupplement( _, SupplementTools );
_.mapExtend( _.resolver, ResolverExtension );

if( typeof module !== 'undefined' )
module[ 'exports' ] = _;

})();
