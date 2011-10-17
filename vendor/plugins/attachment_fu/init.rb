require 'tempfile'

***REMOVED*** Tempfile.class_eval do
***REMOVED***   ***REMOVED*** overwrite so tempfiles use the extension of the basename.  important for rmagick and image science
***REMOVED***   def make_tmpname(basename, n)
***REMOVED***     ext = nil
***REMOVED***     sprintf("%s%d-%d%s", basename.to_s.gsub(/\.\w+$/) { |s| ext = s; '' }, $$, n, ext)
***REMOVED***   end
***REMOVED*** end

require 'geometry'
ActiveRecord::Base.send(:extend, Technoweenie::AttachmentFu::ActMethods)
Technoweenie::AttachmentFu.tempfile_path = ATTACHMENT_FU_TEMPFILE_PATH if Object.const_defined?(:ATTACHMENT_FU_TEMPFILE_PATH)
FileUtils.mkdir_p Technoweenie::AttachmentFu.tempfile_path

$:.unshift(File.dirname(__FILE__) + '/vendor')
