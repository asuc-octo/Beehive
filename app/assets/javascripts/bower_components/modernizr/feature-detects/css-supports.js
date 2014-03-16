// http://dev.w3.org/csswg/css3-conditional/***REMOVED***at-supports
// github.com/Modernizr/Modernizr/issues/648
// Relies on the fact that a browser vendor should expose the CSSSupportsRule interface
// http://dev.w3.org/csswg/css3-conditional/***REMOVED***the-csssupportsrule-interface

Modernizr.addTest("supports","CSSSupportsRule" in window);