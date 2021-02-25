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
let Parent = _.resolver.Resolver;
_.resolver2 = _.resolver2 || Object.create( null );
_.assert( !!_.resolver.Resolver );

// --
// relations
// --

let Defaults =
{

  ... _.resolver.resolve.defaults,

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

  recursive : 32,

  Looker : null,
  Resolver : null, /* xxx : remove */

}

delete Defaults.onSelectorReplicate;
delete Defaults.onSelectorDown;
delete Defaults.onUpBegin;
delete Defaults.onUpEnd;
delete Defaults.onDownEnd;
delete Defaults.onQuantitativeFail;

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
  let rop = it.resolveExtraOptions;
  let resolver = rop.Resolver;
  let selector = o.selector;

  // debugger; /* xxx */

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
  let rop = it.resolveExtraOptions;
  let resolver = rop.Resolver;

  // debugger; /* xxx */

  resolver._arrayFlatten.call( it );

  if( it.continue && _.arrayIs( it.dst ) && it.src.composite === _.resolver2.composite )
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
    /* qqq : cover please */
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
  let rop = it.resolveExtraOptions ? it.resolveExtraOptions : it.replicateIteration.resolveExtraOptions;
  let resolver = rop.Resolver;

  if( !it.dstWritingDown )
  return;

}

//

function _onDownEnd()
{
  let it = this;
  let rop = it.resolveExtraOptions ? it.resolveExtraOptions : it.replicateIteration.resolveExtraOptions;
  let resolver = rop.Resolver;

  // debugger; /* xxx */

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
  let rop = it.resolveExtraOptions ? it.resolveExtraOptions : it.replicateIteration.resolveExtraOptions;
  let resolver = rop.Resolver;
  let currentModule = it.currentModule;

  // _.assert( _.mapIs( rop ) );
  _.assert( _.objectIs( rop ) );

  if( !rop.arrayFlattening || !_.arrayIs( it.dst ) )
  return;

  it.dst = _.arrayFlattenDefined( it.dst );

}

//

function _arrayWrap( result )
{
  let it = this;
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

    debugger; /* zzz qqq : cover */
    it.isFunction = it.selector;
    if( it.selector === 'strings.join' )
    {
      resolver._functionStringsJoinUp.call( it );
    }
    else _.sure( 0, 'Unknown function', it.parsedSelector.full );

  }
  else
  {
    /* zzz */
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
  let rop = it.resolveExtraOptions ? it.resolveExtraOptions : it.replicateIteration.resolveExtraOptions;

  _.sure( !!it.down, () => it.parsedSelector.full + ' expects context to join it' );

  it.src = [ it.src ]; /* zzz : write result of selection to dst, never to src? */
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
  let rop = it.resolveExtraOptions ? it.resolveExtraOptions : it.replicateIteration.resolveExtraOptions;

  if( !_.arrayIs( it.src ) || !it.src[ functionSymbol ] )
  return;

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
  return _.err( 'Failed to resolve', _.color.strFormat( _.entity.exportStringShort( o.selector ), 'path' ), '\n', o.err );
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

function head( routine, args )
{
  _.assert( arguments.length === 2 );
  let o = Self.optionsFromArguments( args );
  if( _.routineIs( routine ) )
  o.Looker = o.Looker || routine.defaults.Looker || Self;
  else
  o.Looker = o.Looker || routine.Looker || Self;
  if( _.routineIs( routine ) ) /* zzz : remove "if" later */
  _.routineOptionsPreservingUndefines( routine, o );
  else
  _.routineOptionsPreservingUndefines( null, o, routine );
  o.Looker.optionsForm( routine, o );
  o.optionsForSelect = o.Looker.optionsForSelectFrom( o );
  let it = o.Looker.optionsToIteration( o );
  return it;
}

//

function perform() /* xxx : rename to body? */
{
  let it = this;

  _.assert( _.arrayIs( it.visited ) );
  // _.assert( !!it._resolveQualifiedAct );
  _.assert( !!it.Resolver );
  _.assert( arguments.length === 0 );
  _.assert( _.arrayIs( it.visited ) );
  _.assert( !!it.resolveExtraOptions );

  _.assert( it.onSelectorReplicate === it.Looker._onSelectorReplicate );
  _.assert( it.onSelectorDown === it.Looker._onSelectorDown );
  _.assert( it.onUpBegin === it.Looker._onUpBegin );
  _.assert( it.onUpEnd === it.Looker._onUpEnd );
  _.assert( it.onDownEnd === it.Looker._onDownEnd );
  _.assert( it.onQuantitativeFail === it.Looker._onQuantitativeFail );

  /* */

  try
  {
    Parent.perform.call( it );
  }
  catch( err )
  {
    throw it.errResolving
    ({
      selector : it.selector,
      rop : it,
      err,
    });
  }

  let result = it.result;

  if( result === undefined )
  {
    result = it.errResolving
    ({
      selector : it.selector,
      rop : it,
      err : _.ErrorLooking( it.selector, 'was not found' ),
    })
  }

  if( _.errIs( result ) )
  {
    return it.errResolvingThrow
    ({
      missingAction : it.missingAction,
      selector : it.selector,
      rop : it,
      err : result,
    });
  }

  let it2 = /* xxx : remove? */
  {
    dst : result,
    resolveExtraOptions : it,
  }

  it._mapsFlatten.call( it2 );
  it._mapValsUnwrap.call( it2 );
  it._singleUnwrap.call( it2 );
  it._arrayWrap.call( it2 );

  return it;
}

//

function optionsFromArguments( args )
{
  let o = args[ 0 ];

  if( args.length === 2 )
  {
    _.assert( !_.resolver2.iterationIs( args[ 0 ] ) );
    o = { src : args[ 0 ], selector : args[ 1 ] }
  }

  _.assert( args.length === 1 || args.length === 2 );
  _.assert( arguments.length === 1 );
  _.assert( _.mapIs( o ) );

  return o;
}

//

function optionsForm( routine, o )
{
  Parent.optionsForm.call( this, routine, o );

  if( o.visited === null )
  o.visited = [];

  if( o.Resolver === null )
  o.Resolver = _.resolver2; /* xxx */

    //   src : o.src,
    //   selector : o.selector,
    //   preservingIteration : o.preservingIteration,
    //   missingAction : o.missingAction,
    //   recursive : 32,
    //
    //   onSelectorReplicate : resolver._onSelectorReplicate,
    //   onSelectorDown : resolver._onSelectorDown,
    //   onUpBegin : resolver._onUpBegin,
    //   onUpEnd : resolver._onUpEnd,
    //   onDownEnd : resolver._onDownEnd,
    //   onQuantitativeFail : resolver._onQuantitativeFail,

  _.assert( o.resolvingRecursive !== undefined );
  _.assert( arguments.length === 2 );
  _.assert( _.longHas( [ 'undefine', 'throw', 'error' ], o.missingAction ), 'Unknown value of option missing action', o.missingAction );
  _.assert( _.longHas( [ 'default', 'resolved', 'throw', 'error' ], o.prefixlessAction ), 'Unknown value of option prefixless action', o.prefixlessAction );
  _.assert( _.arrayIs( o.visited ) );
  _.assert( !o.defaultResourceKind || !_.strHas( o.defaultResourceKind, '*' ), () => 'Expects non glob {-defaultResourceKind-}, but got ' + _.strQuote( o.defaultResourceKind ) );

  return o;
}

//

function optionsToIteration( o )
{
  let it = Parent.optionsToIteration.call( this, o );

  it.iterator.resolveExtraOptions = o; /* xxx */

  _.assert( it.onSelectorReplicate === it.Looker._onSelectorReplicate );
  _.assert( it.onSelectorDown === it.Looker._onSelectorDown );
  _.assert( it.onUpBegin === it.Looker._onUpBegin );
  _.assert( it.onUpEnd === it.Looker._onUpEnd );
  _.assert( it.onDownEnd === it.Looker._onDownEnd );
  _.assert( it.onQuantitativeFail === it.Looker._onQuantitativeFail );

  return it;
}

//

function optionsForSelectFrom( o )
{
  let it = this;
  let o2 = Parent.optionsForSelectFrom.call( it, o );
  // debugger; /* xxx */
  return o2;
}

//

function optionsToIterationOfSelector( o )
{

  _.assert( o.onSelectorReplicate === undefined );
  _.assert( o.onSelectorDown === undefined );
  _.assert( o.onUpBegin === undefined );
  _.assert( o.onUpEnd === undefined );
  _.assert( o.onDownEnd === undefined );
  _.assert( o.onQuantitativeFail === undefined );

  let it = Parent.ResolverSelector.optionsToIteration.call( this, o );

  _.assert( it.onSelectorReplicate === it.Looker._onSelectorReplicate );
  _.assert( it.onSelectorDown === it.Looker._onSelectorDown );
  _.assert( it.onUpBegin === it.Looker._onUpBegin );
  _.assert( it.onUpEnd === it.Looker._onUpEnd );
  _.assert( it.onDownEnd === it.Looker._onDownEnd );
  _.assert( it.onQuantitativeFail === it.Looker._onQuantitativeFail );

  return it;
}

//

function resolveQualified_head( routine, args )
{
  return Self.head( routine, args );
}

//

function resolveQualified_body( it )
{
  it.perform();
  return it.result;
}

resolveQualified_body.defaults = Defaults;

let resolveQualified = _.routineUnite( resolveQualified_head, resolveQualified_body );
let resolveQualifiedMaybe = _.routineUnite( resolveQualified_head, resolveQualified_body );

var defaults = resolveQualifiedMaybe.defaults;
defaults.missingAction = 'undefine';

// //
//
// function _resolveQualifiedAct( o ) /* xxx : remove? */
// {
//   let it = this;
//   let resolver = this; /* xxx : remove */
//   let result;
//
//   _.assert( arguments.length === 1 );
//   _.assert( _.arrayIs( o.visited ) );
//
//   /* */
//
//   try
//   {
//
//     // o.Looker = o.Looker || Self;
//     //
//     // let o2 =
//     // {
//     //
//     //   Looker : o.Looker,
//     //
//     //   src : o.src,
//     //   selector : o.selector,
//     //   preservingIteration : o.preservingIteration,
//     //   missingAction : o.missingAction,
//     //   recursive : 32,
//     //
//     //   onSelectorReplicate : resolver._onSelectorReplicate,
//     //   onSelectorDown : resolver._onSelectorDown,
//     //   onUpBegin : resolver._onUpBegin,
//     //   onUpEnd : resolver._onUpEnd,
//     //   onDownEnd : resolver._onDownEnd,
//     //   onQuantitativeFail : resolver._onQuantitativeFail,
//     //
//     // }
//     //
//     // debugger;
//     // let it = _.resolver.resolve.head( Defaults, [ o2 ] );
//     // it.iterator.resolveExtraOptions = o;
//     // it.perform();
//     // debugger;
//
//     debugger;
//     it.perform();
//
//     return it.result;
//   }
//   catch( err )
//   {
//     throw resolver.errResolving
//     ({
//       selector : o.selector,
//       rop : o,
//       err,
//     });
//   }
//
//   return result;
// }
//
// var defaults = _resolveQualifiedAct.defaults = Defaults;

// --
// relations
// --

let Common =
{

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

  head,
  perform,
  performMaking : resolveQualified,
  optionsFromArguments,
  optionsForm,
  optionsToIteration,
  optionsForSelectFrom,

  resolveQualified,
  resolveQualifiedMaybe,
  // _resolveQualifiedAct,

}

_.assert( !!_.resolver.Resolver.ResolverSelector );
let ResolverExtraSelector = _.looker.define
({
  name : 'ResolverExtraSelector',
  parent : _.resolver.Resolver.ResolverSelector,
  defaults :
  {
    defaultResourceKind : null,
    prefixlessAction : null,
    singleUnwrapping : null,
    mapValsUnwrapping : null,
    mapFlattening : null,
    arrayWrapping : null,
    arrayFlattening : null,
    Resolver : null,
  },
  defaultsSubtraction :
  {
    onUpBegin : null,
    onUpEnd : null,
    onDownEnd : null,
    onQuantitativeFail : null,
  },
  looker :
  {

    optionsToIteration : optionsToIterationOfSelector,

    onSelectorReplicate : _onSelectorReplicate,
    onSelectorDown : _onSelectorDown,
    onUpBegin : _onUpBegin,
    onUpEnd : _onUpEnd,
    onDownEnd : _onDownEnd,
    onQuantitativeFail : _onQuantitativeFail,

    _onSelectorReplicate,
    _onSelectorDown,
    _onUpBegin,
    _onUpEnd,
    _onDownEnd,
    _onQuantitativeFail,

  }
});

_.assert( ResolverExtraSelector._onSelectorReplicate === _onSelectorReplicate );

let functionSymbol = Symbol.for( 'function' );
let Looker =
{

  name : 'resolver',
  shortName : 'resolver',

  ... Common,

  onSelectorReplicate : _onSelectorReplicate,
  onSelectorDown : _onSelectorDown,
  onUpBegin : _onUpBegin,
  onUpEnd : _onUpEnd,
  onDownEnd : _onDownEnd,
  onQuantitativeFail : _onQuantitativeFail,

  // ResolverSelector : ResolverExtraSelector,
  // ResolverExtraSelector,

}

_.assert( !!_.resolver.Resolver );

let Iterator =
{
  resolveExtraOptions : null,
}

let Iteration =
{
}

let IterationPreserve =
{
  isFunction : null,
}

let ResolverExtraReplicator = _.looker.define
({
  name : 'ResolverExtra',
  parent : _.resolver.Resolver,
  // defaults : Defaults, /* xxx */
  looker : Looker,
  iterator : Iterator,
  iteration : Iteration,
  iterationPreserve : IterationPreserve,
});

//

ResolverExtraReplicator.ResolverSelector = ResolverExtraSelector;
ResolverExtraReplicator.ResolverReplicator = ResolverExtraReplicator;

ResolverExtraSelector.ResolverSelector = ResolverExtraSelector;
ResolverExtraSelector.ResolverReplicator = ResolverExtraReplicator;

// ResolverExtraReplicator.ResolverSelector = ResolverExtraSelector;
// ResolverExtraReplicator.ResolverExtraSelector = ResolverExtraSelector;
// ResolverExtraReplicator.ResolverExtra = ResolverExtraReplicator;
// ResolverExtraReplicator.ResolverExtraReplicator = ResolverExtraReplicator;
//
// ResolverExtraSelector.ResolverSelector = ResolverExtraSelector;
// ResolverExtraSelector.ResolverExtraSelector = ResolverExtraSelector;
// ResolverExtraSelector.ResolverExtra = ResolverExtraReplicator;
// ResolverExtraSelector.ResolverExtraReplicator = ResolverExtraReplicator;

/* xxx : pass defaults? */
const Self = ResolverExtraReplicator;
_.assert( ResolverExtraReplicator.Iterator.resolveExtraOptions !== undefined );

//

let ResolverExtension =
{

  ... _.resolver,

  name : 'resolver2',
  shortName : 'resolver2',

  ... Common,

  Looker : ResolverExtraReplicator,
  ResolverExtra : ResolverExtraReplicator,
  ResolverSelector : ResolverExtraSelector,
  ResolverExtraReplicator,
  ResolverExtraSelector,

}

let ToolsExtension =
{

  // ResolverExtra : ResolverExtraReplicator,
  // ResolverExtraReplicator,
  // ResolverExtraSelector,
  // resolveQualified,
  // resolveQualifiedMaybe,

}

_.mapSupplement( _, ToolsExtension );
_.mapExtend( _.resolver2, ResolverExtension );

if( typeof module !== 'undefined' )
module[ 'exports' ] = _;

})();
