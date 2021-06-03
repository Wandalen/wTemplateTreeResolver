
if( typeof module !== 'undefined' )
require( 'wtemplatetreeresolver' );
const _ = wTools;

var tree =
{
  b : [ 1, 2, 3 ],
};

var templateTree = new _.TemplateTreeResolver();
templateTree.tree = tree;
var b1 = templateTree.select( 'b/#1' );
console.log( 'b/#1 :', b1 );
