define([
	"../core",
	"../var/strundefined"
], function( jQuery, strundefined ) {

var
	// Map over jQuery in case of overwrite
	_jQuery = window.jQuery,

	// Map over the $ in case of overwrite
	_$ = window.$;

jQuery.noConflict = function( deep ) {
	if ( window.$ === jQuery ) {
		window.$ = _$;
	}

	if ( deep && window.jQuery === jQuery ) {
		window.jQuery = _jQuery;
	}

	return jQuery;
};

// Expose jQuery and $ identifiers, even in
// AMD (***REMOVED***7102***REMOVED***comment:10, https://github.com/jquery/jquery/pull/557)
// and CommonJS for browser emulators (***REMOVED***13566)
if ( typeof noGlobal === strundefined ) {
	window.jQuery = window.$ = jQuery;
}

});
