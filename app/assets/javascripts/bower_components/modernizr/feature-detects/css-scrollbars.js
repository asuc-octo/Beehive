// Stylable scrollbars detection
Modernizr.addTest('cssscrollbar', function() {

	var bool,

		styles = "***REMOVED***modernizr{overflow: scroll; width: 40px }***REMOVED***" +
			Modernizr._prefixes
				.join("scrollbar{width:0px}"+' ***REMOVED***modernizr::')
				.split('***REMOVED***')
				.slice(1)
				.join('***REMOVED***') + "scrollbar{width:0px}";

	Modernizr.testStyles(styles, function(node) {
		bool = 'scrollWidth' in node && node.scrollWidth == 40;
	});

	return bool;

});
