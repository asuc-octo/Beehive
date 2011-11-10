class String

  ***REMOVED*** @param n [Integer] number to pluralize for
  ***REMOVED*** @return [String] +self+, pluralized for +n+
  ***REMOVED*** @example
  ***REMOVED***   'user'.pluralize_for(1)
  ***REMOVED***    => user
  ***REMOVED***   'user'.pluralize_for(2)
  ***REMOVED***    => users
  ***REMOVED***
  def pluralize_for(n=2)
    n == 1 ? self : self.pluralize
  end

end
