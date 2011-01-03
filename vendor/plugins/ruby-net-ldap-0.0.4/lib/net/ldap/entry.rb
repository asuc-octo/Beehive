***REMOVED*** $Id: entry.rb 123 2006-05-18 03:52:38Z blackhedd $
***REMOVED***
***REMOVED*** LDAP Entry (search-result) support classes
***REMOVED***
***REMOVED***
***REMOVED***----------------------------------------------------------------------------
***REMOVED***
***REMOVED*** Copyright (C) 2006 by Francis Cianfrocca. All Rights Reserved.
***REMOVED***
***REMOVED*** Gmail: garbagecat10
***REMOVED***
***REMOVED*** This program is free software; you can redistribute it and/or modify
***REMOVED*** it under the terms of the GNU General Public License as published by
***REMOVED*** the Free Software Foundation; either version 2 of the License, or
***REMOVED*** (at your option) any later version.
***REMOVED***
***REMOVED*** This program is distributed in the hope that it will be useful,
***REMOVED*** but WITHOUT ANY WARRANTY; without even the implied warranty of
***REMOVED*** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
***REMOVED*** GNU General Public License for more details.
***REMOVED***
***REMOVED*** You should have received a copy of the GNU General Public License
***REMOVED*** along with this program; if not, write to the Free Software
***REMOVED*** Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
***REMOVED***
***REMOVED***---------------------------------------------------------------------------
***REMOVED***




module Net
class LDAP


  ***REMOVED*** Objects of this class represent individual entries in an LDAP
  ***REMOVED*** directory. User code generally does not instantiate this class.
  ***REMOVED*** Net::LDAP***REMOVED***search provides objects of this class to user code,
  ***REMOVED*** either as block parameters or as return values.
  ***REMOVED***
  ***REMOVED*** In LDAP-land, an "entry" is a collection of attributes that are
  ***REMOVED*** uniquely and globally identified by a DN ("Distinguished Name").
  ***REMOVED*** Attributes are identified by short, descriptive words or phrases.
  ***REMOVED*** Although a directory is
  ***REMOVED*** free to implement any attribute name, most of them follow rigorous
  ***REMOVED*** standards so that the range of commonly-encountered attribute
  ***REMOVED*** names is not large.
  ***REMOVED***
  ***REMOVED*** An attribute name is case-insensitive. Most directories also
  ***REMOVED*** restrict the range of characters allowed in attribute names.
  ***REMOVED*** To simplify handling attribute names, Net::LDAP::Entry
  ***REMOVED*** internally converts them to a standard format. Therefore, the
  ***REMOVED*** methods which take attribute names can take Strings or Symbols,
  ***REMOVED*** and work correctly regardless of case or capitalization.
  ***REMOVED***
  ***REMOVED*** An attribute consists of zero or more data items called
  ***REMOVED*** <i>values.</i> An entry is the combination of a unique DN, a set of attribute
  ***REMOVED*** names, and a (possibly-empty) array of values for each attribute.
  ***REMOVED***
  ***REMOVED*** Class Net::LDAP::Entry provides convenience methods for dealing
  ***REMOVED*** with LDAP entries.
  ***REMOVED*** In addition to the methods documented below, you may access individual
  ***REMOVED*** attributes of an entry simply by giving the attribute name as
  ***REMOVED*** the name of a method call. For example:
  ***REMOVED***  ldap.search( ... ) do |entry|
  ***REMOVED***    puts "Common name: ***REMOVED***{entry.cn}"
  ***REMOVED***    puts "Email addresses:"
  ***REMOVED***      entry.mail.each {|ma| puts ma}
  ***REMOVED***  end
  ***REMOVED*** If you use this technique to access an attribute that is not present
  ***REMOVED*** in a particular Entry object, a NoMethodError exception will be raised.
  ***REMOVED***
  ***REMOVED***--
  ***REMOVED*** Ugly problem to fix someday: We key off the internal hash with
  ***REMOVED*** a canonical form of the attribute name: convert to a string,
  ***REMOVED*** downcase, then take the symbol. Unfortunately we do this in
  ***REMOVED*** at least three places. Should do it in ONE place.
  class Entry

    ***REMOVED*** This constructor is not generally called by user code.
    def initialize dn = nil ***REMOVED*** :nodoc:
      @myhash = Hash.new {|k,v| k[v] = [] }
      @myhash[:dn] = [dn]
    end


    def []= name, value ***REMOVED*** :nodoc:
      sym = name.to_s.downcase.intern
      @myhash[sym] = value
    end


    ***REMOVED***--
    ***REMOVED*** We have to deal with this one as we do with []=
    ***REMOVED*** because this one and not the other one gets called
    ***REMOVED*** in formulations like entry["CN"] << cn.
    ***REMOVED***
    def [] name ***REMOVED*** :nodoc:
      name = name.to_s.downcase.intern unless name.is_a?(Symbol)
      @myhash[name]
    end

    ***REMOVED*** Returns the dn of the Entry as a String.
    def dn
      self[:dn][0]
    end

    ***REMOVED*** Returns an array of the attribute names present in the Entry.
    def attribute_names
      @myhash.keys
    end

    ***REMOVED*** Accesses each of the attributes present in the Entry.
    ***REMOVED*** Calls a user-supplied block with each attribute in turn,
    ***REMOVED*** passing two arguments to the block: a Symbol giving
    ***REMOVED*** the name of the attribute, and a (possibly empty)
    ***REMOVED*** Array of data values.
    ***REMOVED***
    def each
      if block_given?
        attribute_names.each {|a|
          attr_name,values = a,self[a]
          yield attr_name, values
        }
      end
    end

    alias_method :each_attribute, :each


    ***REMOVED***--
    ***REMOVED*** Convenience method to convert unknown method names
    ***REMOVED*** to attribute references. Of course the method name
    ***REMOVED*** comes to us as a symbol, so let's save a little time
    ***REMOVED*** and not bother with the to_s.downcase two-step.
    ***REMOVED*** Of course that means that a method name like mAIL
    ***REMOVED*** won't work, but we shouldn't be encouraging that
    ***REMOVED*** kind of bad behavior in the first place.
    ***REMOVED*** Maybe we should thow something if the caller sends
    ***REMOVED*** arguments or a block...
    ***REMOVED***
    def method_missing *args, &block ***REMOVED*** :nodoc:
      s = args[0].to_s.downcase.intern
      if attribute_names.include?(s)
        self[s]
      elsif s.to_s[-1] == 61 and s.to_s.length > 1
        value = args[1] or raise RuntimeError.new( "unable to set value" )
        value = [value] unless value.is_a?(Array)
        name = s.to_s[0..-2].intern
        self[name] = value
      else
        raise NoMethodError.new( "undefined method '***REMOVED***{s}'" )
      end
    end

    def write
    end

  end ***REMOVED*** class Entry


end ***REMOVED*** class LDAP
end ***REMOVED*** module Net


