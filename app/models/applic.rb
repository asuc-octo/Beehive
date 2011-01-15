class Applic < ActiveRecord::Base
  belongs_to :job
  belongs_to :user
  belongs_to :resume,      :class_name => 'Document', :conditions => {:document_type => Document::Types::Resume}
  belongs_to :transcript,  :class_name => 'Document', :conditions => {:document_type => Document::Types::Transcript}
  
  validates_presence_of   :message
  validates_length_of     :message, :minimum => 1, :too_short => "Please enter a message to the faculty sponsor of this job." 

  ***REMOVED*** Uniq'd list of emails of all [sponsors, poster] who want to receive notifications for this applic
  def subscriber_emails
    ***REMOVED*** TODO: for now, just email the poster
    job.user.email

    ***REMOVED*** TODO: add preferences to these people
    ***REMOVED*** TODO: condense faculty -> users
***REMOVED******REMOVED***    emales = job.faculties.collect(&:email)
***REMOVED******REMOVED***    emales << user.email
***REMOVED******REMOVED***    emales
  end

end
