# Approximating Pi with inscribed polygons

## What is it?

This PureScript application demonstrates how the number Pi can be
approximated by inscribing a polygon in a circle. The more vertices
the polygon got, the more exact the approximation!
A running version is available on [http://sleepomeno.github.io/pi/html/index.html](http://sleepomeno.github.io/pi/html/index.html).

## How do I build it?

First of all, you need to have PureScript installed (see the
[PureScript wiki](https://github.com/purescript/purescript/wiki/Language-Guide:-Getting-Started))

### Install grunt, bower, grunt-purescript
In addition, you need *grunt*, *bower* and *grunt-purescript*. Execute
in your repo:

```
npm install -g grunt-cli bower
npm install grunt grunt-purescript@0.6.0
```

### Fetch the dependencies

```
bower update
```

### Run the build

Then you can build the application by:

```
grunt
```

This compiles the PureScript to the *dist/Main.js* JavaScript file.
Open *dist/index.html* in a browser.
