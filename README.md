# jquery-scrollspy

A jQuery plugin for detecting enter/exit of elements in the viewport when the user scrolls

## Usage

```
$('.tile').on('scrollSpy:enter', function() {
	console.log('enter:', $(this).attr('id'));
});

$('.tile').on('scrollSpy:exit', function() {
	console.log('exit:', $(this).attr('id'));
});

$('.tile').scrollSpy();

// or you could do this:
// $.scrollSpy($('.tile'));
// or this
// $('.tile').each(function(i, element) {
// 		$.scrollSpy(element);
// });

```
## TODO

1. *Testing in Internet Explorer.  Please let me know if it works!*
1. This plugin has BigO(n) performance, and is "ok" for a few hundred elements.  If you need to track more elements, you may want to contribute a smarter geospacial index for considering intersection.
1. A feature for considering only elements that stay within the viewport for longer than n-milliseconds.