
// developer.mozilla.org/en/CSS/background-size

Modernizr.testStyles( '***REMOVED***modernizr{background-size:cover}', function( elem ) {
	var style = window.getComputedStyle ?
		window.getComputedStyle( elem, null )
		: elem.currentStyle;
		
	Modernizr.addTest( 'bgsizecover', style.backgroundSize == 'cover' );
});