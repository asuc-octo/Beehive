
# The mailer for feedback
class FeedbackMailer < ApplicationMailer

  def send_feedback(sender, subject_line, body_text)
    #recipients  'octo.beehive@asuc.org'
    #reply_to    sender
    #from        sender
    #subject     "[Beehive Feedback] #{subject_line}"
    #body        body_text
    mail(:to => 'octo.beehive@asuc.org',
         :from => sender,
         :reply_to => sender,
         :subject => "Beehive Feedback #{subject_line}",
         :body => body_text)
  end
end
