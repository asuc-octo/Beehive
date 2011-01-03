***REMOVED*** $Id: dataset.rb 78 2006-04-26 02:57:34Z blackhedd $
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
***REMOVED***




module Net
class LDAP

class Dataset < Hash

  attr_reader :comments


  def Dataset::read_ldif io
    ds = Dataset.new

    line = io.gets && chomp
    dn = nil

    while line
      io.gets and chomp
      if $_ =~ /^[\s]+/
        line << " " << $'
      else
        nextline = $_

        if line =~ /^\***REMOVED***/
          ds.comments << line
        elsif line =~ /^dn:[\s]*/i
          dn = $'
          ds[dn] = Hash.new {|k,v| k[v] = []}
        elsif line.length == 0
          dn = nil
        elsif line =~ /^([^:]+):([\:]?)[\s]*/
          ***REMOVED*** $1 is the attribute name
          ***REMOVED*** $2 is a colon iff the attr-value is base-64 encoded
          ***REMOVED*** $' is the attr-value
          ***REMOVED*** Avoid the Base64 class because not all Ruby versions have it.
          attrvalue = ($2 == ":") ? $'.unpack('m').shift : $'
          ds[dn][$1.downcase.intern] << attrvalue
        end

        line = nextline
      end
    end
  
    ds
  end


  def initialize
    @comments = []
  end


  def to_ldif
    ary = []
    ary += (@comments || [])

    keys.sort.each {|dn|
      ary << "dn: ***REMOVED***{dn}"

      self[dn].keys.map {|sym| sym.to_s}.sort.each {|attr|
        self[dn][attr.intern].each {|val|
          ary << "***REMOVED***{attr}: ***REMOVED***{val}"
        }
      }

      ary << ""
    }

    block_given? and ary.each {|line| yield line}

    ary
  end


end ***REMOVED*** Dataset

end ***REMOVED*** LDAP
end ***REMOVED*** Net


