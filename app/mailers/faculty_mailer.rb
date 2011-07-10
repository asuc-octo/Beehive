class FacultyMailer < ActionMailer::Base
   @@rm_contact = "UC Berkeley ResearchMatch <ucbresearchmatch@gmail.com>"
   layout 'faculty_mailer'

   ***REMOVED*** HACK HACK HACK HACK HACK HACK
   ***REMOVED*** The 2 hours i spent figuring out how to work around the bug in ActionMailer
   ***REMOVED*** would probably have been better spent upgrading to Rails 3, where the bug
   ***REMOVED*** was fixed. :(
   ***REMOVED***
   ***REMOVED*** See http://apidock.com/rails/ActionMailer/Base/render_message
   class TextPlain
     def initialize(template)         ***REMOVED*** render_message wants some object...
       @template = template
     end
     def to_s                         ***REMOVED*** that represents a filename...
       @template
     end
     def content_type                 ***REMOVED*** and also responds to content_type
       'text/plain'
     end
   end

   def self.format_recipient(name, email)
     "\"***REMOVED***{name}\" <***REMOVED***{email}>"
   end

   def faculty_confirmer(email, name, job)***REMOVED***job_id, job_title, job_description, activation_code)
     recipients FacultyMailer.format_recipient(name, email)
     from       "UC Berkeley ResearchMatch <ucbresearchmatch@gmail.com>"
     subject    "ResearchMatch Listing Confirmation"
     body       :email => email, :name => name, :job => job 
   end

   def applic_notification(applic)
     recipients FacultyMailer.format_recipient(applic.job.user.name, applic.job.user.email)
     from       @@rm_contact
     subject    "[ResearchMatch] Application Notification - ***REMOVED***{applic.job.title[0..25]}"
     body       :applic => applic
     content_type 'multipart/alternative'

     ***REMOVED*** Implicit templates aren't used with attachments

     part 'text/plain' do |p|
       p.body = render_message(TextPlain.new('applic_notification.text.plain'), :applic=>applic)
       p.transfer_encoding = 'base64'
     end
     part :content_type => 'text/html', :body => render_message('applic_notification.text.html', :applic=>applic)

     [:resume, :transcript].each do |doctype|
       next unless doc = applic.send(doctype)
       attachment doc.content_type do |a|
         a.body     = File.read(doc.public_filename)
         a.filename = "***REMOVED***{doctype.to_s.capitalize!}.***REMOVED***{doc.public_filename.split('.').last}"
       end
     end
   end
end
