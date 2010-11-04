module ThinkingSphinx
  class MysqlAdapter < AbstractAdapter
    def setup
      ***REMOVED*** Does MySQL actually need to do anything?
    end
    
    def sphinx_identifier
      "mysql"
    end
    
    def concatenate(clause, separator = ' ')
      "CONCAT_WS('***REMOVED***{separator}', ***REMOVED***{clause})"
    end
    
    def group_concatenate(clause, separator = ' ')
      "GROUP_CONCAT(DISTINCT IFNULL(***REMOVED***{clause}, '0') SEPARATOR '***REMOVED***{separator}')"
    end
    
    def cast_to_string(clause)
      "CAST(***REMOVED***{clause} AS CHAR)"
    end
    
    def cast_to_datetime(clause)
      "UNIX_TIMESTAMP(***REMOVED***{clause})"
    end
    
    def cast_to_unsigned(clause)
      "CAST(***REMOVED***{clause} AS UNSIGNED)"
    end
    
    def convert_nulls(clause, default = '')
      default = "'***REMOVED***{default}'" if default.is_a?(String)
      
      "IFNULL(***REMOVED***{clause}, ***REMOVED***{default})"
    end
    
    def boolean(value)
      value ? 1 : 0
    end
    
    def crc(clause, blank_to_null = false)
      clause = "NULLIF(***REMOVED***{clause},'')" if blank_to_null
      "CRC32(***REMOVED***{clause})"
    end
    
    def utf8_query_pre
      "SET NAMES utf8"
    end
    
    def time_difference(diff)
      "DATE_SUB(NOW(), INTERVAL ***REMOVED***{diff} SECOND)"
    end
    
    def utc_query_pre
      "SET TIME_ZONE = '+0:00'"
    end
  end
end
