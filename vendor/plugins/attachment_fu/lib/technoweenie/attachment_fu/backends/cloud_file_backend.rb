module Technoweenie ***REMOVED*** :nodoc:
  module AttachmentFu ***REMOVED*** :nodoc:
    module Backends
      ***REMOVED*** = CloudFiles Storage Backend
      ***REMOVED***
      ***REMOVED*** Enables use of {Rackspace Cloud Files}[http://www.mosso.com/cloudfiles.jsp] as a storage mechanism
      ***REMOVED***
      ***REMOVED*** Based heavily on the Amazon S3 backend.
      ***REMOVED***
      ***REMOVED*** == Requirements
      ***REMOVED***
      ***REMOVED*** Requires the {Cloud Files Gem}[http://www.mosso.com/cloudfiles.jsp] by Rackspace 
      ***REMOVED***
      ***REMOVED*** == Configuration
      ***REMOVED***
      ***REMOVED*** Configuration is done via <tt>Rails.root/config/rackspace_cloudfiles.yml</tt> and is loaded according to the <tt>RAILS_ENV</tt>.
      ***REMOVED*** The minimum connection options that you must specify are a container name, your Mosso login name and your Mosso API key.
      ***REMOVED*** You can sign up for Cloud Files and get access keys by visiting https://www.mosso.com/buy.htm 
      ***REMOVED***
      ***REMOVED*** Example configuration (Rails.root/config/rackspace_cloudfiles.yml)
      ***REMOVED***
      ***REMOVED***   ***REMOVED***
      ***REMOVED***     container_name: appname_development
      ***REMOVED***     username: <your key>
      ***REMOVED***     api_key: <your key>
      ***REMOVED***
      ***REMOVED***   ***REMOVED***
      ***REMOVED***     container_name: appname_test
      ***REMOVED***     username: <your key>
      ***REMOVED***     api_key: <your key>
      ***REMOVED***
      ***REMOVED***   ***REMOVED***
      ***REMOVED***     container_name: appname
      ***REMOVED***     username: <your key>
      ***REMOVED***     apik_key: <your key>
      ***REMOVED***
      ***REMOVED*** You can change the location of the config path by passing a full path to the :cloudfiles_config_path option.
      ***REMOVED***
      ***REMOVED***   has_attachment :storage => :cloud_files, :cloudfiles_config_path => (Rails.root + '/config/mosso.yml')
      ***REMOVED***
      ***REMOVED*** === Required configuration parameters
      ***REMOVED***
      ***REMOVED*** * <tt>:username</tt> - The username for your Rackspace Cloud (Mosso) account. Provided by Rackspace.
      ***REMOVED*** * <tt>:secret_access_key</tt> - The api key for your Rackspace Cloud account. Provided by Rackspace.
      ***REMOVED*** * <tt>:container_name</tt> - The name of a container in your Cloud Files account.
      ***REMOVED***
      ***REMOVED*** If any of these required arguments is missing, a AuthenticationException will be raised from CloudFiles::Connection.
      ***REMOVED***
      ***REMOVED*** == Usage
      ***REMOVED***
      ***REMOVED*** To specify Cloud Files as the storage mechanism for a model, set the acts_as_attachment <tt>:storage</tt> option to <tt>:cloud_files/tt>.
      ***REMOVED***
      ***REMOVED***   class Photo < ActiveRecord::Base
      ***REMOVED***     has_attachment :storage => :cloud_files
      ***REMOVED***   end
      ***REMOVED***
      ***REMOVED*** === Customizing the path
      ***REMOVED***
      ***REMOVED*** By default, files are prefixed using a pseudo hierarchy in the form of <tt>:table_name/:id</tt>, which results
      ***REMOVED*** in Cloud Files object names (and urls) that look like: http://:server/:container_name/:table_name/:id/:filename with :table_name
      ***REMOVED*** representing the customizable portion of the path. You can customize this prefix using the <tt>:path_prefix</tt>
      ***REMOVED*** option:
      ***REMOVED***
      ***REMOVED***   class Photo < ActiveRecord::Base
      ***REMOVED***     has_attachment :storage => :cloud_files, :path_prefix => 'my/custom/path'
      ***REMOVED***   end
      ***REMOVED***
      ***REMOVED*** Which would result in public URLs like <tt>http(s)://:server/:container_name/my/custom/path/:id/:filename.</tt>
      ***REMOVED***
      ***REMOVED*** === Permissions
      ***REMOVED***
      ***REMOVED*** File permisisons are determined by the permissions of the container.  At present, the options are public (and distributed
      ***REMOVED*** by the Limelight CDN), and private (only available to your login)
      ***REMOVED***
      ***REMOVED*** === Other options
      ***REMOVED***
      ***REMOVED*** Of course, all the usual configuration options apply, such as content_type and thumbnails:
      ***REMOVED***
      ***REMOVED***   class Photo < ActiveRecord::Base
      ***REMOVED***     has_attachment :storage => :cloud_files, :content_type => ['application/pdf', :image], :resize_to => 'x50'
      ***REMOVED***     has_attachment :storage => :cloud_files, :thumbnails => { :thumb => [50, 50], :geometry => 'x50' }
      ***REMOVED***   end
      ***REMOVED***
      ***REMOVED*** === Accessing Cloud Files URLs
      ***REMOVED***
      ***REMOVED*** You can get an object's public URL using the cloudfiles_url accessor. For example, assuming that for your postcard app
      ***REMOVED*** you had a container name like 'postcard_world_development', and an attachment model called Photo:
      ***REMOVED***
      ***REMOVED***   @postcard.cloudfiles_url ***REMOVED*** => http://cdn.cloudfiles.mosso.com/c45182/uploaded_files/20/london.jpg
      ***REMOVED***
      ***REMOVED*** The resulting url is in the form: http://:server/:container_name/:table_name/:id/:file.
      ***REMOVED*** The optional thumbnail argument will output the thumbnail's filename (if any).
      ***REMOVED***
      ***REMOVED*** Additionally, you can get an object's base path relative to the container root using
      ***REMOVED*** <tt>base_path</tt>:
      ***REMOVED***
      ***REMOVED***   @photo.file_base_path ***REMOVED*** => uploaded_files/20
      ***REMOVED***
      ***REMOVED*** And the full path (including the filename) using <tt>full_filename</tt>:
      ***REMOVED***
      ***REMOVED***   @photo.full_filename ***REMOVED*** => uploaded_files/20/london.jpg
      ***REMOVED***
      ***REMOVED*** Niether <tt>base_path</tt> or <tt>full_filename</tt> include the container name as part of the path.
      ***REMOVED*** You can retrieve the container name using the <tt>container_name</tt> method.
      module CloudFileBackend
        class RequiredLibraryNotFoundError < StandardError; end
        class ConfigFileNotFoundError < StandardError; end

        def self.included(base) ***REMOVED***:nodoc:
          mattr_reader :container_name, :cloudfiles_config

          begin
            require 'cloudfiles'
          rescue LoadError
            raise RequiredLibraryNotFoundError.new('CloudFiles could not be loaded')
          end

          begin
            @@cloudfiles_config_path = base.attachment_options[:cloudfiles_config_path] || (Rails.root + '/config/rackspace_cloudfiles.yml')
            @@cloudfiles_config = @@cloudfiles_config = YAML.load(ERB.new(File.read(@@cloudfiles_config_path)).result)[RAILS_ENV].symbolize_keys
          rescue
            ***REMOVED***raise ConfigFileNotFoundError.new('File %s not found' % @@cloudfiles_config_path)
          end

          @@container_name = @@cloudfiles_config[:container_name]
          @@cf = CloudFiles::Connection.new(@@cloudfiles_config[:username], @@cloudfiles_config[:api_key])
          @@container = @@cf.container(@@container_name)
          
          base.before_update :rename_file
        end

        ***REMOVED*** Overwrites the base filename writer in order to store the old filename
        def filename=(value)
          @old_filename = filename unless filename.nil? || @old_filename
          write_attribute :filename, sanitize_filename(value)
        end

        ***REMOVED*** The attachment ID used in the full path of a file
        def attachment_path_id
          ((respond_to?(:parent_id) && parent_id) || id).to_s
        end

        ***REMOVED*** The pseudo hierarchy containing the file relative to the container name
        ***REMOVED*** Example: <tt>:table_name/:id</tt>
        def base_path
          File.join(attachment_options[:path_prefix], attachment_path_id)
        end

        ***REMOVED*** The full path to the file relative to the container name
        ***REMOVED*** Example: <tt>:table_name/:id/:filename</tt>
        def full_filename(thumbnail = nil)
          File.join(base_path, thumbnail_name_for(thumbnail))
        end

        ***REMOVED*** All public objects are accessible via a GET request to the Cloud Files servers. You can generate a
        ***REMOVED*** url for an object using the cloudfiles_url method.
        ***REMOVED***
        ***REMOVED***   @photo.cloudfiles_url
        ***REMOVED***
        ***REMOVED*** The resulting url is in the CDN URL for the object
        ***REMOVED***
        ***REMOVED*** The optional thumbnail argument will output the thumbnail's filename (if any).
        ***REMOVED***
        ***REMOVED*** If you are trying to get the URL for a nonpublic container, nil will be returned.
        def cloudfiles_url(thumbnail = nil)
          if @@container.public?
            File.join(@@container.cdn_url, full_filename(thumbnail))
          else
            nil
          end
        end
        alias :public_filename :cloudfiles_url

        def create_temp_file
          write_to_temp_file current_data
        end

        def current_data
          @@container.get_object(full_filename).data
        end

        protected
          ***REMOVED*** Called in the after_destroy callback
          def destroy_file
            @@container.delete_object(full_filename)
          end

          def rename_file
            ***REMOVED*** Cloud Files doesn't rename right now, so we'll just nuke.
            return unless @old_filename && @old_filename != filename

            old_full_filename = File.join(base_path, @old_filename)
            @@container.delete_object(old_full_filename)

            @old_filename = nil
            true
          end

          def save_to_storage
            if save_attachment?
              @object = @@container.create_object(full_filename)
              @object.write((temp_path ? File.open(temp_path) : temp_data))
            end

            @old_filename = nil
            true
          end
      end
    end
  end
end
