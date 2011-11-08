module AttribsHelper
 
  AttribTypes = [:category, :course, :proglang]


  ***REMOVED*** Returns a string representing the names for all
  ***REMOVED*** of this type of attrib, for this object (self).
  ***REMOVED*** e.g. "category" might yield: "signal processing, ai" 
  def attrib_names_for_type(attrib_type, add_spaces = false)
    attrib_names = ''
    self.send(attrib_type.to_s.downcase.pluralize).each do |attrib|
      attrib_names << attrib.name + ','
      if add_spaces then attrib_names << ' ' end
    end
    
    ***REMOVED*** lop off extra ',' or ', ' at the end
    if add_spaces
      return attrib_names[0..(attrib_names.length - 3)]
    else
      return attrib_names[0..(attrib_names.length - 2)]
    end
  end


  ***REMOVED*** Helper method invoked by JobsController's and UsersController's
  ***REMOVED*** update and create. Updates the attribs of the job with the
  ***REMOVED*** stuff in params. (NOTE: attrib_type is singular, e.g. "category")
  def update_attribs(params)
    
    ***REMOVED*** Attribs logic. Gets the attribs from the params and finds or 
    ***REMOVED*** creates them appropriately.

    AttribTypes.each do |attrib_type|
      attrib_array = self.send(attrib_type.to_s.downcase.pluralize)

      ***REMOVED*** Reset the attribs to empty []
      attrib_array.clear

      ***REMOVED*** What was typed into the box. May include commas and spaces.
      next unless params[attrib_type]
      raw_attrib_value = params[attrib_type][:name]
      
      ***REMOVED*** If left blank, we don't want to create "" attribs.
      if raw_attrib_value.present?
        raw_attrib_value.split(',').uniq.each do |val_before_fmt|
          
          ***REMOVED*** Avoid ", , , ," situations
          if val_before_fmt.present?
            
            ***REMOVED*** Remove leading/trailing whitespace
            val = val_before_fmt.strip
            
            ***REMOVED*** HACK: We want to remove spaces and use uppercase for courses only
            ***REMOVED*** and capitalize programming languages only.
            if attrib_type == :course
              val = val.upcase.gsub(/ /, '')
            elsif attrib_type == :proglang
              val = val.capitalize
            else
              val = val.downcase
            end
            
            ***REMOVED*** Find or create the attrib 
            the_attrib = attrib_type.to_s.capitalize.constantize.find_or_create_by_name(val)
            attrib_array << the_attrib unless attrib_array.include?(the_attrib)
          end
        end
      end

    end
    
  end

  ***REMOVED*** Helper method used by edit and show methods in UsersController and 
  ***REMOVED*** JobsController to prepare the params hash by putting in the attribs.
  def prepare_attribs_in_params(obj)
  
    ***REMOVED*** Attribs logic. Puts the attribs in the params so that 
    ***REMOVED*** the user's edit profile form displays existing attribs.
    AttribTypes.each do |attrib_type|
      params[attrib_type] = {}
      params[attrib_type][:name] = obj.attrib_names_for_type(attrib_type, true)
    end
  end

end
