# ScrollSpy

A ScrollSpy library for jQuery that detects the enter and exit of elements in a viewport or scrollable div.

### New Version 0.2.0!

This documentation covers the latest version of ScrollSpy. The 0.2.x version tree has some minor breaking changes from the 0.1.x version tree.  For stability, consider [scrollspy.jquery-0.1.3](https://github.com/thesmart/jquery-scrollspy/tree/0.1.3).

## Getting started:

```
$ git clone git@github.com:thesmart/jquery-scrollspy.git
$ cp ./jquery-scrollspy/scrollSpy.jquery.min.js ~/your-project-folder
```

## Usage

To track elements that enter and exit the viewport:

```js
$(window).ready(->
   $('.box').on('scrollSpy:enter', ->
     $(this).addClass('entered')
     $(this).removeClass('exited')
   ).on('scrollSpy:exit', ->
     $(this).removeClass('entered')
     $(this).addClass('exited')
   )
   $.scrollSpy('.box')
)
```

To track elements that enter and exit the viewable region of a div with ```overflow:scroll```:

```.js
$(window).ready(->
  $('#overflow-div .box').on('scrollSpy:enter', ->
     $(this).addClass('entered')
     $(this).removeClass('exited')
   ).on('scrollSpy:exit', ->
     $(this).removeClass('entered')
     $(this).addClass('exited')
   )
  $('#overflow-div').scrollSpy('.box')
)
```

## Contributions

Please [file bugs here](https://github.com/thesmart/jquery-scrollspy/issues).

Feature requests are much less helpful than pull requests.  

Test cases would be most welcome!

To develop on jquery-scrollspy locally:

```
$ git clone git@github.com:thesmart/jquery-scrollspy.git
$ cd jquery-scrollspy
$ sudo npm install -g harp
$ harp server .
# open a new console tab or console window
$ open 127.0.0.1:9000/demo/
```

Thank you, contributors!

 * [@Mithgol](https://github.com/Mithgol)
 * [@eithanshavit](https://github.com/eithanshavit)

