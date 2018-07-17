You can open the [test here](https://rawgit.com/webbhuset/test-elm-performance/master/index.html).

This is a simple, non-scientific test of the render performance of the Elm Virtual DOM.

Three common implementations of style can be tested and compared:

* HTML with CSS (only CSS classes are handled by Elm)
* HTML with Inline Style (all style is handled by Elm)
* [Stylish Elephants](http://package.elm-lang.org/packages/mdgriffith/stylish-elephants/6.0.2) 6.0.2

One UI component (an accordion) is implemented with each of the above technique and can be compared.
The rendering times are printed to the console using `console.time` and `console.timeEnd`. Three metrics are logged:

1. The Virtual DOM Generation: This is the time of the view function in the Elm program.
2. Diff: The time it takes to compare the generated tree with previous VDOM tree and generating a patch (the Reconciliation algorithm)
3. Apply: This is the time it takes to apply the changes to the "real" DOM.

Two scenarios can easly be compared:

1. A small portion of the DOM is changed. (Open / Close the accordion)
2. The whole page is re-rendered. (Change the Implementation)


