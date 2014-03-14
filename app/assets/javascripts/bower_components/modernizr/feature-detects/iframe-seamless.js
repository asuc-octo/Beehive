// Test for `seamless` attribute in iframes.
//
// Spec: http://www.whatwg.org/specs/web-apps/current-work/multipage/the-iframe-element.html***REMOVED***attr-iframe-seamless

Modernizr.addTest('seamless', 'seamless' in document.createElement('iframe'));
