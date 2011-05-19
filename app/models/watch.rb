class Watch < ActiveRecord::Base

  ***REMOVED*** === List of columns ===
  ***REMOVED***   id         : integer 
  ***REMOVED***   job_id     : integer 
  ***REMOVED***   user_id    : integer 
  ***REMOVED***   created_at : datetime 
  ***REMOVED***   updated_at : datetime 
  ***REMOVED*** =======================

  belongs_to :job
  belongs_to :user
  
  def unread?
    self.updated_at < job.updated_at
  end
  
  def mark_read
    self.updated_at = Time.now
    self.save
  end
  
end
