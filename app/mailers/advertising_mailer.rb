class AdvertisingMailer < ApplicationMailer
  def advertising_email(body,subject,recipient)
    @body = body
    @recipient = recipient
    mail(:to => @recipient.email, :subject => subject)
  end
end
