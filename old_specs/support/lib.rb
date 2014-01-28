***REMOVED******REMOVED***
***REMOVED*** Takes a range and yields pairs of [value, valid?]
***REMOVED***
***REMOVED*** @param r [Range] range to test
***REMOVED***
***REMOVED*** @example
***REMOVED***   test_range(10..20) do |value, valid|
***REMOVED***     MyModel.new(:value => value).valid?.should == valid
***REMOVED***   end
***REMOVED***
***REMOVED*** Yields:
***REMOVED***   [9, false]
***REMOVED***   [10, true]
***REMOVED***   [19, true]
***REMOVED***   [20, false]
***REMOVED***
***REMOVED***
def test_range(r)
  yield [r.min-1, false]
  yield [r.min,   true]
  yield [r.max,   true]
  yield [r.max+1, false]
end
