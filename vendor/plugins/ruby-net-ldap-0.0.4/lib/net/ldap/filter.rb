***REMOVED*** $Id: filter.rb 151 2006-08-15 08:34:53Z blackhedd $
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


***REMOVED*** Class Net::LDAP::Filter is used to constrain
***REMOVED*** LDAP searches. An object of this class is
***REMOVED*** passed to Net::LDAP***REMOVED***search in the parameter :filter.
***REMOVED***
***REMOVED*** Net::LDAP::Filter supports the complete set of search filters
***REMOVED*** available in LDAP, including conjunction, disjunction and negation
***REMOVED*** (AND, OR, and NOT). This class supplants the (infamous) RFC-2254
***REMOVED*** standard notation for specifying LDAP search filters.
***REMOVED***
***REMOVED*** Here's how to code the familiar "objectclass is present" filter:
***REMOVED***  f = Net::LDAP::Filter.pres( "objectclass" )
***REMOVED*** The object returned by this code can be passed directly to
***REMOVED*** the <tt>:filter</tt> parameter of Net::LDAP***REMOVED***search.
***REMOVED***
***REMOVED*** See the individual class and instance methods below for more examples.
***REMOVED***
class Filter

  def initialize op, a, b
    @op = op
    @left = a
    @right = b
  end

  ***REMOVED*** ***REMOVED***eq creates a filter object indicating that the value of
  ***REMOVED*** a paticular attribute must be either <i>present</i> or must
  ***REMOVED*** match a particular string.
  ***REMOVED***
  ***REMOVED*** To specify that an attribute is "present" means that only
  ***REMOVED*** directory entries which contain a value for the particular
  ***REMOVED*** attribute will be selected by the filter. This is useful
  ***REMOVED*** in case of optional attributes such as <tt>mail.</tt>
  ***REMOVED*** Presence is indicated by giving the value "*" in the second
  ***REMOVED*** parameter to ***REMOVED***eq. This example selects only entries that have
  ***REMOVED*** one or more values for <tt>sAMAccountName:</tt>
  ***REMOVED***  f = Net::LDAP::Filter.eq( "sAMAccountName", "*" )
  ***REMOVED***
  ***REMOVED*** To match a particular range of values, pass a string as the
  ***REMOVED*** second parameter to ***REMOVED***eq. The string may contain one or more
  ***REMOVED*** "*" characters as wildcards: these match zero or more occurrences
  ***REMOVED*** of any character. Full regular-expressions are <i>not</i> supported
  ***REMOVED*** due to limitations in the underlying LDAP protocol.
  ***REMOVED*** This example selects any entry with a <tt>mail</tt> value containing
  ***REMOVED*** the substring "anderson":
  ***REMOVED***  f = Net::LDAP::Filter.eq( "mail", "*anderson*" )
  ***REMOVED***--
  ***REMOVED*** Removed gt and lt. They ain't in the standard!
  ***REMOVED***
  def Filter::eq attribute, value; Filter.new :eq, attribute, value; end
  def Filter::ne attribute, value; Filter.new :ne, attribute, value; end
  ***REMOVED***def Filter::gt attribute, value; Filter.new :gt, attribute, value; end
  ***REMOVED***def Filter::lt attribute, value; Filter.new :lt, attribute, value; end
  def Filter::ge attribute, value; Filter.new :ge, attribute, value; end
  def Filter::le attribute, value; Filter.new :le, attribute, value; end

  ***REMOVED*** ***REMOVED***pres( attribute ) is a synonym for ***REMOVED***eq( attribute, "*" )
  ***REMOVED***
  def Filter::pres attribute; Filter.eq attribute, "*"; end

  ***REMOVED*** operator & ("AND") is used to conjoin two or more filters.
  ***REMOVED*** This expression will select only entries that have an <tt>objectclass</tt>
  ***REMOVED*** attribute AND have a <tt>mail</tt> attribute that begins with "George":
  ***REMOVED***  f = Net::LDAP::Filter.pres( "objectclass" ) & Net::LDAP::Filter.eq( "mail", "George*" )
  ***REMOVED***
  def & filter; Filter.new :and, self, filter; end

  ***REMOVED*** operator | ("OR") is used to disjoin two or more filters.
  ***REMOVED*** This expression will select entries that have either an <tt>objectclass</tt>
  ***REMOVED*** attribute OR a <tt>mail</tt> attribute that begins with "George":
  ***REMOVED***  f = Net::LDAP::Filter.pres( "objectclass" ) | Net::LDAP::Filter.eq( "mail", "George*" )
  ***REMOVED***
  def | filter; Filter.new :or, self, filter; end


  ***REMOVED***
  ***REMOVED*** operator ~ ("NOT") is used to negate a filter.
  ***REMOVED*** This expression will select only entries that <i>do not</i> have an <tt>objectclass</tt>
  ***REMOVED*** attribute:
  ***REMOVED***  f = ~ Net::LDAP::Filter.pres( "objectclass" )
  ***REMOVED***
  ***REMOVED***--
  ***REMOVED*** This operator can't be !, evidently. Try it.
  ***REMOVED*** Removed GT and LT. They're not in the RFC.
  def ~@; Filter.new :not, self, nil; end


  def to_s
    case @op
    when :ne
      "(!(***REMOVED***{@left}=***REMOVED***{@right}))"
    when :eq
      "(***REMOVED***{@left}=***REMOVED***{@right})"
    ***REMOVED***when :gt
     ***REMOVED*** "***REMOVED***{@left}>***REMOVED***{@right}"
    ***REMOVED***when :lt
     ***REMOVED*** "***REMOVED***{@left}<***REMOVED***{@right}"
    when :ge
      "***REMOVED***{@left}>=***REMOVED***{@right}"
    when :le
      "***REMOVED***{@left}<=***REMOVED***{@right}"
    when :and
      "(&(***REMOVED***{@left})(***REMOVED***{@right}))"
    when :or
      "(|(***REMOVED***{@left})(***REMOVED***{@right}))"
    when :not
      "(!(***REMOVED***{@left}))"
    else
      raise "invalid or unsupported operator in LDAP Filter"
    end
  end


  ***REMOVED***--
  ***REMOVED*** to_ber
  ***REMOVED*** Filter ::=
  ***REMOVED***     CHOICE {
  ***REMOVED***         and            [0] SET OF Filter,
  ***REMOVED***         or             [1] SET OF Filter,
  ***REMOVED***         not            [2] Filter,
  ***REMOVED***         equalityMatch  [3] AttributeValueAssertion,
  ***REMOVED***         substrings     [4] SubstringFilter,
  ***REMOVED***         greaterOrEqual [5] AttributeValueAssertion,
  ***REMOVED***         lessOrEqual    [6] AttributeValueAssertion,
  ***REMOVED***         present        [7] AttributeType,
  ***REMOVED***         approxMatch    [8] AttributeValueAssertion
  ***REMOVED***     }
  ***REMOVED***
  ***REMOVED*** SubstringFilter
  ***REMOVED***     SEQUENCE {
  ***REMOVED***         type               AttributeType,
  ***REMOVED***         SEQUENCE OF CHOICE {
  ***REMOVED***             initial        [0] LDAPString,
  ***REMOVED***             any            [1] LDAPString,
  ***REMOVED***             final          [2] LDAPString
  ***REMOVED***         }
  ***REMOVED***     }
  ***REMOVED***
  ***REMOVED*** Parsing substrings is a little tricky.
  ***REMOVED*** We use the split method to break a string into substrings
  ***REMOVED*** delimited by the * (star) character. But we also need
  ***REMOVED*** to know whether there is a star at the head and tail
  ***REMOVED*** of the string. A Ruby particularity comes into play here:
  ***REMOVED*** if you split on * and the first character of the string is
  ***REMOVED*** a star, then split will return an array whose first element
  ***REMOVED*** is an _empty_ string. But if the _last_ character of the
  ***REMOVED*** string is star, then split will return an array that does
  ***REMOVED*** _not_ add an empty string at the end. So we have to deal
  ***REMOVED*** with all that specifically.
  ***REMOVED***
  def to_ber
    case @op
    when :eq
      if @right == "*"          ***REMOVED*** present
        @left.to_s.to_ber_contextspecific 7
      elsif @right =~ /[\*]/    ***REMOVED***substring
        ary = @right.split( /[\*]+/ )
        final_star = @right =~ /[\*]$/
        initial_star = ary.first == "" and ary.shift

        seq = []
        unless initial_star
          seq << ary.shift.to_ber_contextspecific(0)
        end
        n_any_strings = ary.length - (final_star ? 0 : 1)
        ***REMOVED***p n_any_strings
        n_any_strings.times {
          seq << ary.shift.to_ber_contextspecific(1)
        }
        unless final_star
          seq << ary.shift.to_ber_contextspecific(2)
        end
        [@left.to_s.to_ber, seq.to_ber].to_ber_contextspecific 4
      else                      ***REMOVED***equality
        [@left.to_s.to_ber, @right.to_ber].to_ber_contextspecific 3
      end
    when :ge
      [@left.to_s.to_ber, @right.to_ber].to_ber_contextspecific 5
    when :le
      [@left.to_s.to_ber, @right.to_ber].to_ber_contextspecific 6
    when :and
      ary = [@left.coalesce(:and), @right.coalesce(:and)].flatten
      ary.map {|a| a.to_ber}.to_ber_contextspecific( 0 )
    when :or
      ary = [@left.coalesce(:or), @right.coalesce(:or)].flatten
      ary.map {|a| a.to_ber}.to_ber_contextspecific( 1 )
    when :not
        [@left.to_ber].to_ber_contextspecific 2
    else
      ***REMOVED*** ERROR, we'll return objectclass=* to keep things from blowing up,
      ***REMOVED*** but that ain't a good answer and we need to kick out an error of some kind.
      raise "unimplemented search filter"
    end
  end

  ***REMOVED***--
  ***REMOVED*** coalesce
  ***REMOVED*** This is a private helper method for dealing with chains of ANDs and ORs
  ***REMOVED*** that are longer than two. If BOTH of our branches are of the specified
  ***REMOVED*** type of joining operator, then return both of them as an array (calling
  ***REMOVED*** coalesce recursively). If they're not, then return an array consisting
  ***REMOVED*** only of self.
  ***REMOVED***
  def coalesce operator
    if @op == operator
      [@left.coalesce( operator ), @right.coalesce( operator )]
    else
      [self]
    end
  end



  ***REMOVED***--
  ***REMOVED*** We get a Ruby object which comes from parsing an RFC-1777 "Filter"
  ***REMOVED*** object. Convert it to a Net::LDAP::Filter.
  ***REMOVED*** TODO, we're hardcoding the RFC-1777 BER-encodings of the various
  ***REMOVED*** filter types. Could pull them out into a constant.
  ***REMOVED***
  def Filter::parse_ldap_filter obj
    case obj.ber_identifier
    when 0x87         ***REMOVED*** present. context-specific primitive 7.
      Filter.eq( obj.to_s, "*" )
    when 0xa3         ***REMOVED*** equalityMatch. context-specific constructed 3.
      Filter.eq( obj[0], obj[1] )
    else
      raise LdapError.new( "unknown ldap search-filter type: ***REMOVED***{obj.ber_identifier}" )
    end
  end


  ***REMOVED***--
  ***REMOVED*** We got a hash of attribute values.
  ***REMOVED*** Do we match the attributes?
  ***REMOVED*** Return T/F, and call match recursively as necessary.
  def match entry
    case @op
    when :eq
      if @right == "*"
        l = entry[@left] and l.length > 0
      else
        l = entry[@left] and l = l.to_a and l.index(@right)
      end
    else
      raise LdapError.new( "unknown filter type in match: ***REMOVED***{@op}" )
    end
  end

  ***REMOVED*** Converts an LDAP filter-string (in the prefix syntax specified in RFC-2254)
  ***REMOVED*** to a Net::LDAP::Filter.
  def self.construct ldap_filter_string
    FilterParser.new(ldap_filter_string).filter
  end

  ***REMOVED*** Synonym for ***REMOVED***construct.
  ***REMOVED*** to a Net::LDAP::Filter.
  def self.from_rfc2254 ldap_filter_string
    construct ldap_filter_string
  end

end ***REMOVED*** class Net::LDAP::Filter



class FilterParser ***REMOVED***:nodoc:

  attr_reader :filter

  def initialize str
    require 'strscan'
    @filter = parse( StringScanner.new( str )) or raise Net::LDAP::LdapError.new( "invalid filter syntax" )
  end

  def parse scanner
    parse_filter_branch(scanner) or parse_paren_expression(scanner)
  end

  def parse_paren_expression scanner
    if scanner.scan /\s*\(\s*/
      b = if scanner.scan /\s*\&\s*/
        a = nil
        branches = []
        while br = parse_paren_expression(scanner)
          branches << br
        end
        if branches.length >= 2
          a = branches.shift
          while branches.length > 0
            a = a & branches.shift
          end
          a
        end
      elsif scanner.scan /\s*\|\s*/
        ***REMOVED*** TODO: DRY!
        a = nil
        branches = []
        while br = parse_paren_expression(scanner)
          branches << br
        end
        if branches.length >= 2
          a = branches.shift
          while branches.length > 0
            a = a | branches.shift
          end
          a
        end
      elsif scanner.scan /\s*\!\s*/
        br = parse_paren_expression(scanner)
        if br
          ~ br
        end
      else
        parse_filter_branch( scanner )
      end

      if b and scanner.scan( /\s*\)\s*/ )
        b
      end
    end
  end

  ***REMOVED*** Added a greatly-augmented filter contributed by Andre Nathan
  ***REMOVED*** for detecting special characters in values. (15Aug06)
  def parse_filter_branch scanner
    scanner.scan /\s*/
    if token = scanner.scan( /[\w\-_]+/ )
      scanner.scan /\s*/
      if op = scanner.scan( /\=|\<\=|\<|\>\=|\>|\!\=/ )
        scanner.scan /\s*/
        ***REMOVED***if value = scanner.scan( /[\w\*\.]+/ ) (ORG)
        if value = scanner.scan( /[\w\*\.\+\-@=***REMOVED***\$%&!]+/ )
          case op
          when "="
            Filter.eq( token, value )
          when "!="
            Filter.ne( token, value )
          when "<"
            Filter.lt( token, value )
          when "<="
            Filter.le( token, value )
          when ">"
            Filter.gt( token, value )
          when ">="
            Filter.ge( token, value )
          end
        end
      end
    end
  end

end ***REMOVED*** class Net::LDAP::FilterParser

end ***REMOVED*** class Net::LDAP
end ***REMOVED*** module Net


