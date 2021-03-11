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
_.resolver2 = _.resolver2 || Object.create( null ); /* xxx : inherit? */
_.assert( !!_.resolver.Resolver );

// --
// relations
// --

let Defaults =
{

  // ... _.resolver.resolve.defaults,
  ... _.mapExtend( null, _.resolver.Looker.Prime ),

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

  // Looker : null,
  // Resolver : null, /* xxx : remove */

  onSelectorReplicate : _onSelectorReplicate,
  onSelectorDown : _onSelectorDown,
  onUpBegin : _onUpBegin,
  onUpEnd : _onUpEnd,
  onDownEnd : _onDownEnd,
  onQuantitativeFail : _onQuantitativeFail,

}

// delete Defaults.onSelectorReplicate;
// delete Defaults.onSelectorDown;
// delete Defaults.onUpBegin;
// delete Defaults.onUpEnd;
// delete Defaults.onDownEnd;
// delete Defaults.onQuantitativeFail;

// --
// parser
// --

function strRequestParse( srcStr )
{
  let it = this;
  let rit = it.replicateIteration ? it.replicateIteration : it;
  //let resolver = this;

  if( /*resolver*/it._selectorIs( srcStr ) )
  {
    let left, right;
    let splits = _.strSplit( srcStr );

    if( splits.length > 1 )
    debugger;

    for( let s = splits.length - 1 ; s >= 0 ; s-- )
    {
      let split = splits[ s ];
      if( /*resolver*/it._selectorIs( split ) )
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

  if( splits.length === 1 && _.strIs( splits[ 0 ] ) && /*resolver*/this.selectorIs( splits[ 0 ] ) )
  {
    let o2 = _.mapExtend( null, o );
    o2.selector = splits[ 0 ];
    splits[ 0 ] = /*resolver*/this.selectorLongSplit( o2 );
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
  //let resolver = this;

  if( !/*resolver*/it.selectorIs( src ) )
  return src;

  let parsed = /*resolver*/it.selectorParse( src );
  let result = /*resolver*/it.selectorStr( parsed );

  return result;
}

// --
// iterator methods
// --

function _onSelectorReplicate( o )
{
  let it = this;
  let rit = it.replicateIteration ? it.replicateIteration : it;
  // let rop = it.iterator;
  //let resolver = /*rop*/rit.Resolver;
  let selector = o.selector;

  if( !_.strIs( selector ) )
  return;

  if( /*resolver*/it._selectorIs( selector ) )
  return /*resolver*/it._onSelectorReplicateComposite.call( it, o );

  if( o.counter > 0 )
  return;

  if( /*rop*/rit.prefixlessAction === 'default' && !it.composite )
  {
    return selector;
  }
  else if( /*rop*/rit.prefixlessAction === 'resolved' || /*rop*/rit.prefixlessAction === 'default' )
  {
    return;
  }
  else if( /*rop*/rit.prefixlessAction === 'throw' || /*rop*/rit.prefixlessAction === 'error' )
  {
    debugger;
    it.iterator.continue = false;
    let err = /*resolver*/it.errResolving
    ({
      selector,
      // rop,
      err : _.LookingError( 'Resource selector should have prefix' ),
    });
    if( /*rop*/rit.prefixlessAction === 'throw' )
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
  // let rop = it.iterator;
  //let resolver = /*rop*/rit.Resolver;

  /*resolver*/it._arrayFlatten.call( it );

  if( it.continue && _.arrayIs( it.dst ) && it.src.composite === _.resolver2.compositeSymbol )
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
  // let rop = rit.iterator;
  /* let rop ** = it.resolveExtraOptions ? it.resolveExtraOptions : it.replicateIteration.resolveExtraOptions */
  //let resolver = /*rop*/rit.Resolver;
  let doing = true;

  if( !it.dstWritingDown )
  return;

  /*resolver*/it._queryParse.call( it );
  /*resolver*/it._resourceMapSelect.call( it );

  let recursing = _.strIs( it.dst ) && /*resolver*/it._selectorIs( it.dst );
  if( recursing )
  {

    debugger;
    /* qqq : cover please */
    let o2 = _.mapOnly( it, /*resolver*/it.resolve.defaults );
    o2.selector = it.dst;
    o2.src = it.iterator.src;
    it.src = /*resolver*/it.resolve( o2 ); /* zzz : write result of selection to dst, never to src? */

  }

}

//

function _onUpEnd()
{
  let it = this;
  // let rop = rit.iterator;
  //let resolver = /*rop*/rit.Resolver;

  if( !it.dstWritingDown )
  return;

}

//

function _onDownEnd()
{
  let it = this;
  let rit = it.replicateIteration ? it.replicateIteration : it;
  // let rop = rit.iterator;
  //let resolver = /*rop*/rit.Resolver;

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
  // let rop = rit.iterator;
  //let resolver = /*rop*/rit.Resolver;

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
  let rit = it.replicateIteration ? it.replicateIteration : it;
  // let rop = rit.iterator;
  //let resolver = /*rop*/rit.Resolver;
  let currentModule = it.currentModule;

  // _.assert( _.objectIs( rop ) );

  if( !/*rop*/rit.arrayFlattening || !_.arrayIs( it.dst ) )
  return;

  it.dst = _.arrayFlattenDefined( it.dst );

}

//

function _arrayWrap( result )
{
  let it = this;
  let rit = it.replicateIteration ? it.replicateIteration : it;
  // let rop = rit.iterator;
  //let resolver = /*rop*/rit.Resolver;

  if( !/*rop*/rit.arrayWrapping )
  return;

  if( !_.mapIs( it.dst ) )
  it.dst = _.arrayAs( it.dst );

}

//

function _mapsFlatten()
{
  let it = this;
  let rit = it.replicateIteration ? it.replicateIteration : it;
  // let rop = rit.iterator;
  //let resolver = /*rop*/rit.Resolver;

  if( !/*rop*/rit.mapFlattening || !_.mapIs( it.dst ) )
  return;

  it.dst = _.mapsFlatten([ it.dst ]);

}

//

function _mapValsUnwrap()
{
  let it = this;
  let rit = it.replicateIteration ? it.replicateIteration : it;
  // let rop = rit.iterator;
  //let resolver = /*rop*/rit.Resolver;
  // _.debugger;

  if( !/*rop*/rit.mapValsUnwrapping )
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
  let rit = it.replicateIteration ? it.replicateIteration : it;
  // let rop = rit.iterator;
  //let resolver = /*rop*/rit.Resolver;

  if( !/*rop*/rit.singleUnwrapping )
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
  let rit = it.replicateIteration ? it.replicateIteration : it;
  // let rop = rit.iterator;
  //let resolver = /*rop*/rit.Resolver;

  if( !it.selector )
  return;

  let splits = /*resolver*/it.selectorShortSplit
  ({
    selector : it.selector,
    defaultResourceKind : /*rop*/rit.defaultResourceKind,
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
  let rit = it.replicateIteration ? it.replicateIteration : it;
  // let rop = rit.iterator;
  //let resolver = /*rop*/rit.Resolver;

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
      /*resolver*/it._functionStringsJoinUp.call( it );
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
  let rit = it.replicateIteration ? it.replicateIteration : it;
  // let rop = rit.iterator;

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
  let rit = it.replicateIteration ? it.replicateIteration : it;
  // let rop = rit.iterator;

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
  let it = this;
  let rit = it.replicateIteration ? it.replicateIteration : it;
  //let resolver = this;
  _.assertRoutineOptions( errResolving, arguments );
  _.assert( arguments.length === 1 );
  debugger;
  /* xxx : tag error */
  /* xxx : avoid recreation of error */
  return _.err( 'Failed to resolve', _.color.strFormat( _.entity.exportStringShort( o.selector ), 'path' ), '\n', o.err ); /* xxx : use _.ct? */
}

errResolving.defaults =
{
  selector : null,
  // rop : null,
  err : null,
}

//

function errResolvingThrow( o )
{
  //let resolver = this;
  _.assertRoutineOptions( errResolvingThrow, arguments );
  _.assert( arguments.length === 1 );
  if( o.missingAction === 'undefine' )
  return;

  debugger;

  let err = /*resolver*/it.errResolving
  ({
    selector : o.selector,
    // rop : o.rop,
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
  // rop : null,
  err : null,
}

// --
// resolve
// --

// /* xxx : remove */
// function head( routine, args )
// {
//   _.assert( arguments.length === 2 );
//   let o = routine.defaults.Looker.optionsFromArguments( args );
//   if( _.routineIs( routine ) )
//   o.Looker = o.Looker || routine.defaults.Looker;
//   else
//   o.Looker = o.Looker || routine.Looker;
//
//   _.assert( _.routineIs( routine ) || _.auxIs( routine ) );
//   if( _.routineIs( routine ) ) /* zzz : remove "if" later */
//   _.assertMapHasOnly( o, routine.defaults );
//   // _.routineOptionsPreservingUndefines( routine, o );
//   else if( routine !== null )
//   _.assertMapHasOnly( o, routine );
//   // _.routineOptionsPreservingUndefines( null, o, routine );
//
//   // o.Looker.optionsForm( routine, o );
//   o.optionsForSelect = o.Looker.selectorOptionsForSelectFrom( o );
//   let it = o.Looker.optionsToIteration( null, o );
//   return it;
// }

//

function perform() /* xxx : rename to body? */
{
  let it = this;

  /* */

  it.performBegin();

  // _.debugger;

  try
  {
    it.iterate();
    // Parent.perform.call( it );
  }
  catch( err )
  {
    throw it.errResolving
    ({
      selector : it.selector,
      // rop : it,
      err,
    });
  }

  // _.debugger;

  it.performEnd();

  return it;
}

//

function performBegin()
{
  let it = this;
  Parent.performBegin.apply( it, arguments );

  // _.assert( Object.is( it.originalSrc, it.src ) );
  _.assert( _.arrayIs( it.visited ) );
  _.assert( it.Resolver === undefined );
  _.assert( arguments.length === 0 );
  _.assert( _.arrayIs( it.visited ) );
  // _.assert( !!it.resolveExtraOptions );
  _.assert( it.resolveExtraOptions === undefined );

  _.assert( it.onSelectorReplicate === it.Looker._onSelectorReplicate );
  _.assert( it.onSelectorDown === it.Looker._onSelectorDown );
  _.assert( it.onUpBegin === it.Looker._onUpBegin );
  _.assert( it.onUpEnd === it.Looker._onUpEnd );
  _.assert( it.onDownEnd === it.Looker._onDownEnd );
  _.assert( it.onQuantitativeFail === it.Looker._onQuantitativeFail );

  return it;
}

//

function performEnd()
{
  let it = this;
  let result = it.result;

  if( result === undefined )
  {
    result = it.errResolving
    ({
      selector : it.selector,
      // rop : it,
      err : _.LookingError( it.selector, 'was not found' ),
    })
  }

  if( _.errIs( result ) )
  {
    return it.errResolvingThrow
    ({
      missingAction : it.missingAction,
      selector : it.selector,
      // rop : it,
      err : result,
    });
  }

  it._mapsFlatten();
  it._mapValsUnwrap();
  it._singleUnwrap();
  it._arrayWrap();

  Parent.performEnd.apply( it, arguments );
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

  // if( o.Resolver === null )
  // o.Resolver = _.resolver2; /* xxx */

  _.assert( o.iteratorProper( o ) );
  _.assert( o.Resolver === undefined );
  _.assert( o.resolvingRecursive !== undefined );
  _.assert( arguments.length === 2 );
  _.assert( _.longHas( [ 'undefine', 'throw', 'error' ], o.missingAction ), 'Unknown value of option missing action', o.missingAction );
  _.assert( _.longHas( [ 'default', 'resolved', 'throw', 'error' ], o.prefixlessAction ), 'Unknown value of option prefixless action', o.prefixlessAction );
  _.assert( _.arrayIs( o.visited ) );
  _.assert( !o.defaultResourceKind || !_.strHas( o.defaultResourceKind, '*' ), () => 'Expects non glob {-defaultResourceKind-}, but got ' + _.strQuote( o.defaultResourceKind ) );

  return o;
}

//

function optionsToIteration( iterator, o )
{
  let it = Parent.optionsToIteration.call( this, iterator, o );

  // it.iterator.resolveExtraOptions = o; /* xxx */

  _.assert( arguments.length === 2 );
  _.assert( it.onSelectorReplicate === it.Looker._onSelectorReplicate );
  _.assert( it.onSelectorDown === it.Looker._onSelectorDown );
  _.assert( it.onUpBegin === it.Looker._onUpBegin );
  _.assert( it.onUpEnd === it.Looker._onUpEnd );
  _.assert( it.onDownEnd === it.Looker._onDownEnd );
  _.assert( it.onQuantitativeFail === it.Looker._onQuantitativeFail );

  return it;
}

//

function selectorOptionsForSelectFrom( o )
{
  let it = this;

  let o2 = Parent.selectorOptionsForSelectFrom.call( it, o );

  // _.assert( !!o.onSelectorReplicate );
  // _.assert( !!o.onSelectorDown );
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
  // _.assert( o.onQuantitativeFail === undefined );

  let it = Parent.Selector.optionsToIteration.call( this, iterator, o );

  _.assert( it.onSelectorReplicate === undefined );
  _.assert( it.onSelectorDown === undefined );
  // _.assert( it.onSelectorReplicate === it.Looker._onSelectorReplicate );
  // _.assert( it.onSelectorDown === it.Looker._onSelectorDown );
  _.assert( it.onUpBegin === it.Looker._onUpBegin );
  _.assert( it.onUpEnd === it.Looker._onUpEnd );
  _.assert( it.onDownEnd === it.Looker._onDownEnd );
  _.assert( it.onQuantitativeFail === it.Looker._onQuantitativeFail );

  return it;
}

// //
//
// function resolve_head( routine, args )
// {
//   return routine.defaults.head( routine, args );
// }
//
// //
//
// /* xxx : rename */
// function resolve_body( it )
// {
//   it.perform();
//   return it.result;
// }

// Defaults.onSelectorReplicate = _onSelectorReplicate;
// Defaults.onSelectorDown = _onSelectorDown;
// Defaults.onUpBegin = _onUpBegin;
// Defaults.onUpEnd = _onUpEnd;
// Defaults.onDownEnd = _onDownEnd;
// Defaults.onQuantitativeFail = _onQuantitativeFail;

// resolve_body.defaults = Defaults;

// let resolve = _.routineUnite( resolve_head, resolve_body );
// let resolveMaybe = _.routineUnite( resolve_head, resolve_body );
//
// var defaults = resolveMaybe.defaults;
// defaults.missingAction = 'undefine';

// --
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

  // err

  errResolving,
  errResolvingThrow,

}

_.assert( !!_.resolver.Resolver.Selector );
// let ResolverExtraSelector = _.looker.classDefine
let ResolverExtraSelector =
({
  name : 'ResolverExtraSelector',
  parent : _.resolver.Resolver.Selector,
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
  // defaultsSubtraction :
  // {
  // },
  looker :
  {
    ... Common,

    optionsToIteration : optionsToIterationOfSelector,

    _onUpBegin,
    _onUpEnd,
    _onDownEnd,
    _onQuantitativeFail,

  }
});

// _.assert( ResolverExtraSelector._onSelectorReplicate === _onSelectorReplicate );
_.assert( !!_.resolver.Resolver );

// let ResolverExtraReplicator = _.looker.classDefine
let ResolverExtraReplicator =
({
  name : 'ResolverExtra',
  parent : _.resolver.Resolver,
  defaults : Defaults, /* xxx */
  looker :
  {

    ... Common,

    name : 'resolver',
    shortName : 'resolver',

    onSelectorReplicate : _onSelectorReplicate,
    onSelectorDown : _onSelectorDown,

    // head,
    perform,
    performBegin,
    performEnd,
    // exec : resolve,
    optionsFromArguments,
    optionsForm,
    optionsToIteration,
    selectorOptionsForSelectFrom,

    // resolve, /* xxx : rename to resolve */
    // resolveMaybe, /* xxx : rename to resolveMaybe */

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

let Resolver2 = _.resolver.classDefine
({
  selector : ResolverExtraSelector,
  replicator : ResolverExtraReplicator,
});

_.assert( Resolver2.Selector._onSelectorReplicate === _onSelectorReplicate ); /* xxx : rename to Selector? */

// ResolverExtraReplicator.Selector = ResolverExtraSelector;
// ResolverExtraReplicator.Replicator = ResolverExtraReplicator;
//
// ResolverExtraSelector.Selector = ResolverExtraSelector;
// ResolverExtraSelector.Replicator = ResolverExtraReplicator;

//

/* xxx : pass defaults? */
const Self = Resolver2;
_.assert( Resolver2.IterationPreserve.isFunction !== undefined );

// let resolveMaybe = _.routineUnite( Resolver2.exec.head, Resolver2.exec.body );
// let resolveMaybe = _.routineUnite({ head : Resolver2.exec.head, body : Resolver2.exec.body, strategy : 'inheriting' });
let resolveMaybe = _.routine.uniteInheriting( Resolver2.exec.head, Resolver2.exec.body );
var defaults = resolveMaybe.defaults;
defaults.Looker = defaults;
defaults.missingAction = 'undefine';
_.assert( Resolver2.exec.body.defaults.missingAction === 'throw' );
_.assert( Resolver2.exec.defaults.missingAction === 'throw' );

//

let ResolverExtension =
{

  ... _.resolver,
  // ... Common, /* xxx : remove */

  name : 'resolver2',
  shortName : 'resolver2',

  resolve : Resolver2.exec,
  resolveMaybe,

  Looker : Resolver2,
  Resolver : Resolver2,
  // ResolverExtra : Resolver2,
  // Selector : Resolver2.Selector,
  // ResolverExtraReplicator : Resolver2,
  // ResolverExtraSelector : Resolver2.Selector,

}

let ToolsExtension =
{
}

_.mapSupplement( _, ToolsExtension );
_.mapExtend( _.resolver2, ResolverExtension );

if( typeof module !== 'undefined' )
module[ 'exports' ] = _;

})();
