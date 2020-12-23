
if( typeof module !== 'undefined' )
require( 'wtemplatetreeresolver' );

var tree =
{
  a : 'a',
  b : [ 1, 2, 3 ],
  c : { c1 : [ 1, 2, 3 ], c2 : [ 11, 22, 33 ] },
  d : '{{^^a}}'
};

var templateTree = new wTemplateTreeResolver();
templateTree.tree = tree;

var b1 = templateTree.select( 'b/1' );
var d = templateTree.select( 'd' );

console.log( 'b/1 :', b1 );
/* log : b/1 : 2 */
console.log( 'd :', d );
/* log : d : {{^^a}} */
