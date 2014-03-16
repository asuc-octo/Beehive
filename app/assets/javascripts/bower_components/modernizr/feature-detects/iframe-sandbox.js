// Test for `sandbox` attribute in iframes.
//
// Spec: http://www.whatwg.org/specs/web-apps/current-work/multipage/the-iframe-element.html***REMOVED***attr-iframe-sandbox

Modernizr.addTest('sandbox', 'sandbox' in document.createElement('iframe'));
