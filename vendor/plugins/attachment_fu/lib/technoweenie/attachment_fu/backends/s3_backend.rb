module Technoweenie ***REMOVED*** :nodoc:
  module AttachmentFu ***REMOVED*** :nodoc:
    module Backends
      ***REMOVED*** = AWS::S3 Storage Backend
      ***REMOVED***
      ***REMOVED*** Enables use of {Amazon's Simple Storage Service}[http://aws.amazon.com/s3] as a storage mechanism
      ***REMOVED***
      ***REMOVED*** == Requirements
      ***REMOVED***
      ***REMOVED*** Requires the {AWS::S3 Library}[http://amazon.rubyforge.org] for S3 by Marcel Molina Jr. installed either
      ***REMOVED*** as a gem or a as a Rails plugin.
      ***REMOVED***
      ***REMOVED*** == Configuration
      ***REMOVED***
      ***REMOVED*** Configuration is done via <tt>Rails.root/config/amazon_s3.yml</tt> and is loaded according to the <tt>RAILS_ENV</tt>.
      ***REMOVED*** The minimum connection options that you must specify are a bucket name, your access key id and your secret access key.
      ***REMOVED*** If you don't already have your access keys, all you need to sign up for the S3 service is an account at Amazon.
      ***REMOVED*** You can sign up for S3 and get access keys by visiting http://aws.amazon.com/s3.
      ***REMOVED***
      ***REMOVED*** If you wish to use Amazon CloudFront to serve the files, you can also specify a distibution domain for the bucket.
      ***REMOVED*** To read more about CloudFront, visit http://aws.amazon.com/cloudfront
      ***REMOVED***
      ***REMOVED*** Example configuration (Rails.root/config/amazon_s3.yml)
      ***REMOVED***
      ***REMOVED***   ***REMOVED***
      ***REMOVED***     bucket_name: appname_development
      ***REMOVED***     access_key_id: <your key>
      ***REMOVED***     secret_access_key: <your key>
      ***REMOVED***     distribution_domain: XXXX.cloudfront.net
      ***REMOVED***
      ***REMOVED***   ***REMOVED***
      ***REMOVED***     bucket_name: appname_test
      ***REMOVED***     access_key_id: <your key>
      ***REMOVED***     secret_access_key: <your key>
      ***REMOVED***     distribution_domain: XXXX.cloudfront.net
      ***REMOVED***
      ***REMOVED***   ***REMOVED***
      ***REMOVED***     bucket_name: appname
      ***REMOVED***     access_key_id: <your key>
      ***REMOVED***     secret_access_key: <your key>
      ***REMOVED***     distribution_domain: XXXX.cloudfront.net
      ***REMOVED***
      ***REMOVED*** You can change the location of the config path by passing a full path to the :s3_config_path option.
      ***REMOVED***
      ***REMOVED***   has_attachment :storage => :s3, :s3_config_path => (Rails.root + '/config/s3.yml')
      ***REMOVED***
      ***REMOVED*** === Required configuration parameters
      ***REMOVED***
      ***REMOVED*** * <tt>:access_key_id</tt> - The access key id for your S3 account. Provided by Amazon.
      ***REMOVED*** * <tt>:secret_access_key</tt> - The secret access key for your S3 account. Provided by Amazon.
      ***REMOVED*** * <tt>:bucket_name</tt> - A unique bucket name (think of the bucket_name as being like a database name).
      ***REMOVED***
      ***REMOVED*** If any of these required arguments is missing, a MissingAccessKey exception will be raised from AWS::S3.
      ***REMOVED***
      ***REMOVED*** == About bucket names
      ***REMOVED***
      ***REMOVED*** Bucket names have to be globaly unique across the S3 system. And you can only have up to 100 of them,
      ***REMOVED*** so it's a good idea to think of a bucket as being like a database, hence the correspondance in this
      ***REMOVED*** implementation to the development, test, and production environments.
      ***REMOVED***
      ***REMOVED*** The number of objects you can store in a bucket is, for all intents and purposes, unlimited.
      ***REMOVED***
      ***REMOVED*** === Optional configuration parameters
      ***REMOVED***
      ***REMOVED*** * <tt>:server</tt> - The server to make requests to. Defaults to <tt>s3.amazonaws.com</tt>.
      ***REMOVED*** * <tt>:port</tt> - The port to the requests should be made on. Defaults to 80 or 443 if <tt>:use_ssl</tt> is set.
      ***REMOVED*** * <tt>:use_ssl</tt> - If set to true, <tt>:port</tt> will be implicitly set to 443, unless specified otherwise. Defaults to false.
      ***REMOVED*** * <tt>:distribution_domain</tt> - The CloudFront distribution domain for the bucket.  This can either be the assigned
      ***REMOVED***     distribution domain (ie. XXX.cloudfront.net) or a chosen domain using a CNAME. See CloudFront for more details.
      ***REMOVED***
      ***REMOVED*** == Usage
      ***REMOVED***
      ***REMOVED*** To specify S3 as the storage mechanism for a model, set the acts_as_attachment <tt>:storage</tt> option to <tt>:s3</tt>.
      ***REMOVED***
      ***REMOVED***   class Photo < ActiveRecord::Base
      ***REMOVED***     has_attachment :storage => :s3
      ***REMOVED***   end
      ***REMOVED***
      ***REMOVED*** === Customizing the path
      ***REMOVED***
      ***REMOVED*** By default, files are prefixed using a pseudo hierarchy in the form of <tt>:table_name/:id</tt>, which results
      ***REMOVED*** in S3 urls that look like: http(s)://:server/:bucket_name/:table_name/:id/:filename with :table_name
      ***REMOVED*** representing the customizable portion of the path. You can customize this prefix using the <tt>:path_prefix</tt>
      ***REMOVED*** option:
      ***REMOVED***
      ***REMOVED***   class Photo < ActiveRecord::Base
      ***REMOVED***     has_attachment :storage => :s3, :path_prefix => 'my/custom/path'
      ***REMOVED***   end
      ***REMOVED***
      ***REMOVED*** Which would result in URLs like <tt>http(s)://:server/:bucket_name/my/custom/path/:id/:filename.</tt>
      ***REMOVED***
      ***REMOVED*** === Using different bucket names on different models
      ***REMOVED***
      ***REMOVED*** By default the bucket name that the file will be stored to is the one specified by the
      ***REMOVED*** <tt>:bucket_name</tt> key in the amazon_s3.yml file.  You can use the <tt>:bucket_key</tt> option
      ***REMOVED*** to overide this behavior on a per model basis.  For instance if you want a bucket that will hold
      ***REMOVED*** only Photos you can do this:
      ***REMOVED***
      ***REMOVED***   class Photo < ActiveRecord::Base
      ***REMOVED***     has_attachment :storage => :s3, :bucket_key => :photo_bucket_name
      ***REMOVED***   end
      ***REMOVED***
      ***REMOVED*** And then your amazon_s3.yml file needs to look like this.
      ***REMOVED***
      ***REMOVED***   ***REMOVED***
      ***REMOVED***     bucket_name: appname_development
      ***REMOVED***     access_key_id: <your key>
      ***REMOVED***     secret_access_key: <your key>
      ***REMOVED***
      ***REMOVED***   ***REMOVED***
      ***REMOVED***     bucket_name: appname_test
      ***REMOVED***     access_key_id: <your key>
      ***REMOVED***     secret_access_key: <your key>
      ***REMOVED***
      ***REMOVED***   ***REMOVED***
      ***REMOVED***     bucket_name: appname
      ***REMOVED***     photo_bucket_name: appname_photos
      ***REMOVED***     access_key_id: <your key>
      ***REMOVED***     secret_access_key: <your key>
      ***REMOVED***
      ***REMOVED***  If the bucket_key you specify is not there in a certain environment then attachment_fu will
      ***REMOVED***  default to the <tt>bucket_name</tt> key.  This way you only have to create special buckets
      ***REMOVED***  this can be helpful if you only need special buckets in certain environments.
      ***REMOVED***
      ***REMOVED*** === Permissions
      ***REMOVED***
      ***REMOVED*** By default, files are stored on S3 with public access permissions. You can customize this using
      ***REMOVED*** the <tt>:s3_access</tt> option to <tt>has_attachment</tt>. Available values are
      ***REMOVED*** <tt>:private</tt>, <tt>:public_read_write</tt>, and <tt>:authenticated_read</tt>.
      ***REMOVED***
      ***REMOVED*** === Other options
      ***REMOVED***
      ***REMOVED*** Of course, all the usual configuration options apply, such as content_type and thumbnails:
      ***REMOVED***
      ***REMOVED***   class Photo < ActiveRecord::Base
      ***REMOVED***     has_attachment :storage => :s3, :content_type => ['application/pdf', :image], :resize_to => 'x50'
      ***REMOVED***     has_attachment :storage => :s3, :thumbnails => { :thumb => [50, 50], :geometry => 'x50' }
      ***REMOVED***   end
      ***REMOVED***
      ***REMOVED*** === Accessing S3 URLs
      ***REMOVED***
      ***REMOVED*** You can get an object's URL using the s3_url accessor. For example, assuming that for your postcard app
      ***REMOVED*** you had a bucket name like 'postcard_world_development', and an attachment model called Photo:
      ***REMOVED***
      ***REMOVED***   @postcard.s3_url ***REMOVED*** => http(s)://s3.amazonaws.com/postcard_world_development/photos/1/mexico.jpg
      ***REMOVED***
      ***REMOVED*** The resulting url is in the form: http(s)://:server/:bucket_name/:table_name/:id/:file.
      ***REMOVED*** The optional thumbnail argument will output the thumbnail's filename (if any).
      ***REMOVED***
      ***REMOVED*** Additionally, you can get an object's base path relative to the bucket root using
      ***REMOVED*** <tt>base_path</tt>:
      ***REMOVED***
      ***REMOVED***   @photo.file_base_path ***REMOVED*** => photos/1
      ***REMOVED***
      ***REMOVED*** And the full path (including the filename) using <tt>full_filename</tt>:
      ***REMOVED***
      ***REMOVED***   @photo.full_filename ***REMOVED*** => photos/
      ***REMOVED***
      ***REMOVED*** Niether <tt>base_path</tt> or <tt>full_filename</tt> include the bucket name as part of the path.
      ***REMOVED*** You can retrieve the bucket name using the <tt>bucket_name</tt> method.
      ***REMOVED*** 
      ***REMOVED*** === Accessing CloudFront URLs
      ***REMOVED*** 
      ***REMOVED*** You can get an object's CloudFront URL using the cloudfront_url accessor.  Using the example from above:
      ***REMOVED*** @postcard.cloudfront_url ***REMOVED*** => http://XXXX.cloudfront.net/photos/1/mexico.jpg
      ***REMOVED***
      ***REMOVED*** The resulting url is in the form: http://:distribution_domain/:table_name/:id/:file
      ***REMOVED***
      ***REMOVED*** If you set :cloudfront to true in your model, the public_filename will be the CloudFront
      ***REMOVED*** URL, not the S3 URL.
      module S3Backend
        class RequiredLibraryNotFoundError < StandardError; end
        class ConfigFileNotFoundError < StandardError; end

        def self.included(base) ***REMOVED***:nodoc:
          mattr_reader :bucket_name, :s3_config

          begin
            require 'aws/s3'
            include AWS::S3
          rescue LoadError
            raise RequiredLibraryNotFoundError.new('AWS::S3 could not be loaded')
          end

          begin
            @@s3_config_path = base.attachment_options[:s3_config_path] || (Rails.root + '/config/amazon_s3.yml')
            @@s3_config = @@s3_config = YAML.load(ERB.new(File.read(@@s3_config_path)).result)[RAILS_ENV].symbolize_keys
          ***REMOVED***rescue
          ***REMOVED***  raise ConfigFileNotFoundError.new('File %s not found' % @@s3_config_path)
          end

          bucket_key = base.attachment_options[:bucket_key]

          if bucket_key and s3_config[bucket_key.to_sym]
            eval_string = "def bucket_name()\n  \"***REMOVED***{s3_config[bucket_key.to_sym]}\"\nend"
          else
            eval_string = "def bucket_name()\n  \"***REMOVED***{s3_config[:bucket_name]}\"\nend"
          end
          base.class_eval(eval_string, __FILE__, __LINE__)

          Base.establish_connection!(s3_config.slice(:access_key_id, :secret_access_key, :server, :port, :use_ssl, :persistent, :proxy))

          ***REMOVED*** Bucket.create(@@bucket_name)

          base.before_update :rename_file
        end

        def self.protocol
          @protocol ||= s3_config[:use_ssl] ? 'https://' : 'http://'
        end

        def self.hostname
          @hostname ||= s3_config[:server] || AWS::S3::DEFAULT_HOST
        end

        def self.port_string
          @port_string ||= (s3_config[:port].nil? || s3_config[:port] == (s3_config[:use_ssl] ? 443 : 80)) ? '' : ":***REMOVED***{s3_config[:port]}"
        end
        
        def self.distribution_domain
          @distribution_domain = s3_config[:distribution_domain]
        end

        module ClassMethods
          def s3_protocol
            Technoweenie::AttachmentFu::Backends::S3Backend.protocol
          end

          def s3_hostname
            Technoweenie::AttachmentFu::Backends::S3Backend.hostname
          end

          def s3_port_string
            Technoweenie::AttachmentFu::Backends::S3Backend.port_string
          end
          
          def cloudfront_distribution_domain
            Technoweenie::AttachmentFu::Backends::S3Backend.distribution_domain
          end
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

        ***REMOVED*** The pseudo hierarchy containing the file relative to the bucket name
        ***REMOVED*** Example: <tt>:table_name/:id</tt>
        def base_path
          File.join(attachment_options[:path_prefix], attachment_path_id)
        end

        ***REMOVED*** The full path to the file relative to the bucket name
        ***REMOVED*** Example: <tt>:table_name/:id/:filename</tt>
        def full_filename(thumbnail = nil)
          File.join(base_path, thumbnail_name_for(thumbnail))
        end

        ***REMOVED*** All public objects are accessible via a GET request to the S3 servers. You can generate a
        ***REMOVED*** url for an object using the s3_url method.
        ***REMOVED***
        ***REMOVED***   @photo.s3_url
        ***REMOVED***
        ***REMOVED*** The resulting url is in the form: <tt>http(s)://:server/:bucket_name/:table_name/:id/:file</tt> where
        ***REMOVED*** the <tt>:server</tt> variable defaults to <tt>AWS::S3 URL::DEFAULT_HOST</tt> (s3.amazonaws.com) and can be
        ***REMOVED*** set using the configuration parameters in <tt>Rails.root/config/amazon_s3.yml</tt>.
        ***REMOVED***
        ***REMOVED*** The optional thumbnail argument will output the thumbnail's filename (if any).
        def s3_url(thumbnail = nil)
          File.join(s3_protocol + s3_hostname + s3_port_string, bucket_name, full_filename(thumbnail))
        end
        
        ***REMOVED*** All public objects are accessible via a GET request to CloudFront. You can generate a
        ***REMOVED*** url for an object using the cloudfront_url method.
        ***REMOVED***
        ***REMOVED***   @photo.cloudfront_url
        ***REMOVED***
        ***REMOVED*** The resulting url is in the form: <tt>http://:distribution_domain/:table_name/:id/:file</tt> using
        ***REMOVED*** the <tt>:distribution_domain</tt> variable set in the configuration parameters in <tt>Rails.root/config/amazon_s3.yml</tt>.
        ***REMOVED***
        ***REMOVED*** The optional thumbnail argument will output the thumbnail's filename (if any).
        def cloudfront_url(thumbnail = nil)
          "http://" + cloudfront_distribution_domain + "/" + full_filename(thumbnail)
        end
        
        def public_filename(*args)
          if attachment_options[:cloudfront]
            cloudfront_url(args)
          else
            s3_url(args)
          end
        end

        ***REMOVED*** All private objects are accessible via an authenticated GET request to the S3 servers. You can generate an
        ***REMOVED*** authenticated url for an object like this:
        ***REMOVED***
        ***REMOVED***   @photo.authenticated_s3_url
        ***REMOVED***
        ***REMOVED*** By default authenticated urls expire 5 minutes after they were generated.
        ***REMOVED***
        ***REMOVED*** Expiration options can be specified either with an absolute time using the <tt>:expires</tt> option,
        ***REMOVED*** or with a number of seconds relative to now with the <tt>:expires_in</tt> option:
        ***REMOVED***
        ***REMOVED***   ***REMOVED*** Absolute expiration date (October 13th, 2025)
        ***REMOVED***   @photo.authenticated_s3_url(:expires => Time.mktime(2025,10,13).to_i)
        ***REMOVED***
        ***REMOVED***   ***REMOVED*** Expiration in five hours from now
        ***REMOVED***   @photo.authenticated_s3_url(:expires_in => 5.hours)
        ***REMOVED***
        ***REMOVED*** You can specify whether the url should go over SSL with the <tt>:use_ssl</tt> option.
        ***REMOVED*** By default, the ssl settings for the current connection will be used:
        ***REMOVED***
        ***REMOVED***   @photo.authenticated_s3_url(:use_ssl => true)
        ***REMOVED***
        ***REMOVED*** Finally, the optional thumbnail argument will output the thumbnail's filename (if any):
        ***REMOVED***
        ***REMOVED***   @photo.authenticated_s3_url('thumbnail', :expires_in => 5.hours, :use_ssl => true)
        def authenticated_s3_url(*args)
          options   = args.extract_options!
          options[:expires_in] = options[:expires_in].to_i if options[:expires_in]
          thumbnail = args.shift
          S3Object.url_for(full_filename(thumbnail), bucket_name, options)
        end

        def create_temp_file
          write_to_temp_file current_data
        end

        def current_data
          S3Object.value full_filename, bucket_name
        end

        def s3_protocol
          Technoweenie::AttachmentFu::Backends::S3Backend.protocol
        end

        def s3_hostname
          Technoweenie::AttachmentFu::Backends::S3Backend.hostname
        end

        def s3_port_string
          Technoweenie::AttachmentFu::Backends::S3Backend.port_string
        end
        
        def cloudfront_distribution_domain
          Technoweenie::AttachmentFu::Backends::S3Backend.distribution_domain
        end

        protected
          ***REMOVED*** Called in the after_destroy callback
          def destroy_file
            S3Object.delete full_filename, bucket_name
          end

          def rename_file
            return unless @old_filename && @old_filename != filename

            old_full_filename = File.join(base_path, @old_filename)

            S3Object.rename(
              old_full_filename,
              full_filename,
              bucket_name,
              :access => attachment_options[:s3_access]
            )

            @old_filename = nil
            true
          end

          def save_to_storage
            if save_attachment?
              S3Object.store(
                full_filename,
                (temp_path ? File.open(temp_path) : temp_data),
                bucket_name,
                :content_type => content_type,
                :access => attachment_options[:s3_access]
              )
            end

            @old_filename = nil
            true
          end
      end
    end
  end
end
