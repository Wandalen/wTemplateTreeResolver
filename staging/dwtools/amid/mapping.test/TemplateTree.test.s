( function _TemplateTreeResolver_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  if( typeof _global_ === 'undefined' || !_global_.wBase )
  {
    let toolsPath = '../../../../dwtools/Base.s';
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

  _.include( 'wTesting' );
  require( '../mapping/TemplateTreeAresolver.s' );

}

//

var _ = _global_.wTools;
var Parent = _.Tester;

var tree =
{

  atomic1 : 'a1',
  atomic2 : 2,
  branch1 : { a : 1, b : 'b', c : /xx/, d : '{atomic1}', e : '{atomic2}', f : '{branch2.0}', g :'{branch2.5}' },
  branch2 : [ 11,'bb',/yy/,'{atomic1}','{atomic2}','{branch1.a}','{branch1.f}' ],
  branch3 : [ 'a{atomic1}c','a{branch1.b}c','a{branch3.1}c','x{branch3.0}y{branch3.1}{branch3.2}z','{branch3.0}x{branch3.1}y{branch3.2}' ],

  relative : [ 'a','{^^.0}','0{^^.1}0' ],

  regexp : [ /b/,/a{regexp.0}/,/{regexp.1}c/,/{atomic1}x{regexp.0}y{regexp.2}z/g ],

  error : [ '{error.a}','{error2.0}','{^^.c}','{error.3}' ],

  array : [ 'a','b','c' ],
  map : { a : 'a', b : 'b', c : 'c' },
  arrayFromString : 'prefix {array} postfix',
  mapFromString : 'prefix {map} postfix',

  emptyString : '',
  resolveEmptyString : '{emptyString}',

}

// --
// test
// --

function query( test )
{
  var self = this;
  var template = new wTemplateTreeResolver({ tree : tree, prefixSymbol : '{', postfixSymbol : '}', upSymbol : '.' });

  /* */

  var got = template.query( 'atomic1' );
  var expected = 'a1';
  test.identical( got,expected );

  var got = template.query( 'atomic2' );
  var expected = 2;
  test.identical( got,expected );

  /* */

  var got = template.query( 'branch1.a' );
  var expected = 1;
  test.identical( got,expected );

  var got = template.query( 'branch1.b' );
  var expected = 'b';
  test.identical( got,expected );

  var got = template.query( 'branch1.c' );
  var expected = /xx/;
  test.identical( got,expected );

  var got = template.query( 'branch1.d' );
  var expected = 'a1';
  test.identical( got,expected );

  var got = template.query( 'branch1.e' );
  var expected = 2;
  test.identical( got,expected );

  var got = template.query( 'branch1.f' );
  var expected = 11;
  test.identical( got,expected );

  var got = template.query( 'branch1.g' );
  var expected = 1;
  test.identical( got,expected );

  /* */

  var got = template.query( 'branch2.0' );
  var expected = 11;
  test.identical( got,expected );

  var got = template.query( 'branch2.1' );
  var expected = 'bb';
  test.identical( got,expected );

  var got = template.query( 'branch2.2' );
  var expected = /yy/;
  test.identical( got,expected );

  var got = template.query( 'branch2.3' );
  var expected = 'a1';
  test.identical( got,expected );

  var got = template.query( 'branch2.4' );
  var expected = 2;
  test.identical( got,expected );

  var got = template.query( 'branch2.5' );
  var expected = 1;
  test.identical( got,expected );

  var got = template.query( 'branch2.6' );
  var expected = 11;
  test.identical( got,expected );

  /* */

  test.description = 'error';

  var got = template.queryTry( 'aa' );
  var expected = undefined;
  test.identical( got,expected );

  var got = template.queryTry( 'error.0' );
  var expected = undefined;
  test.identical( got,expected );

  var got = template.queryTry( 'error.1' );
  var expected = undefined;
  test.identical( got,expected );

  var got = template.queryTry( 'error.2' );
  var expected = undefined;
  test.identical( got,expected );

  var got = template.queryTry( 'error.3' );
  var expected = undefined;
  test.identical( got,expected );

}

//

function resolve( test )
{
  var self = this;
  var template = new wTemplateTreeResolver
  ({
    tree : tree,
    prefixSymbol : '{',
    postfixSymbol : '}',
    upSymbol : '.'
  });

  /* */

  test.description = 'trivial cases';

  var got = template.resolve( 'atomic1' );
  var expected = 'atomic1';
  test.identical( got,expected );

  var got = template.resolve( '{atomic1}' );
  var expected = 'a1';
  test.identical( got,expected );

  var got = template.resolve( '{atomic2}' );
  var expected = 2;
  test.identical( got,expected );

  var got = template.resolve( 'a{atomic1}b' );
  var expected = 'aa1b';
  test.identical( got,expected );

  var got = template.resolve( '{atomic2}' );
  var expected = 2;
  test.identical( got,expected );

  /* */

  test.description = 'complex cases';

  var got = template.resolve( '{branch3.0}' );
  var expected = 'aa1c';
  test.identical( got,expected );

  var got = template.resolve( '{branch3.1}' );
  var expected = 'abc';
  test.identical( got,expected );

  var got = template.resolve( '{branch3.2}' );
  var expected = 'aabcc';
  test.identical( got,expected );

  var got = template.resolve( '0{branch3.3}0' );
  var expected = '0xaa1cyabcaabccz0';
  test.identical( got,expected );

  var got = template.resolve( '0{branch3.4}0' );
  var expected = '0aa1cxabcyaabcc0';
  test.identical( got,expected );

  /* */

  test.description = 'regexp cases';

  var got = template.resolve( '{regexp.0}' );
  var expected = /b/;
  test.identical( got,expected );

  var got = template.resolve( '{regexp.1}' );
  var expected = /ab/;
  test.identical( got,expected );

  var got = template.resolve( '{regexp.2}' );
  var expected = /abc/;
  test.identical( got,expected );

  var got = template.resolve( '{regexp.3}' );
  var expected = /a1xbyabcz/g;
  test.identical( got,expected );

  var got = template.resolve( /0{regexp.3}0/ );
  var expected = /0a1xbyabcz0/;
  test.identical( got,expected );

  /* */

  test.description = 'non-string';

  var got = template.resolve( [ '{atomic1}','{atomic2}' ] );
  var expected = [ 'a1',2 ];
  test.identical( got,expected );

  var got = template.resolve( { atomic1 : '{atomic1}', atomic2 : '{atomic2}' } );
  var expected = { atomic1 : 'a1', atomic2 : 2 };
  test.identical( got,expected );

  var got = template.resolve( '{branch2}' );
  var expected = [ 11,'bb',/yy/,'a1',2,1,11 ];
  test.identical( got,expected );

  /* */

  test.description = 'relative';

  var got = template.query( 'relative.1' );
  var got = template.resolve( '{relative.1}' );
  var expected = 'a';
  test.identical( got,expected );

  var got = template.resolve( '{relative.2}' );
  var expected = '0a0';
  test.identical( got,expected );

  /* */

  test.description = 'not throwing error';

  var got = template.resolveTry( '{aa}' );
  var expected = undefined;
  test.identical( got,expected );

  var got = template.resolveTry( 'aa{aa}aa' );
  var expected = undefined;
  test.identical( got,expected );

  var got = template.resolveTry( '{error.0}' );
  var expected = undefined;
  test.identical( got,expected );

  var got = template.resolveTry( '{error.1}' );
  var expected = undefined;
  test.identical( got,expected );

  var got = template.resolveTry( '{error.2}' );
  var expected = undefined;
  test.identical( got,expected );

  var got = template.resolveTry( '{error.3}' );
  var expected = undefined;
  test.identical( got,expected );

  var got = template.resolveTry( [ '{error.3}' ] );
  var expected = undefined;
  test.identical( got,expected );

  var got = template.resolveTry( { a : '{error.3}' } );
  var expected = undefined;
  test.identical( got,expected );

  var got = template.resolveTry( /{error.3}/ );
  var expected = undefined;
  test.identical( got,expected );

  /**/

  test.description = 'resolving empty string';

  var got = template.resolve( '{resolveEmptyString}' );
  var expected = '';
  test.identical( got,expected );

  /* */

  test.description = 'throwing error';
  if( !Config.debug )
  return;

  test.shouldThrowErrorSync( function()
  {
    template.resolve( '{aa}' );
  });

  test.shouldThrowErrorSync( function()
  {
    template.resolve( 'aa{aa}aa' );
  });

  test.shouldThrowErrorSync( function()
  {
    template.resolve( '{error.0}' );
  });

  test.shouldThrowErrorSync( function()
  {
    template.resolve( '{error.1}' );
  });

  test.shouldThrowErrorSync( function()
  {
    template.resolve( '{error.2}' );
  });

  test.shouldThrowErrorSync( function()
  {
    template.resolve( '{error.3}' );
  });

  test.shouldThrowErrorSync( function()
  {
    template.resolve( [ '{error.3}' ] );
  });

  test.shouldThrowErrorSync( function()
  {
    template.resolve( { a : '{error.3}' } );
  });

  test.shouldThrowErrorSync( function()
  {
    template.resolve( /{error.3}/ );
  });

  debugger;
}

//

function resolveStringToArray( test )
{

  var template = new wTemplateTreeResolver
  ({
    tree : tree,
    prefixSymbol : '{',
    postfixSymbol : '}',
    upSymbol : '.'
  });

  /* */

  test.description = 'trivial cases';

  var expected = [ 'prefix a postfix','prefix b postfix','prefix c postfix' ];
  var got = template.resolve( '{arrayFromString}' );
  test.identical( got, expected );

  /* */

  test.description = 'trivial cases';

  var expected = { a : 'prefix a postfix', b : 'prefix b postfix', c : 'prefix c postfix' };
  var got = template.resolve( '{mapFromString}' );
  test.identical( got, expected );

}

// --
// proto
// --

var Self =
{

  name : 'TemplateTreeResolver',
  verbosity : 1,

  tests :
  {

    query : query,
    resolve : resolve,
    resolveStringToArray : resolveStringToArray,

  },

};

//

Self = wTestSuit( Self );
if( typeof module !== 'undefined' && !module.parent )
_.Tester.test( Self.name );

} )( );
