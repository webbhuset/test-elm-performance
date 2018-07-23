
You can open the [test here](https://rawgit.com/webbhuset/test-elm-performance/master/index.html) and try it on your device.

## What is this?

This is a simple, non-scientific test of the render performance of the Elm Virtual DOM. I
created this to get a better understanding on how the Virtual DOM works and what affects
the rendering performance.

Three common approaches of working with style / layout are implemented and can be compared:

* HTML with CSS (only CSS classes are handled by Elm)
* HTML with Inline Style (all style is handled by Elm)
* [Stylish Elephants](http://package.elm-lang.org/packages/mdgriffith/stylish-elephants/6.0.2) 6.0.2

One UI component (an accordion) is implemented with each of the above techniques and can be compared.
The rendering times are printed to the console using [console.time](https://developer.mozilla.org/en-US/docs/Web/API/Console/time) and [console.timeEnd](https://developer.mozilla.org/en-US/docs/Web/API/Console/timeEnd). This is achieved by patching the virtual-dom package. Three metrics are logged:

1. **view**: The time of the view function in the Elm program.
2. **diff**: The time it takes to compare the generated tree with previous VDOM tree and generating a patch (the Reconciliation algorithm).
3. **apply**: This is the time it takes to apply the changes to the "real" DOM.

Two scenarios can be compared in this app:

1. A small portion of the DOM is changed. (Open / Close the accordion)
2. The whole page is re-rendered. (Change the Implementation)

## Some Test Results

### Small changes to the DOM

For example when you toggle someting on the page. In this case opening an accordion.

* 1000 Accordions on an slow desktop computer.
* Average values from opening and closing the first accordion 10 times.

|             | HTML-CSS | HTML Inline |  SE   |
| ----------- | -------- | ----------- | ----- |
| View        |      7.2 |        18.1 |   400 |
| Diff        |      4.3 |        10.8 |    27 |
| Apply       |    < 1.0 |       < 1.0 | < 1.0 |
| Node Count* |     3040 |        3040 |  6043 |

 * DOM Node Count using `document.querySelectorAll('*').length`

Here you can se that the view function of the program is the largest part of rendering.

Even though the html-inline approach has the same html elements as html-css, it takes more time on both *view* and *diff* since it also has to handle all the style attributes.

Stylish Elephants does a lot more work for you than just generating a Virtual Dom tree, so this comparisation is quite unfair. But on the other hand, this is a performance test.

Using [Html.Lazy](http://package.elm-lang.org/packages/elm-lang/html/2.0.0/Html-Lazy) (or Element.Lazy) will reduce the *view* and *diff* step.

Since just one element has to be changed, the apply step is below 1ms and does not have any practical impact on the performance.

### Replacing a lot

This could be when switching page in your application.

* 1000 Accordions on an slow desktop computer.
* Switching between the three implementations.

|             | HTML-CSS | HTML Inline |  SE   |
| ----------- | -------- | ----------- | ----- |
| View        |      6.5 |        22.7 |   400 |
| Diff        |      1.2 |         0.8 |   0.5 |
| Apply       |      130 |         270 |   170 |
| Node Count* |     3040 |        3040 |  6043 |

The same amount of Virtual DOM is generated in this test so the time on the view function is more or less the same.

Since `Html.Keyed` is used around the accordion wrapper the diffing will bail out early and just replace the whole thing.
This is why you see much lower times on the diffing step compared to the previous example.

Applying the patch to the "real" DOM takes more time here since many nodes has to be deleted and created.
You can see that the html-inline implementation takes more time to apply since it also has to handle a lot of attributes on each node.

### Layout and Paint

When a browser renders the page there is a lot more happening than just diffing and applying virtual DOM.
A fair amount of time is also spent on calculating layout and painting. Garbage Collection cycles can also affect the rendering performance.

In this test, I start with the first accordion open and measure the time it takes to finnish the complete rendering process.

With 1000 Accordions

|             | HTML-CSS | HTML Inline |  SE   |
| ----------- | -------- | ----------- | ----- |
| View        |       27 |          33 |   670 |
| Diff        |        7 |          10 |    31 |
| Apply       |    < 1.0 |       < 1.0 | < 1.0 |
| Layout      |       45 |          45 |   150 |
| Paint       |      3.5 |         3.5 |    25 |
| Node Count* |       3k |          3k |    6k |

With 5000 Accordions

|             | HTML-CSS | HTML Inline |  SE   |
| ----------- | -------- | ----------- | ----- |
| View        |       61 |         138 |  2590 |
| Diff        |       25 |          38 |   148 |
| Apply       |    < 1.0 |         1.9 |   1.5 |
| Layout      |      230 |         235 |   720 |
| Paint       |      7.5 |         7.5 |    98 |
| Node Count* |      15k |         15k |   30k |



### Animation Frame FPS vs Size

If you hit the "Run Test" button the app will call `requestAnimationFrame` 30 times and open an accordion on each frame.
This way the whole rendering cycle is taken into account.

Here are some results from different devices.

#### Desktop i7 4.5Ghz

|      | HTML CSS | HTML Inline | S Elephants |
| ---- | -------- | ----------- | ----------- |
| 64   |       60 |          60 |          60 |
| 128  |       60 |          60 |          59 |
| 256  |       60 |          60 |          41 |
| 512  |       60 |          60 |          20 |
| 1024 |       59 |          58 |          10 |
| 2048 |       57 |          55 |           5 |
| 4096 |       43 |          29 |           2 |
| 8192 |       25 |          16 |           1 |


#### Macbook Pro 13" (2015)

|      | HTML CSS | HTML Inline | S Elephants |
| ---- | -------- | ----------- | ----------- |
| 64   |       60 |          60 |          60 |
| 128  |       60 |          60 |          57 |
| 256  |       60 |          60 |          37 |
| 512  |       60 |          60 |          17 |
| 1024 |       59 |          57 |           9 |
| 2048 |       56 |          45 |           4 |
| 4096 |       31 |          23 |           2 |
| 8192 |       14 |          11 |           1 |


#### Samsung Galaxy S7

|      | HTML CSS | HTML Inline | S Elephants |
| ---- | -------- | ----------- | ----------- |
| 64   |       59 |          59 |          37 |
| 128  |       58 |          58 |          21 |
| 256  |       57 |          52 |          12 |
| 512  |       50 |          40 |           6 |
| 1024 |       40 |          28 |           3 |
| 2048 |       24 |          15 |           1 |
| 4096 |        9 |           7 |           0 |
| 8192 |        4 |           4 |           0 |


## Conclusion

In reality the numbers would probably look different. The html-css implementation is very naive and I think the test it is somewhat unfair to stylish elephants. Maybe I will try to make a more realistic example some day.

You'd probably want to use [Element.Lazy](http://package.elm-lang.org/packages/mdgriffith/stylish-elephants/6.0.2/Element-Lazy) if you are building a larger project using stylish elephants. Especially if you are targeting low end devices.

 
