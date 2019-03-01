class AdvertisingMailer < ApplicationMailer
  def execute(body,subject,recipient)
    # emails = User.all.collect(&:email).select{|email| email.present?}
    @body = body
    @recipient = recipient
    mail(:to => @recipient.email, :subject => subject)
  end
end
