# jquery-scrollspy

A jQuery plugin for detecting enter/exit of elements in the viewport when the user scrolls

## New Features

Added a couple new features:

 * now supports window resize
 * now throttles scrollspy events so that event handles only fire every 100 milliseconds

## Usage

```js
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
