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

  const _ = require( '../../../node_modules/Tools' );
  _.include( 'wLooker' );
  _.include( 'wSelector' );
  _.include( 'wResolver' );

}

const _global = _global_;
const _ = _global_.wTools;
const Parent = _.resolver.Resolver;
_.resolverAdv = _.resolverAdv || Object.create( _.resolver );
_.assert( !!_.resolver.Resolver );

/* qqq : write nice example for readme */

// --
// relations
// --

let Prime =
{

  selector : null,
  defaultResourceKind : null,
  prefixlessAction : 'resolved',
  // missingAction : 'throw',
  visited : null,
  singleUnwrapping : 1,
  mapValsUnwrapping : 1,
  mapFlattening : 1,
  arrayWrapping : 0,
  arrayFlattening : 1,
  preservingIteration : 0,

  recursive : 32,

  onSelectorReplicate : _onSelectorReplicate,
  onSelectorDown : _onSelectorDown,
  onUpBegin : _onUpBegin,
  onUpEnd : _onUpEnd,
  onDownEnd : _onDownEnd,
  onQuantitativeFail : _onQuantitativeFail,

}

// --
// parser
// --

function strRequestParse( srcStr )
{
  let it = this;
  let rit = it.replicateIteration ? it.replicateIteration : it;

  if( it._selectorIs( srcStr ) )
  {
    let left, right;
    let splits = _.strSplit( srcStr );

    for( let s = splits.length - 1 ; s >= 0 ; s-- )
    {
      let split = splits[ s ];
      if( it._selectorIs( split ) )
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

  _.routine.assertOptions( selectorShortSplit, o );
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

  _.routine.options_( selectorLongSplit, o );
  _.assert( arguments.length === 1 );
  _.sure( _.strIs( o.selector ) || _.strsAreAll( o.selector ), 'Expects string, but got', _.entity.strType( o.selector ) );

  let selectors = o.selector.split( '/' );

  selectors.forEach( ( selector ) =>
  {
    let o2 = _.props.extend( null, o );
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
  let result = [];

  if( _.strIs( o ) )
  o = { selector : o }

  _.routine.options_( selectorParse, o );
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

    let o2 = _.props.extend( null, o );
    o2.selector = split[ 1 ];
    return this.selectorLongSplit( o2 );
  });

  splits = _.strSplitsUngroupedJoin( splits );

  if( splits.length === 1 && _.strIs( splits[ 0 ] ) && this.selectorIs( splits[ 0 ] ) )
  {
    let o2 = _.props.extend( null, o );
    o2.selector = splits[ 0 ];
    splits[ 0 ] = this.selectorLongSplit( o2 );
  }

  return splits;
}

var defaults = selectorParse.defaults = Object.create( null )
defaults.selector = null
defaults.defaultResourceKind = null;

//

function selectorStr( parsedSelector )
{
  let it = this;
  let rit = it.replicateIteration ? it.replicateIteration : it;
  //let resolver = this;

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
  let it = this;
  let rit = it.replicateIteration ? it.replicateIteration : it;

  if( !it.selectorIs( src ) )
  return src;

  let parsed = it.selectorParse( src );
  let result = it.selectorStr( parsed );

  return result;
}

// --
// iterator methods
// --

function _onSelectorReplicate( o )
{
  let it = this;
  let rit = it.replicateIteration ? it.replicateIteration : it;
  let selector = o.selector;

  if( !_.strIs( selector ) )
  return;

  if( it._selectorIs( selector ) )
  return it._onSelectorReplicateComposite.call( it, o );

  if( o.counter > 0 )
  return;

  if( rit.prefixlessAction === 'default' && !it.composite )
  {
    return selector;
  }
  else if( rit.prefixlessAction === 'resolved' || rit.prefixlessAction === 'default' )
  {
    return;
  }
  else if( rit.prefixlessAction === 'throw' || rit.prefixlessAction === 'error' )
  {
    it.iterator.continue = false;
    let err = it.errResolvingMake
    ({
      selector,
      err : _.looker.SeekingError( 'Resource selector should have prefix' ),
    });
    if( rit.prefixlessAction === 'throw' )
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
  let rit = it.replicateIteration ? it.replicateIteration : it;

  it._arrayFlatten();

  if( it.continue && _.arrayIs( it.dst ) && it.src.composite === _.resolverAdv.compositeSymbol )
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
  let rit = it.replicateIteration ? it.replicateIteration : it;
  let doing = true;

  if( !it.dstWritingDown )
  return;

  _.debugger;

  it._queryParse();
  it._resourceMapSelect();

  let recursing = _.strIs( it.dst ) && it._selectorIs( it.dst );
  if( recursing )
  {

    /* qqq : cover please */
    let o2 = _.mapOnly_( null, it, it.resolve.defaults );
    o2.selector = it.dst;
    o2.src = it.iterator.src;
    it.src = it.resolve( o2 ); /* zzz : write result of selection to dst, never to src? */

  }

}

//

function _onUpEnd()
{
  let it = this;

  if( !it.dstWritingDown )
  return;

}

//

function _onDownEnd()
{
  let it = this;
  let rit = it.replicateIteration ? it.replicateIteration : it;

  _.assert( !!it.replicateIteration );

  if( !it.dstWritingDown )
  return;

  it._functionStringsJoinDown();
  it._mapsFlatten();
  it._mapValsUnwrap();
  it._arrayFlatten();
  it._singleUnwrap();


}

//

function _onQuantitativeFail( err )
{
  let it = this;
  let rit = it.replicateIteration ? it.replicateIteration : it;

  let result = it.dst;
  if( _.mapIs( result ) )
  result = _.props.vals( result );
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
  let rit = it.replicateIteration ? it.replicateIteration : it;
  let currentModule = it.currentModule;

  if( !rit.arrayFlattening || !_.arrayIs( it.dst ) )
  return;

  it.dst = _.arrayFlattenDefined( it.dst );

}

//

function _arrayWrap( result )
{
  let it = this;
  let rit = it.replicateIteration ? it.replicateIteration : it;

  if( !rit.arrayWrapping )
  return;

  if( !_.mapIs( it.dst ) )
  it.dst = _.array.as( it.dst );

}

//

function _mapsFlatten()
{
  let it = this;
  let rit = it.replicateIteration ? it.replicateIteration : it;

  if( !rit.mapFlattening || !_.mapIs( it.dst ) )
  return;

  it.dst = _.mapsFlatten([ it.dst ]);

}

//

function _mapValsUnwrap()
{
  let it = this;
  let rit = it.replicateIteration ? it.replicateIteration : it;

  if( !rit.mapValsUnwrapping )
  return;
  if( !_.mapIs( it.dst ) )
  return;
  if( !_.all( it.dst, ( e ) => _.instanceIs( e ) || _.primitiveIs( e ) ) )
  return;

  it.dst = _.props.vals( it.dst );
}

//

function _singleUnwrap()
{
  let it = this;
  let rit = it.replicateIteration ? it.replicateIteration : it;

  if( !rit.singleUnwrapping )
  return;

  if( _.any( it.dst, ( e ) => _.mapIs( e ) || _.arrayIs( e ) ) )
  return;

  if( _.mapIs( it.dst ) )
  {
    if( _.props.keys( it.dst ).length === 1 )
    it.dst = _.props.vals( it.dst )[ 0 ];
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
  let rit = it.replicateIteration ? it.replicateIteration : it;

  if( !it.selector )
  return;

  let splits = it.selectorShortSplit
  ({
    selector : it.selector,
    defaultResourceKind : rit.defaultResourceKind,
  });

  it.parsedSelector = Object.create( null );
  it.parsedSelector.kind = splits[ 0 ];

  if( !it.parsedSelector.kind )
  {
    if( splits[ 1 ] !== undefined )
    it.parsedSelector.kind = null;
  }

  it.parsedSelector.full = splits.join( '' );

  let selectorChanged = it.selector !== splits[ 2 ];
  it.selector = it.parsedSelector.name = splits[ 2 ];
  if( selectorChanged )
  {
    it.selectorType = null;
    it.iterable = null;
    it.iterationSelectorChanged();
    it.srcChanged();
  }

}

//

function _resourceMapSelect()
{
  let it = this;
  let rit = it.replicateIteration ? it.replicateIteration : it;

  if( it.selector === undefined || it.selector === null )
  return;

  let kind = it.parsedSelector.kind;
  if( kind === '' || kind === null )
  {
  }
  else if( kind === 'f' )
  {

    /* zzz qqq : cover */
    it.isFunction = it.selector;
    if( it.selector === 'strings.join' )
    {
      it._functionStringsJoinUp();
    }
    else _.sure( 0, 'Unknown function', it.parsedSelector.full );

  }
  else
  {
    /* zzz */
    let root = it.root || it;

    let k, c;
    [ it.src, k, c, it.exists ] = it.elementGet( it.iterator.src, kind, null );

    // it.src = it.iterator.src[ kind ];
    // it.exists = _.props.has( it.iterator.src, kind );
    // yyy
    // if( it.selector === '.' )
    // it.src = { '.' : it.src }
    // debugger;
    if( !it.exists )
    {
      it.errHandle( () => it.errDoesNotExist() );
      // it.errHandle
      // ({
      //   missingAction : it.missingAction,
      //   selector : it.selector,
      // });
    }

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
  let rit = it.replicateIteration ? it.replicateIteration : it;

  _.sure( !!it.down, () => it.parsedSelector.full + ' expects context to join it' );

  it.src = [ it.src ];
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
  let rit = it.replicateIteration ? it.replicateIteration : it;

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
// resolve
// --

function performBegin()
{
  let it = this;

  Parent.performBegin.apply( it, arguments );

  _.assert( _.arrayIs( it.visited ) );
  _.assert( it.Resolver === undefined );
  _.assert( arguments.length === 0 );
  _.assert( _.arrayIs( it.visited ) );
  _.assert( it.resolveExtraOptions === undefined );

  _.assert( it.onSelectorReplicate === it.Seeker._onSelectorReplicate );
  _.assert( it.onSelectorDown === it.Seeker._onSelectorDown );
  _.assert( it.onUpBegin === it.Seeker._onUpBegin );
  _.assert( it.onUpEnd === it.Seeker._onUpEnd );
  _.assert( it.onDownEnd === it.Seeker._onDownEnd );
  _.assert( it.onQuantitativeFail === it.Seeker._onQuantitativeFail );

  return it;
}

//

/* qqq : implement good test covering resolving with undefined result */
function performEnd()
{
  let it = this;

  it._mapsFlatten();
  it._mapValsUnwrap();
  it._singleUnwrap();
  it._arrayWrap();

  Parent.performEnd.apply( it, arguments );

  // debugger;
  // let result = it.result;
  // if( result === undefined || _.errIs( result ) )
  // {
  //   return it.errResolvingHandle
  //   ({
  //     missingAction : it.missingAction,
  //     selector : it.selector,
  //     err : () =>
  //     {
  //       if( _.errIs( result ) )
  //       return result;
  //       return it.errResolvingMake
  //       ({
  //         selector : it.selector,
  //         err : _.looker.SeekingError( it.selector, 'was not found' ),
  //       })
  //     }
  //   });
  // }

  return it;
}

//

function optionsFromArguments( args )
{
  let o = args[ 0 ];

  if( args.length === 2 )
  {
    _.assert( !_.resolverAdv.iterationIs( args[ 0 ] ) );
    o = { src : args[ 0 ], selector : args[ 1 ] }
  }

  _.assert( args.length === 1 || args.length === 2 );
  _.assert( arguments.length === 1 );
  _.assert( _.mapIs( o ) );

  return o;
}

//

function optionsToIteration( iterator, o )
{
  let it = Parent.optionsToIteration.call( this, iterator, o );

  _.assert( arguments.length === 2 );
  _.assert( it.onSelectorReplicate === it.Seeker._onSelectorReplicate );
  _.assert( it.onSelectorDown === it.Seeker._onSelectorDown );
  _.assert( it.onUpBegin === it.Seeker._onUpBegin );
  _.assert( it.onUpEnd === it.Seeker._onUpEnd );
  _.assert( it.onDownEnd === it.Seeker._onDownEnd );
  _.assert( it.onQuantitativeFail === it.Seeker._onQuantitativeFail );

  return it;
}

//

function iteratorInitEnd( iterator )
{
  let looker = this;
  let result = Parent.iteratorInitEnd.call( this, iterator );

  if( iterator.visited === null )
  iterator.visited = [];

  _.assert( iterator.iteratorProper( iterator ) );
  _.assert( iterator.resolvingRecursive >= 0 );
  _.assert( arguments.length === 1 );
  _.assert
  (
    _.longHas( [ 'default', 'resolved', 'throw', 'error' ], iterator.prefixlessAction ),
    'Unknown value of option prefixless action', iterator.prefixlessAction /* qqq : template string in all files */
  );
  _.assert( _.arrayIs( iterator.visited ) );
  _.assert
  (
    !iterator.defaultResourceKind || !_.strHas( iterator.defaultResourceKind, '*' ),
    () => 'Expects non glob {-defaultResourceKind-}, but got ' + _.strQuote( iterator.defaultResourceKind )
  );

  return result;
}

//

function selectorOptionsForSelectFrom( o )
{
  let it = this;

  let o2 = Parent.selectorOptionsForSelectFrom.call( it, o );

  _.assert( !!o2.onUpBegin );
  _.assert( !!o2.onUpEnd );
  _.assert( !!o2.onDownEnd );
  _.assert( !!o2.onQuantitativeFail );

  return o2;
}

//

function optionsToIterationOfSelector( iterator, o )
{

  _.assert( arguments.length === 2 );
  _.assert( o.onSelectorReplicate === undefined );
  _.assert( o.onSelectorDown === undefined );
  _.assert( o.onUpBegin !== undefined );
  _.assert( o.onUpEnd !== undefined );
  _.assert( o.onDownEnd !== undefined );
  _.assert( o.onQuantitativeFail !== undefined );

  let it = Parent.Selector.optionsToIteration.call( this, iterator, o );

  _.assert( it.onSelectorReplicate === undefined );
  _.assert( it.onSelectorDown === undefined );
  _.assert( it.onUpBegin === it.Seeker._onUpBegin );
  _.assert( it.onUpEnd === it.Seeker._onUpEnd );
  _.assert( it.onDownEnd === it.Seeker._onDownEnd );
  _.assert( it.onQuantitativeFail === it.Seeker._onQuantitativeFail );

  return it;
}

// ---
// relations
// --

let functionSymbol = Symbol.for( 'function' );

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

}

_.assert( !!_.resolver.Resolver.Selector );

//

let Selector =
({
  name : 'ResolverSelectorAdv',
  prime :
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
  seeker :
  {
    ... Common,

    optionsToIteration : optionsToIterationOfSelector,

    _onUpBegin,
    _onUpEnd,
    _onDownEnd,
    _onQuantitativeFail,

  }
});

_.assert( !!_.resolver.Resolver );

let Replicator =
({
  name : 'ResolverAdv',
  prime : Prime,
  seeker :
  {

    ... Common,

    name : 'resolver',
    shortName : 'resolver',

    onSelectorReplicate : _onSelectorReplicate,
    onSelectorDown : _onSelectorDown,

    performBegin,
    performEnd,
    optionsFromArguments,
    optionsToIteration,
    iteratorInitEnd,
    selectorOptionsForSelectFrom,

  },
  iterator :
  {
  },
  iterationPreserve :
  {
    isFunction : null,
  },
});

//

let ResolverAdv = _.resolver.classDefine
({
  selector : Selector,
  replicator : Replicator,
});

_.assert( ResolverAdv.Selector._onSelectorReplicate === _onSelectorReplicate );

//

const Self = ResolverAdv;

_.assert( ResolverAdv.IterationPreserve.isFunction !== undefined );
_.assert( ResolverAdv.Iteration.isFunction !== undefined );
// _.assert( ResolverAdv.Iteration.isFunction === undefined );
_.assert( ResolverAdv.Iterator.isFunction === undefined );
// _.assert( ResolverAdv.isFunction !== undefined );
_.assert( ResolverAdv.isFunction === undefined );

let resolveMaybe = _.routine.uniteInheriting( ResolverAdv.exec.head, ResolverAdv.exec.body );
var defaults = resolveMaybe.defaults;
defaults.Seeker = defaults;
defaults.missingAction = 'undefine';
_.assert( ResolverAdv.exec.body.defaults.missingAction === 'throw' );
_.assert( ResolverAdv.exec.defaults.missingAction === 'throw' );

//

let ResolverExtension =
{

  name : 'resolverAdv',
  resolve : ResolverAdv.exec,
  resolveMaybe,
  Seeker : ResolverAdv,
  Resolver : ResolverAdv,

}

let ToolsExtension =
{
}

_.props.extend( _, ToolsExtension );
/* _.props.extend */Object.assign( _.resolverAdv, ResolverExtension );

if( typeof module !== 'undefined' )
module[ 'exports' ] = _;

})();
