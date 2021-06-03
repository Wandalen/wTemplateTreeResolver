
# module::TemplateTreeResolver [![status](https://github.com/Wandalen/wTemplateTreeResolver/actions/workflows/StandardPublish.yml/badge.svg)](https://github.com/Wandalen/wTemplateTreeResolver/actions/workflows/StandardPublish.yml) [![experimental](https://img.shields.io/badge/stability-experimental-orange.svg)](https://github.com/emersion/stability-badges#experimental)

Class to resolve tree-like data structures with links  or paths in the structure. Use the module to resolve template or path to value.

### Sample

```js
var tree =
{
  b : [ 1, 2, 3 ],
};

var templateTree = new _.TemplateTreeResolver();
templateTree.tree = tree;
var b1 = templateTree.select( 'b/#1' );
console.log( 'b/#1 :', b1 );
```
[Source code](sample/trivial/Sample.s)

### Try out from the repository

```
git clone https://github.com/Wandalen/wTemplateTreeResolver
cd wTemplateTreeResolver
will .npm.install
node sample/trivial/Sample.s
```

Make sure you have utility `willbe` installed. To install willbe: `npm i -g willbe@stable`. Willbe is required to build of the module.

### To add to your project

```
npm add 'wtemplatetreeresolver@stable'
```

`Willbe` is not required to use the module in your project as submodule.

