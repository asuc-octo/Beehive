***REMOVED*** $Id: psw.rb 73 2006-04-24 21:59:35Z blackhedd $
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


class Password
  class << self

  ***REMOVED*** Generate a password-hash suitable for inclusion in an LDAP attribute.
  ***REMOVED*** Pass a hash type (currently supported: :md5 and :sha) and a plaintext
  ***REMOVED*** password. This function will return a hashed representation.
  ***REMOVED*** STUB: This is here to fulfill the requirements of an RFC, which one?
  ***REMOVED*** TODO, gotta do salted-sha and (maybe) salted-md5.
  ***REMOVED*** Should we provide sha1 as a synonym for sha1? I vote no because then
  ***REMOVED*** should you also provide ssha1 for symmetry?
  def generate( type, str )
    case type
    when :md5
      require 'md5'
      "{MD5}***REMOVED***{ [MD5.new( str.to_s ).digest].pack("m").chomp }"
    when :sha
      require 'sha1'
      "{SHA}***REMOVED***{ [SHA1.new( str.to_s ).digest].pack("m").chomp }"
    ***REMOVED*** when ssha
    else
      raise Net::LDAP::LdapError.new( "unsupported password-hash type (***REMOVED***{type})" )
    end
  end

  end
end


end ***REMOVED*** class LDAP
end ***REMOVED*** module Net


