// last-child pseudo selector
// https://github.com/Modernizr/Modernizr/pull/304


Modernizr.addTest('lastchild', function(){

  return Modernizr.testStyles("***REMOVED***modernizr div {width:100px} ***REMOVED***modernizr :last-child{width:200px;display:block}", function (elem) {
    return elem.lastChild.offsetWidth > elem.firstChild.offsetWidth;
  }, 2);

});
