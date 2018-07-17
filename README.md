You can open the [test here](https://rawgit.com/webbhuset/test-elm-performance/master/index.html).

This is a simple, non-scientific test of the render performance in the Elm Virtual DOM.

Three common implementations of style can be tested and compared:

* HTML with CSS (only CSS classes are handled by Elm)
* HTML with Inline Style (all style is handled by Elm)
* [Stylish Elephants](http://package.elm-lang.org/packages/mdgriffith/stylish-elephants/6.0.2) 6.0.2

Two scenarios can easly be compared:

1. A small portion of the DOM is changed. (Open / Close the accordion)
2. The whole page is re-rendered. (Change implementation)
