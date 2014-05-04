
***REMOVED*** The mailer for feedback
class FeedbackMailer < ActionMailer::Base
  
  def send_feedback(sender, subject_line, body_text)
    ***REMOVED***recipients  'beehive-support@lists.berkeley.edu'
    ***REMOVED***reply_to    sender
    ***REMOVED***from        sender
    ***REMOVED***subject     "[Beehive Feedback] ***REMOVED***{subject_line}"
    ***REMOVED***body        body_text
    mail(:to => 'beehive-support@lists.berkeley.edu',
         :from => sender,
         :reply_to => sender,
         :subject => "Beehive Feedback ***REMOVED***{subject_line}",
         :body => body_text) 
  end
end
