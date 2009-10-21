class Project < ActiveRecord::Base
  has_and_belongs_to_many :developers, :uniq => true
  
  has_many :topics
    ***REMOVED*** :finder_sql  => 'SELECT * FROM topics WHERE (topics.project_id = ***REMOVED***{id})',
    ***REMOVED*** :counter_sql => 'SELECT COUNT(*) FROM topics WHERE (topics.project_id = ***REMOVED***{id})'
  
  has_many :replies, :through => :topics do
    def find_recent(params = {})
      with_scope :find => { :conditions => ['replies.created_at > ?', 15.minutes.ago] } do
        find :all, params
      end
    end
  end
end
