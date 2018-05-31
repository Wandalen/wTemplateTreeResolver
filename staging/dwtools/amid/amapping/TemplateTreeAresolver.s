( function _TemplateTreeAresolver_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  if( typeof _global_ === 'undefined' || !_global_.wBase )
  {
    let toolsPath = '../../../dwtools/Base.s';
    let toolsExternal = 0;
    try
    {
      require.resolve( toolsPath );
    }
    catch( err )
    {
      toolsExternal = 1;
      require( 'wTools' );
    }
    if( !toolsExternal )
    require( toolsPath );
  }

  var _ = _global_.wTools;

  _.include( 'wCopyable' );

}

var _ = _global_.wTools;
var Parent = null;
var Self = function wTemplateTreeResolver( o )
{
  if( !( this instanceof Self ) )
  if( o instanceof Self )
  return o;
  else
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

Self.nameShort = 'TemplateTreeResolver';

// --
// inter
// --

function init( o )
{
  var self = this;

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

function resolve( src )
{
  var self = this;

  _.assert( arguments.length === 1 );

  var result = self._resolveEnter( src,'' );

  if( result instanceof self.ErrorQuerying )
  {
    debugger;
    var result = self._resolveEnter( src,'' );
    throw _.err( result );
  }

  return result;
}

//

function resolveTry( src )
{
  var self = this;

  _.assert( arguments.length === 1 );

  var result = self._resolveEnter( src,'' );

  if( result instanceof self.ErrorQuerying )
  return;

  return result;
}

//

function _resolveEnter( src,query )
{
  var self = this;
  var l = self.current.length;
  var node,path;

  _.assert( arguments.length === 2 );

  if( query === '' )
  {
    _.assert( l === 0 );
    node = self.tree;
    path = self.upSymbol;
  }
  else
  {
    node = src;
    path = self.current[ self.current.length-1 ].path;
  }

  var entered = self._enter( node,[ query ],path,0 );
  if( entered instanceof self.ErrorQuerying )
  {
    debugger;
    return entered;
  }

  var result = self._resolveEntered( src );

  self._leave( node );
  _.assert( self.current.length === l );

  return result;
}

//

function _resolveEntered( src )
{
  var self = this;

  _.assert( arguments.length === 1 );

  if( !self.shouldInvestigate( src ) )
  return src;

  if( _.strIs( src ) )
  return self._resolveString( src );

  if( _.regexpIs( src ) )
  return self._resolveRegexp( src );

  if( _.mapIs( src ) )
  return self._resolveMap( src );

  if( _.arrayLike( src ) )
  return self._resolveArray( src );

  throw _.err( 'repalce : unexpected type of src',_.strTypeOf( src ) );
}

//

function _resolveString( src )
{
  var self = this;
  var r;
  var rarray = [];

  if( src === '' )
  return src;

  var optionsForExtract =
  {
    prefix : self.prefixSymbol,
    postfix : self.postfixSymbol,
    onStrip : function( src ){ return [ src ]; },
  }

  var strips = _.strExtractStereoStrips.call( optionsForExtract,src );

  /* */

  for( var s = 0 ; s < strips.length ; s++ )
  {

    var strip = strips[ s ];

    // if( strip[ 0 ] === 'opt/helperHpp' )
    // debugger;

    if( _.strIs( strip ) )
    {
      element = strip;
    }
    else
    {
      element = self._queryEntered( strip[ 0 ] );
    }

    if( element instanceof self.ErrorQuerying )
    {
      element = _.err( element,'\nCant resolve :',src.substring( 0,80 ) );
      return element;
    }

    rarray.push( element );

  }

  /* */

  if( rarray.length < 2 )
  return rarray[ 0 ];

  /* */

  var result = '';
  for( var r = 0 ; r < rarray.length ; r++ )
  {
    var element = rarray[ r ];
    if( _.arrayIs( element ) )
    {
      _.assert( _.strIs( result ),'cant mix',_.strTypeOf( [] ),'with',_.strTypeOf( result ) );
      result = _.dup( '',element.length );
      _.assert( result.length === element.length );
    }
    else if( _.mapIs( element ) )
    {
      _.assert( _.strIs( result ),'cant mix',_.strTypeOf( Object.create( null ) ),'with',_.strTypeOf( result ) );
      result = _.mapExtend( null,element );
      for( var i in result )
      result[ i ] = '';
    }
  }

  /* */

  function join( result,element )
  {
    result += element;
    _.assert( _.strIs( result ) );
    _.assert( _.strIs( element ) );
    return result;
  }

  for( var r = 0 ; r < rarray.length ; r++ )
  {
    var element = rarray[ r ];

    element = self.strFrom( element );

    if( _.arrayIs( result ) )
    {
      for( var i = 0 ; i < result.length ; i++ )
      if( _.arrayIs( element ) )
      result[ i ] = join( result[ i ] , element[ i ] );
      else
      result[ i ] = join( result[ i ] , element );
    }
    else if( _.mapIs( result ) )
    {
      debugger;
      for( var i in result )
      if( _.mapIs( element ) )
      result[ i ] = join( result[ i ] , element[ i ] );
      else
      result[ i ] = join( result[ i ] , element );
    }
    else
    {
      result = join( result , element );
    }

  }

  return result;
}

//

function _resolveRegexp( src )
{
  var self = this;

  _.assert( _.regexpIs( src ) );

  var source = src.source;
  source = self._resolveString( source );

  if( source instanceof self.ErrorQuerying )
  return source;

  if( source === src.source )
  return src;

  src = new RegExp( source,src.flags );

  return src;
}

//

function _resolveMap( src )
{
  var self = this;
  var result = Object.create( null );

  for( var s in src )
  {
    result[ s ] = self._resolveEnter( src[ s ],s );
    if( result[ s ] instanceof self.ErrorQuerying )
    {
      return result[ s ];
    }
  }

  return result;
}

//

function _resolveArray( src )
{
  var self = this;
  var result = new src.constructor( src.length );

  for( var s = 0 ; s < src.length ; s++ )
  {
    result[ s ] = self._resolveEnter( src[ s ],s );
    if( result[ s ] instanceof self.ErrorQuerying )
    {
      return result[ s ];
    }
  }

  return result;
}

// --
// query
// --

function query( query )
{
  var self = this;

  _.assert( arguments.length === 1 );

  var result = self._queryEntering( query );
  if( result instanceof self.ErrorQuerying )
  {
    debugger;
    throw _.err( result,'\nquery :',query );
  }

  return result;
}

//

function queryTry( query )
{
  var self = this;

  _.assert( arguments.length === 1 );

  var result = self._queryEntering( query );
  if( result instanceof self.ErrorQuerying )
  return;

  return result;
}

//

function _querySplit( query )
{
  var self = this;

  _.assert( _.strIs( query ) || _.arrayIs( query ) );
  _.assert( arguments.length === 1 );

  if( _.strIs( query ) )
  {

    /* query = query.split( self.upSymbol ); */

    query = _.strSplit
    ({
      src : query,
      delimeter : [ self.upSymbol,self.downSymbol ],
      preservingDelimeters : 1,
    });

    if( query[ 0 ] !== self.downSymbol && query[ 0 ] !== self.upSymbol )
    query.unshift( self.upSymbol );

  }

  return query;
}

//

function _queryEntering( query )
{
  var self = this;

  _.assert( arguments.length === 1 );
  _.assert( !self.current.length );

  query = self._querySplit( query );

  //self._enter( self.tree,query,self.upSymbol,1 );
  self._enter( self.tree,query,'',1 );

  var result = self._queryEntered( query );

  self._leave( self.tree );
  _.assert( self.current.length === 0 );

  return result;
}

//

function _queryEntered( query )
{
  var self = this;

  _.assert( _.strIs( query ) || _.arrayIs( query ) );
  _.assert( arguments.length === 1 );

  if( _.strIs( query ) )
  {
    query = self._querySplit( query );
  }

  var result = self._queryAct( self.tree,query );

  return result;
}

//

function _queryAct( here,query )
{

  _.assert( arguments.length === 2 );
  _.assert( query.length > 0 );
  // _.assert( query[ 0 ] === self.upSymbol || query[ 0 ] === self.downSymbol );

  var result;
  var self = this;
  var path = self.current[ self.current.length-1 ].path;
  var queryOriginal = query;
  var newQuery;

  /* clear from up symbol */

  if( query[ 0 ] === self.upSymbol )
  query.splice( 0,1 );

  /* clear from down symbol or select */

  if( query[ 0 ] === self.downSymbol )
  {
    for( var q = 0 ; q < query.length ; q++ )
    if( query[ q ] !== self.downSymbol )
    break;
    query.splice( 0,q );
    if( self.current.length >= q )
    result = self.current[ self.current.length-q ].node;
    newQuery = query.slice();
  }
  else
  {
    if( !here )
    {
      // debugger;
      return self._errorQuerying({ at : path, query : queryOriginal.join( self.upSymbol ) });
    }
    result = here[ query[ 0 ] ];
    newQuery = query.slice( 1 );
  }

  /* */

  if( result === undefined )
  {
    // debugger;
    return self._errorQuerying({ at : path, query : queryOriginal.join( self.upSymbol ) });
  }

  /* */

  var current = result;
  var entered = self._enter( current,query,path,0 );
  if( entered instanceof self.ErrorQuerying )
  {
    debugger;
    return self._errorQuerying({ reason : 'dead cycle', at : path, query : queryOriginal.join( self.upSymbol ) });
  }

  /* */

  if( newQuery.length )
  {
    if( _.strIs( result ) )
    result = self._resolveEntered( result );
    if( result !== undefined )
    result = self._queryAct( result,newQuery );
  }
  else
  {
    result = self._resolveEntered( result );
  }

  /* */

  self._leave( current );

  if( result === undefined )
  {
    debugger;
    return self._errorQuerying({ at : path, query : query.join( self.upSymbol ) });
  }

  return result;
}

// --
// tracker
// --

function _entryGet( entry )
{
  var self = this;

  var result = _.entityFilter( self.current,entry );

  return result;
}

//

function _enter( node,query,path,throwing )
{
  var self = this;

  _.assert( arguments.length === 4 );
  _.assert( _.arrayIs( query ) );

  var newPath;

  if( path === '' )
  newPath = '/'
  else if( path === '/' )
  newPath = path + query[ 0 ];
  else
  newPath = path + query[ 0 ] + query[ 1 ];

  // var newPath = path !== self.upSymbol ? path + query[ 0 ] + query[ 1 ] : path + query[ 0 ]; debugger;
  // var newPath = path + query[ 0 ] + query[ 1 ]; debugger;

  var d = {};
  d.node = node;
  d.path = newPath;
  d.query = query.join( '' );
  //d.query = query.join( self.upSymbol );

  if( query )
  if( self._entryGet({ query : d.query, node : node }).length )
  {
    var err = self._errorQuerying({ reason : 'dead cycle', at : newPath, query : d.query });;
    if( throwing )
    throw err;
    else
    return err;
  }

  self.current.push( d );

  return d;
}

//

function _leave( node )
{
  var self = this;

  _.assert( arguments.length === 1 );

  var d = self.current.pop();

  _.assert( d.node === node );

  return d;
}

// --
// etc
// --

function ErrorQuerying( o )
{
  _.mapExtend( this,o );
  //self.stack = _.diagnosticStack();
}

ErrorQuerying.prototype = Object.create( Error.prototype );
ErrorQuerying.prototype.constructor = ErrorQuerying;
ErrorQuerying.prototype.name = 'x';

//

function _errorQuerying( o )
{
  // debugger;
  var err = new ErrorQuerying( o );
  err = _.err( err );
  _.assert( err instanceof Error );
  _.assert( err instanceof ErrorQuerying );
  _.assert( err.stack );
  return err;
}

//

function shouldInvestigate( src )
{
  var self = this;

  if( _.strIs( src ) )
  return self.investigatingString;

  if( _.mapIs( src ) )
  return self.investigatingMap;

  if( _.regexpIs( src ) )
  return self.investigatingRegexp;

  if( _.arrayLike( src ) )
  return self.investigatingArrayLike;

  return false;
}

//

function strFrom( src )
{
  var self = this;

  if( _.regexpIs( src ) )
  src = src.source;

  if( !_.strIs( src ) && self.onStrFrom )
  src = self.onStrFrom( src );

  return src;
}

//

function entityResolve( src,tree )
{
  _.assert( arguments.length === 2 );
  var self = new Self({ tree : tree });
  return self.resolve( src );
}

// --
// shortcuts
// --

function resolveAndAssign( src )
{
  var self = this;

  if( src !== undefined )
  self.tree = src;

  self.tree = self.resolve( self.tree );

  return self.tree;
}

// --
// relationships
// --

var Composes =
{

  investigatingString : true,
  investigatingMap : true,
  investigatingRegexp : true,
  investigatingArrayLike : true,

  current : [],

  prefixSymbol : '{{',
  postfixSymbol : '}}',
  downSymbol : '^',
  upSymbol : '/',

  onStrFrom : null,

}

var Associates =
{
  tree : null,
}

var Restricts =
{
}

var Statics =
{
  ErrorQuerying : ErrorQuerying,
  entityResolve : entityResolve,
}

var Globals =
{
  entityResolve : entityResolve,
}

// --
// proto
// --

var Proto =
{

  init : init,


  // resolve

  resolve : resolve,
  resolveTry : resolveTry,
  _resolveEnter : _resolveEnter,
  _resolveEntered : _resolveEntered,
  _resolveString : _resolveString,
  _resolveMap : _resolveMap,
  _resolveArray : _resolveArray,
  _resolveRegexp : _resolveRegexp,


  // query

  query : query,
  queryTry : queryTry,
  _querySplit : _querySplit,
  _queryEntering : _queryEntering,
  _queryEntered : _queryEntered,
  _queryAct : _queryAct,


  // tracker

  _entryGet : _entryGet,
  _enter : _enter,
  _leave : _leave,


  // etc

  _errorQuerying : _errorQuerying,
  shouldInvestigate : shouldInvestigate,
  strFrom : strFrom,
  entityResolve : entityResolve,


  // shortcuts

  resolveAndAssign : resolveAndAssign,


  // relationships

  constructor : Self,
  Composes : Composes,
  Associates : Associates,
  Restricts : Restricts,
  Statics : Statics,
  Globals : Globals,

}

// define

_.classMake
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

_.Copyable.mixin( Self );
_.mapExtend( _global_,Globals );

//

_[ Self.nameShort ] = _global_[ Self.name ] = Self;
if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;

})();
