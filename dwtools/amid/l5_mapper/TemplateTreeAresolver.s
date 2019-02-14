( function _TemplateTreeAresolver_s_( ) {

'use strict';


/**
 * Class to resolve tree-like with links data structures or paths in the structure. Use the module to resolve template or path to value.
  @module Tools/mid/TemplateTreeResolver
*/

/**
 * @file TemplateTreeResolver.s.
 */

if( typeof module !== 'undefined' )
{

  let _ = require( '../../Tools.s' );

  _.include( 'wCopyable' );

}

let _ = _global_.wTools;
let Parent = null;
let Self = function wTemplateTreeResolver( o )
{
  return _.instanceConstructor( Self, this, arguments );
}

Self.shortName = 'TemplateTreeResolver';

// --
// inter
// --

function init( o )
{
  let self = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.instanceInit( self );

  if( self.constructor === Self )
  Object.preventExtensions( self );

  if( o )
  self.copy( o );

}

// --
// resolve
// --

function resolveString( src )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.strIs( src ) );

  return self.resolve( self.prefixToken + srcStr + self.postfixSymbo );
}

//

function resolve( src )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  let result = self._resolve( src );

  if( result instanceof self.ErrorLooking )
  {
    let result = self._resolve( src );
    throw _.err( result );
  }

  return result;
}

//

function resolveTry( src )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  let result = self._resolve( src );

  if( result instanceof self.ErrorLooking )
  return;

  return result;
}

//

function _resolve( src )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( self.stack.length === 0, 'Something wrong with stack' );

  let result = self._resolveEnter
  ({
    subject : src,
    rootContainer : self.tree,
    currentContainer : self.tree,
    query : '',
    path : self.upTokenDefault(),
  });

  _.assert( self.stack.length === 0, 'Something wrong with stack' );

  return result;
}

//

function _resolveEnter( o )
{
  let self = this;
  // let l = self.current.length;
  // let current = self.current[ l-1 ];
  let current = self.stack[ self.stack.length-1 ];

  _.assert( arguments.length === 1 );
  _.routineOptionsPreservingUndefines( _resolveEnter, arguments );

  if( o.path === null )
  o.path = current ? current.path : self.upTokenDefault();

  // let entered = self._enter
  // ({
  //   rootContainer : o.rootContainer,
  //   currentContainer : o.currentContainer,
  //   subject : o.subject,
  //   query : o.query,
  //   path : o.path,
  //   throwing : 0,
  // });

  // if( entered instanceof self.ErrorLooking )
  // {
  //   debugger;
  //   return entered;
  // }

  let result = self._resolveEntered( o.subject );

  // self._leave( o.path );

  // _.assert( self.current.length === l );

  return result;
}

_resolveEnter.defaults =
{
  subject : null,
  rootContainer : null,
  currentContainer : null,
  query : null,
  path : null,
}

//

function _resolveEntered( src )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  if( !self.shouldInvestigate( src ) )
  return src;

  if( _.strIs( src ) )
  return self._resolveString( src );

  if( _.regexpIs( src ) )
  return self._resolveRegexp( src );

  if( _.mapIs( src ) )
  return self._resolveMap( src );

  if( _.longIs( src ) )
  return self._resolveArray( src );

  throw _.err( 'Unexpected type of src', _.strType( src ) );
}

//

function _resolveString( src )
{
  let self = this;
  let r;
  let rarray = [];
  let throwen = 0;
  // let current = self.current[ self.current.length - 1 ];
  let current = self.stack[ self.stack.length-1 ];

  if( src === '' )
  return src;

  let o2 =
  {
    src : src,
    prefix : self.prefixToken,
    postfix : self.postfixToken,
    onInlined : function( src ){ return [ src ]; },
  }

  let strips = _.strExtractInlinedStereo( o2 );

  /* */

  for( let s = 0 ; s < strips.length ; s++ )
  {
    let element;
    let strip = strips[ s ];

    if( _.strIs( strip ) )
    {
      element = strip;
    }
    else
    {
      _.assert( strip.length === 1 );
      strip = strip[ 0 ];
      element = handleStrip( strip );
    }

    _.assert( _.strIs( strip ) );

    if( element instanceof _.ErrorLooking || throwen )
    {
      // debugger;
      element = _.err
      (
        'Cant resolve', _.strQuote( src.substring( 0,80 ) ),
        '\n', _.strQuote( strip ), 'is not defined', '\n',
        element
      );

      if( throwen )
      throw element

      return element;
    }

    if( strips.length > 1 )
    {
      _.assert( element !== undefined );
      let element2 = self.strFrom( element );
      if( !_.strIs( element2 ) && !_.arrayIs( element2 ) && !_.mapIs( element2 ) )
      {
        debugger;
        element2 = _.err
        (
         'Cant resolve', _.strQuote( src.substring( 0,80 ) ), '\n', _.strQuote( strip ), 'is', _.strType( element2 ), '\n',
         'Allowed types are: String, Array, Map'
        );
        return element2;
      }
      element = element2;
    }

    rarray.push( element );

  }

  /* */

  if( rarray.length <= 1 )
  return rarray[ 0 ];

  let result;

  try
  {
    result = self.strJoin.apply( self, rarray );
  }
  catch( err )
  {
    throw _.err
    (
      'Can\'t mix different elements of template :', _.strQuote( src.substring( 0,80 ) ),
      '\n','Elements:\n',rarray,'\n', err.message
    );
  }

  return result;

  /* */

  function handleStrip( strip )
  {
    let element = strip;

    let it;
    try
    {
      it = self._queryTracking( element );
    }
    catch( err )
    {
      throwen = 1;
      element = err;
    }

    if( it && it.error )
    element = it.error;

    if( it && !it.error )
    {
      let lit = it.lastSelect;
      self._queryBegin( lit );

      if( it.error )
      {
        element = it.error;
      }
      else
      {

        let element2 = it.result;
        if( element !== element2 && element2 !== undefined )
        {
          // debugger;
          element2 = self._resolveEnter
          ({
            subject : element2,
            rootContainer : current ? current.root : self.tree,
            currentContainer : it.lastSelect.src,
            path : it.lastSelect.path,
            query : '',
          });
        }
        element = element2;

        self._queryEnd( lit );
      }

    }

    return element
  }

}

//

function _resolveRegexp( src )
{
  let self = this;

  _.assert( _.regexpIs( src ) );

  let source = src.source;
  // debugger;
  source = self._resolveString( source );
  // debugger;

  if( source instanceof self.ErrorLooking )
  return source;

  if( source === src.source )
  return src;

  src = new RegExp( source, src.flags );

  return src;
}

//

function _resolveMap( src )
{
  let self = this;
  // let current = self.current[ self.current.length - 1 ];
  let current = self.stack[ self.stack.length-1 ];
  let result = Object.create( null );

  for( let s in src )
  {
    result[ s ] = self._resolveEnter
    ({
      subject : src[ s ],
      currentContainer : src[ s ],
      rootContainer : current ? current.root : self.tree,
      query : s,
    });
    if( result[ s ] instanceof self.ErrorLooking )
    {
      return result[ s ];
    }
  }

  return result;
}

//

function _resolveArray( src )
{
  let self = this;
  // let current = self.current[ self.current.length - 1 ];
  let current = self.stack[ self.stack.length-1 ];
  let result = new src.constructor( src.length );

  for( let s = 0 ; s < src.length ; s++ )
  {
    result[ s ] = self._resolveEnter
    ({
      subject : src[ s ],
      currentContainer : src[ s ],
      rootContainer : current ? current.root : self.tree,
      query : s,
    });
    if( result[ s ] instanceof self.ErrorLooking )
    {
      return result[ s ];
    }
  }

  return result;
}

// --
// query
// --

function query_pre( routine, args )
{

  args = _.longSlice( args );

  let o = args[ 0 ]
  if( _.strIs( o ) )
  o = { query : o }

  o.container = this.tree;
  o.downToken = this.downToken;
  o.upToken = this.upToken;

  _.assert( arguments.length === 2 );
  _.assert( args.length === 1 );

  return _.selectSingle.pre.call( this, routine, [ o ] );
}

//

function _queryAct_body( it )
{
  let self = this;
  let result = _.selectSingle.body.call( _, it );
  return it;
}

_.routineExtend( _queryAct_body, _.selectSingle.body );

var defaults = _queryAct_body.defaults;

defaults.missingAction = 'throw';

let _queryAct = _.routineFromPreAndBody( query_pre, _queryAct_body );

//

function query_body( o )
{
  let it = this._queryAct.body.call( this, o );
  return it.result;
}

_.routineExtend( query_body, _queryAct.body );

let query = _.routineFromPreAndBody( query_pre, query_body );

var defaults = query.defaults;

query.missingAction = 'throw';

//

let queryTry = _.routineFromPreAndBody( query_pre, query_body );

var defaults = queryTry.defaults;

defaults.missingAction = 'undefine';

//

function _queryTracking_pre( routine, args )
{
  let self = this;
  let current = self.stack[ self.stack.length-1 ];

  args = _.longSlice( args );

  let o = args[ 0 ]
  if( _.strIs( o ) )
  o = { query : o }

  o.container = this.tree;
  o.downToken = this.downToken;
  o.upToken = this.upToken;

  if( _.strBegins( o.query, [ '..', '.' ] ) )
  {
    debugger;
    _.sure( !!current, 'Cant resolve', () => _.strQuote( o.query ) + ' no current!' );
    o.it = current.reiteration();
    o.container = null;
  }

  _.assert( arguments.length === 2 );
  _.assert( args.length === 1 );

  return _.selectSingle.pre.call( this, routine, [ o ] );
}

//

function _queryTracking_body( it )
{
  let self = this;
  this._queryAct.body.call( this, it );
  // self.stack.push( it.lastSelect );
  return it;
}

_.routineExtend( _queryTracking_body, _queryAct.body );

let _queryTracking = _.routineFromPreAndBody( _queryTracking_pre, _queryTracking_body );

_.assert( _queryTracking.defaults.missingAction === 'throw' );
_queryTracking.defaults.missingAction = 'error';
_.assert( _queryTracking.defaults.missingAction === 'error' );

//

function _queryBegin( it )
{
  let self = this;

  // debugger;
  let found = _.entityFilter( self.stack, { src : it.src } );

  if( found.length )
  {
    debugger;
    it.iterator.error = _.ErrorLooking
    (
      'Dead lock', _.strQuote( it.context.query ),
      '\nbecause', _.strQuote( it.query ), 'does not exist',
      '\nat', _.strQuote( it.path ),
      '\nin container', _.toStr( it.context.container )
    );
    return it.iterator.error;
  }

  self.stack.push( it );
  return it;
}

//

function _queryEnd( it )
{
  let self = this;
  let pit = self.stack.pop();
  _.assert( pit === it );
  return it;
}

// --
// tracker
// --

// function _entryGet( entry )
// {
//   let self = this;
//   let result = _.entityFilter( self.current, entry );
//   return result;
// }
//
// //
//
// function _enter( o )
// {
//   let self = this;
//   let newPath;
//
//   _.routineOptionsPreservingUndefines( _enter, arguments );
//   _.assert( arguments.length === 1 );
//   _.assert( _.strIs( o.query ) || _.numberIs( o.query ) );
//
//   let upToken = self.upTokenDefault();
//   if( o.path === '' )
//   newPath = upToken;
//   else if( o.path === upToken )
//   newPath = o.path + o.query;
//   else if( o.query )
//   newPath = o.path + upToken + o.query;
//   else
//   newPath = o.path;
//
//   let d = Object.create( null );
//   d.rootContainer = o.rootContainer;
//   d.currentContainer = o.currentContainer;
//   d.subject = o.subject;
//   d.path = o.path;
//   d.newPath = newPath;
//   d.query = o.query;
//
//   _.assert( _.strIs( d.path ) );
//   _.assert( _.strIs( d.newPath ) );
//
//   // if( o.query )
//   // if( self._entryGet({ path : o.path, rootContainer : o.rootContainer }).length )
//   // {
//   //   debugger;
//   //   let err = self._errorQuerying({ reason : 'dead cycle', at : newPath, query : d.query });;
//   //   if( o.throwing )
//   //   throw err;
//   //   else
//   //   return err;
//   // }
//
//   self.current.push( d );
//
//   return d;
// }
//
// _enter.defaults =
// {
//   rootContainer : null,
//   currentContainer : null,
//   subject : null,
//   query : null,
//   path : null,
//   throwing : 0,
// }
//
// //
//
// function _leave( path )
// {
//   let self = this;
//
//   _.assert( arguments.length === 1, 'Expects single argument' );
//
//   let d = self.current.pop();
//
//   _.assert( d.path === path );
//
//   return d;
// }

// --
// etc
// --

// function ErrorLooking( o )
// {
//   _.mapExtend( this, o );
// }
//
// ErrorLooking.prototype = Object.create( Error.prototype );
// ErrorLooking.prototype.constructor = ErrorLooking;
//
// //
//
// function _errorQuerying( o )
// {
//   let err = new ErrorLooking( o );
//   err = _.err( err );
//   _.assert( err instanceof Error );
//   _.assert( err instanceof ErrorLooking );
//   _.assert( !!err.stack );
//   return err;
// }

let ErrorLooking = _.ErrorLooking;
_.assert( _.routineIs( ErrorLooking ) );

//

function shouldInvestigate( src )
{
  let self = this;

  if( _.strIs( src ) )
  return self.investigatingString;

  if( _.mapIs( src ) )
  return self.investigatingMap;

  if( _.regexpIs( src ) )
  return self.investigatingRegexp;

  if( _.longIs( src ) )
  return self.investigatingArrayLike;

  return false;
}

//

function strFrom( src )
{
  let self = this;

  if( _.regexpIs( src ) )
  src = src.source;

  if( !_.strIs( src ) && self.onStrFrom )
  src = self.onStrFrom( src );

  return src;
}

//

function _strJoin()
{
  let result = '';
  for( var i = 0; i < arguments.length; i++ )
  {
    _.assert( _.strIs( arguments[ i ] ), 'Can\'t join elements:', '\n', arguments, '\n', 'Expects String, but got:', arguments[ i ] );
    result += arguments[ i ];
  }
  return result;
}

let strJoin = _.routineVectorize_functor
({
  routine : _strJoin,
  vectorizingArray : 1,
  vectorizingMapVals : 1,
  vectorizingMapKeys : 0,
  select : Infinity
})

//

function upTokenDefault()
{
  let self = this;
  let result = self.onUpTokenDefault();
  _.assert( _.strIs( result ) );
  return result;
}

//

function onUpTokenDefault()
{
  let self = this;
  let result = self.upToken;
  if( _.arrayIs( result ) )
  result = _.strsShortest( result );
  return result;
}

// --
// shortcuts
// --

function resolveAndAssign( src )
{
  let self = this;

  if( src !== undefined )
  self.tree = src;

  self.tree = self.resolve( self.tree );

  return self.tree;
}

//

function EntityResolve( src, tree )
{
  if( tree === undefined )
  tree = src;
  _.assert( arguments.length === 1 || arguments.length === 2 );
  let self = new Self({ tree : tree });
  return self.resolve( src );
}

// --
// relations
// --

let Composes =
{

  investigatingString : true,
  investigatingMap : true,
  investigatingRegexp : true,
  investigatingArrayLike : true,

  // current : _.define.own([]),
  stack : _.define.own([]),

  prefixToken : '{{',
  postfixToken : '}}',
  downToken : '..',
  upToken : _.define.own([ '\\/', '/' ]),

  onStrFrom : null,
  onUpTokenDefault : onUpTokenDefault,

}

let Associates =
{
  tree : null,
}

let Restricts =
{
}

let Statics =
{
  ErrorLooking : ErrorLooking,
  EntityResolve : EntityResolve,
}

let Globals =
{
  entityResolve : EntityResolve,
}

// --
// declare
// --

let Proto =
{

  init : init,

  // resolve

  resolveString : resolveString,
  resolve : resolve,
  resolveTry : resolveTry,
  _resolve : _resolve,
  _resolveEnter : _resolveEnter,
  _resolveEntered : _resolveEntered,

  _resolveString : _resolveString,
  _resolveMap : _resolveMap,
  _resolveArray : _resolveArray,
  _resolveRegexp : _resolveRegexp,

  // query

  _queryAct : _queryAct,
  query : query,
  queryTry : queryTry,

  _queryTracking : _queryTracking,
  _queryBegin : _queryBegin,
  _queryEnd : _queryEnd,

  // tracker

  // _entryGet : _entryGet,
  // _enter : _enter,
  // _leave : _leave,

  // etc

  // _errorQuerying : _errorQuerying,
  shouldInvestigate : shouldInvestigate,
  strFrom : strFrom,
  _strJoin : _strJoin,
  strJoin : strJoin,
  upTokenDefault : upTokenDefault,

  // shortcuts

  resolveAndAssign : resolveAndAssign,
  EntityResolve : EntityResolve,

  // relations

  Composes : Composes,
  Associates : Associates,
  Restricts : Restricts,
  Statics : Statics,
  Globals : Globals,

}

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

_.Copyable.mixin( Self );
_.mapExtend( _global_, Globals );

//

// if( typeof module !== 'undefined' )
// if( _global_.WTOOLS_PRIVATE )
// { /* delete require.cache[ module.id ]; */ }

_[ Self.shortName ] = _global_[ Self.name ] = Self;
if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;

})();
