require 'will_paginate/core_ext'

module WillPaginate
  ***REMOVED*** = Will Paginate view helpers
  ***REMOVED***
  ***REMOVED*** The main view helper, ***REMOVED***will_paginate, renders
  ***REMOVED*** pagination links for the given collection. The helper itself is lightweight
  ***REMOVED*** and serves only as a wrapper around LinkRenderer instantiation; the
  ***REMOVED*** renderer then does all the hard work of generating the HTML.
  ***REMOVED*** 
  ***REMOVED*** == Global options for helpers
  ***REMOVED***
  ***REMOVED*** Options for pagination helpers are optional and get their default values from the
  ***REMOVED*** <tt>WillPaginate::ViewHelpers.pagination_options</tt> hash. You can write to this hash to
  ***REMOVED*** override default options on the global level:
  ***REMOVED***
  ***REMOVED***   WillPaginate::ViewHelpers.pagination_options[:previous_label] = 'Previous page'
  ***REMOVED***
  ***REMOVED*** By putting this into "config/initializers/will_paginate.rb" (or simply environment.rb in
  ***REMOVED*** older versions of Rails) you can easily translate link texts to previous
  ***REMOVED*** and next pages, as well as override some other defaults to your liking.
  module ViewHelpers
    ***REMOVED*** default options that can be overridden on the global level
    @@pagination_options = {
      :class          => 'pagination',
      :previous_label => '&laquo; Previous',
      :next_label     => 'Next &raquo;',
      :inner_window   => 4, ***REMOVED*** links around the current page
      :outer_window   => 1, ***REMOVED*** links around beginning and end
      :separator      => ' ', ***REMOVED*** single space is friendly to spiders and non-graphic browsers
      :param_name     => :page,
      :params         => nil,
      :renderer       => 'WillPaginate::LinkRenderer',
      :page_links     => true,
      :container      => true
    }
    mattr_reader :pagination_options

    ***REMOVED*** Renders Digg/Flickr-style pagination for a WillPaginate::Collection
    ***REMOVED*** object. Nil is returned if there is only one page in total; no point in
    ***REMOVED*** rendering the pagination in that case...
    ***REMOVED*** 
    ***REMOVED*** ==== Options
    ***REMOVED*** Display options:
    ***REMOVED*** * <tt>:previous_label</tt> -- default: "« Previous" (this parameter is called <tt>:prev_label</tt> in versions <b>2.3.2</b> and older!)
    ***REMOVED*** * <tt>:next_label</tt> -- default: "Next »"
    ***REMOVED*** * <tt>:page_links</tt> -- when false, only previous/next links are rendered (default: true)
    ***REMOVED*** * <tt>:inner_window</tt> -- how many links are shown around the current page (default: 4)
    ***REMOVED*** * <tt>:outer_window</tt> -- how many links are around the first and the last page (default: 1)
    ***REMOVED*** * <tt>:separator</tt> -- string separator for page HTML elements (default: single space)
    ***REMOVED*** 
    ***REMOVED*** HTML options:
    ***REMOVED*** * <tt>:class</tt> -- CSS class name for the generated DIV (default: "pagination")
    ***REMOVED*** * <tt>:container</tt> -- toggles rendering of the DIV container for pagination links, set to
    ***REMOVED***   false only when you are rendering your own pagination markup (default: true)
    ***REMOVED*** * <tt>:id</tt> -- HTML ID for the container (default: nil). Pass +true+ to have the ID
    ***REMOVED***   automatically generated from the class name of objects in collection: for example, paginating
    ***REMOVED***   ArticleComment models would yield an ID of "article_comments_pagination".
    ***REMOVED***
    ***REMOVED*** Advanced options:
    ***REMOVED*** * <tt>:param_name</tt> -- parameter name for page number in URLs (default: <tt>:page</tt>)
    ***REMOVED*** * <tt>:params</tt> -- additional parameters when generating pagination links
    ***REMOVED***   (eg. <tt>:controller => "foo", :action => nil</tt>)
    ***REMOVED*** * <tt>:renderer</tt> -- class name, class or instance of a link renderer (default:
    ***REMOVED***   <tt>WillPaginate::LinkRenderer</tt>)
    ***REMOVED***
    ***REMOVED*** All options not recognized by will_paginate will become HTML attributes on the container
    ***REMOVED*** element for pagination links (the DIV). For example:
    ***REMOVED*** 
    ***REMOVED***   <%= will_paginate @posts, :style => 'font-size: small' %>
    ***REMOVED***
    ***REMOVED*** ... will result in:
    ***REMOVED***
    ***REMOVED***   <div class="pagination" style="font-size: small"> ... </div>
    ***REMOVED***
    ***REMOVED*** ==== Using the helper without arguments
    ***REMOVED*** If the helper is called without passing in the collection object, it will
    ***REMOVED*** try to read from the instance variable inferred by the controller name.
    ***REMOVED*** For example, calling +will_paginate+ while the current controller is
    ***REMOVED*** PostsController will result in trying to read from the <tt>@posts</tt>
    ***REMOVED*** variable. Example:
    ***REMOVED***
    ***REMOVED***   <%= will_paginate :id => true %>
    ***REMOVED***
    ***REMOVED*** ... will result in <tt>@post</tt> collection getting paginated:
    ***REMOVED***
    ***REMOVED***   <div class="pagination" id="posts_pagination"> ... </div>
    ***REMOVED***
    def will_paginate(collection = nil, options = {})
      options, collection = collection, nil if collection.is_a? Hash
      unless collection or !controller
        collection_name = "@***REMOVED***{controller.controller_name}"
        collection = instance_variable_get(collection_name)
        raise ArgumentError, "The ***REMOVED***{collection_name} variable appears to be empty. Did you " +
          "forget to pass the collection object for will_paginate?" unless collection
      end
      ***REMOVED*** early exit if there is nothing to render
      return nil unless WillPaginate::ViewHelpers.total_pages_for_collection(collection) > 1
      
      options = options.symbolize_keys.reverse_merge WillPaginate::ViewHelpers.pagination_options
      if options[:prev_label]
        WillPaginate::Deprecation::warn(":prev_label view parameter is now :previous_label; the old name has been deprecated", caller)
        options[:previous_label] = options.delete(:prev_label)
      end
      
      ***REMOVED*** get the renderer instance
      renderer = case options[:renderer]
      when String
        options[:renderer].to_s.constantize.new
      when Class
        options[:renderer].new
      else
        options[:renderer]
      end
      ***REMOVED*** render HTML for pagination
      renderer.prepare collection, options, self
      renderer.to_html
    end
    
    ***REMOVED*** Wrapper for rendering pagination links at both top and bottom of a block
    ***REMOVED*** of content.
    ***REMOVED*** 
    ***REMOVED***   <% paginated_section @posts do %>
    ***REMOVED***     <ol id="posts">
    ***REMOVED***       <% for post in @posts %>
    ***REMOVED***         <li> ... </li>
    ***REMOVED***       <% end %>
    ***REMOVED***     </ol>
    ***REMOVED***   <% end %>
    ***REMOVED***
    ***REMOVED*** will result in:
    ***REMOVED***
    ***REMOVED***   <div class="pagination"> ... </div>
    ***REMOVED***   <ol id="posts">
    ***REMOVED***     ...
    ***REMOVED***   </ol>
    ***REMOVED***   <div class="pagination"> ... </div>
    ***REMOVED***
    ***REMOVED*** Arguments are passed to a <tt>will_paginate</tt> call, so the same options
    ***REMOVED*** apply. Don't use the <tt>:id</tt> option; otherwise you'll finish with two
    ***REMOVED*** blocks of pagination links sharing the same ID (which is invalid HTML).
    def paginated_section(*args, &block)
      pagination = will_paginate(*args).to_s
      
      unless ActionView::Base.respond_to? :erb_variable
        concat pagination
        yield
        concat pagination
      else
        content = pagination + capture(&block) + pagination
        concat(content, block.binding)
      end
    end

    ***REMOVED*** Renders a helpful message with numbers of displayed vs. total entries.
    ***REMOVED*** You can use this as a blueprint for your own, similar helpers.
    ***REMOVED***
    ***REMOVED***   <%= page_entries_info @posts %>
    ***REMOVED***   ***REMOVED***-> Displaying posts 6 - 10 of 26 in total
    ***REMOVED***
    ***REMOVED*** By default, the message will use the humanized class name of objects
    ***REMOVED*** in collection: for instance, "project types" for ProjectType models.
    ***REMOVED*** Override this with the <tt>:entry_name</tt> parameter:
    ***REMOVED***
    ***REMOVED***   <%= page_entries_info @posts, :entry_name => 'item' %>
    ***REMOVED***   ***REMOVED***-> Displaying items 6 - 10 of 26 in total
    def page_entries_info(collection, options = {})
      entry_name = options[:entry_name] ||
        (collection.empty?? 'entry' : collection.first.class.name.underscore.sub('_', ' '))
      
      if collection.total_pages < 2
        case collection.size
        when 0; "No ***REMOVED***{entry_name.pluralize} found"
        when 1; "Displaying <b>1</b> ***REMOVED***{entry_name}"
        else;   "Displaying <b>all ***REMOVED***{collection.size}</b> ***REMOVED***{entry_name.pluralize}"
        end
      else
        %{Displaying ***REMOVED***{entry_name.pluralize} <b>%d&nbsp;-&nbsp;%d</b> of <b>%d</b> in total} % [
          collection.offset + 1,
          collection.offset + collection.length,
          collection.total_entries
        ]
      end
    end

    def self.total_pages_for_collection(collection) ***REMOVED***:nodoc:
      if collection.respond_to?('page_count') and !collection.respond_to?('total_pages')
        WillPaginate::Deprecation.warn %{
          You are using a paginated collection of class ***REMOVED***{collection.class.name}
          which conforms to the old API of WillPaginate::Collection by using
          `page_count`, while the current method name is `total_pages`. Please
          upgrade yours or 3rd-party code that provides the paginated collection}, caller
        class << collection
          def total_pages; page_count; end
        end
      end
      collection.total_pages
    end
  end

  ***REMOVED*** This class does the heavy lifting of actually building the pagination
  ***REMOVED*** links. It is used by the <tt>will_paginate</tt> helper internally.
  class LinkRenderer

    ***REMOVED*** The gap in page links is represented by:
    ***REMOVED***
    ***REMOVED***   <span class="gap">&hellip;</span>
    attr_accessor :gap_marker
    
    def initialize
      @gap_marker = '<span class="gap">&hellip;</span>'
    end
    
    ***REMOVED*** * +collection+ is a WillPaginate::Collection instance or any other object
    ***REMOVED***   that conforms to that API
    ***REMOVED*** * +options+ are forwarded from +will_paginate+ view helper
    ***REMOVED*** * +template+ is the reference to the template being rendered
    def prepare(collection, options, template)
      @collection = collection
      @options    = options
      @template   = template

      ***REMOVED*** reset values in case we're re-using this instance
      @total_pages = @param_name = @url_string = nil
    end

    ***REMOVED*** Process it! This method returns the complete HTML string which contains
    ***REMOVED*** pagination links. Feel free to subclass LinkRenderer and change this
    ***REMOVED*** method as you see fit.
    def to_html
      links = @options[:page_links] ? windowed_links : []
      ***REMOVED*** previous/next buttons
      links.unshift page_link_or_span(@collection.previous_page, 'disabled prev_page', @options[:previous_label])
      links.push    page_link_or_span(@collection.next_page,     'disabled next_page', @options[:next_label])
      
      html = links.join(@options[:separator])
      @options[:container] ? @template.content_tag(:div, html, html_attributes) : html
    end

    ***REMOVED*** Returns the subset of +options+ this instance was initialized with that
    ***REMOVED*** represent HTML attributes for the container element of pagination links.
    def html_attributes
      return @html_attributes if @html_attributes
      @html_attributes = @options.except *(WillPaginate::ViewHelpers.pagination_options.keys - [:class])
      ***REMOVED*** pagination of Post models will have the ID of "posts_pagination"
      if @options[:container] and @options[:id] === true
        @html_attributes[:id] = @collection.first.class.name.underscore.pluralize + '_pagination'
      end
      @html_attributes
    end
    
  protected

    ***REMOVED*** Collects link items for visible page numbers.
    def windowed_links
      prev = nil

      visible_page_numbers.inject [] do |links, n|
        ***REMOVED*** detect gaps:
        links << gap_marker if prev and n > prev + 1
        links << page_link_or_span(n, 'current')
        prev = n
        links
      end
    end

    ***REMOVED*** Calculates visible page numbers using the <tt>:inner_window</tt> and
    ***REMOVED*** <tt>:outer_window</tt> options.
    def visible_page_numbers
      inner_window, outer_window = @options[:inner_window].to_i, @options[:outer_window].to_i
      window_from = current_page - inner_window
      window_to = current_page + inner_window
      
      ***REMOVED*** adjust lower or upper limit if other is out of bounds
      if window_to > total_pages
        window_from -= window_to - total_pages
        window_to = total_pages
      end
      if window_from < 1
        window_to += 1 - window_from
        window_from = 1
        window_to = total_pages if window_to > total_pages
      end
      
      visible   = (1..total_pages).to_a
      left_gap  = (2 + outer_window)...window_from
      right_gap = (window_to + 1)...(total_pages - outer_window)
      visible  -= left_gap.to_a  if left_gap.last - left_gap.first > 1
      visible  -= right_gap.to_a if right_gap.last - right_gap.first > 1

      visible
    end
    
    def page_link_or_span(page, span_class, text = nil)
      text ||= page.to_s
      
      if page and page != current_page
        classnames = span_class && span_class.index(' ') && span_class.split(' ', 2).last
        page_link page, text, :rel => rel_value(page), :class => classnames
      else
        page_span page, text, :class => span_class
      end
    end

    def page_link(page, text, attributes = {})
      @template.link_to text, url_for(page), attributes
    end

    def page_span(page, text, attributes = {})
      @template.content_tag :span, text, attributes
    end

    ***REMOVED*** Returns URL params for +page_link_or_span+, taking the current GET params
    ***REMOVED*** and <tt>:params</tt> option into account.
    def url_for(page)
      page_one = page == 1
      unless @url_string and !page_one
        @url_params = {}
        ***REMOVED*** page links should preserve GET parameters
        stringified_merge @url_params, @template.params if @template.request.get?
        stringified_merge @url_params, @options[:params] if @options[:params]
        
        if complex = param_name.index(/[^\w-]/)
          page_param = parse_query_parameters("***REMOVED***{param_name}=***REMOVED***{page}")
          
          stringified_merge @url_params, page_param
        else
          @url_params[param_name] = page_one ? 1 : 2
        end

        url = @template.url_for(@url_params)
        return url if page_one
        
        if complex
          @url_string = url.sub(%r!((?:\?|&amp;)***REMOVED***{CGI.escape param_name}=)***REMOVED***{page}!, "\\1\0")
          return url
        else
          @url_string = url
          @url_params[param_name] = 3
          @template.url_for(@url_params).split(//).each_with_index do |char, i|
            if char == '3' and url[i, 1] == '2'
              @url_string[i] = "\0"
              break
            end
          end
        end
      end
      ***REMOVED*** finally!
      @url_string.sub "\0", page.to_s
    end

  private

    def rel_value(page)
      case page
      when @collection.previous_page; 'prev' + (page == 1 ? ' start' : '')
      when @collection.next_page; 'next'
      when 1; 'start'
      end
    end

    def current_page
      @collection.current_page
    end

    def total_pages
      @total_pages ||= WillPaginate::ViewHelpers.total_pages_for_collection(@collection)
    end

    def param_name
      @param_name ||= @options[:param_name].to_s
    end

    ***REMOVED*** Recursively merge into target hash by using stringified keys from the other one
    def stringified_merge(target, other)
      other.each do |key, value|
        key = key.to_s ***REMOVED*** this line is what it's all about!
        existing = target[key]

        if value.is_a?(Hash) and (existing.is_a?(Hash) or existing.nil?)
          stringified_merge(existing || (target[key] = {}), value)
        else
          target[key] = value
        end
      end
    end

    def parse_query_parameters(params)
      if defined? Rack::Utils
        ***REMOVED*** For Rails > 2.3
        Rack::Utils.parse_nested_query(params)
      elsif defined?(ActionController::AbstractRequest)
        ActionController::AbstractRequest.parse_query_parameters(params)
      elsif defined?(ActionController::UrlEncodedPairParser)
        ***REMOVED*** For Rails > 2.2
        ActionController::UrlEncodedPairParser.parse_query_parameters(params)
      elsif defined?(CGIMethods)
        CGIMethods.parse_query_parameters(params)
      else
        raise "unsupported ActionPack version"
      end
    end
  end
end
