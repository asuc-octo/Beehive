class AdvertisingMailer < ApplicationMailer
  def execute(body,subject)
    # emails = User.all.collect(&:email).select{|email| email.present?}
    @body = body
    emails = [ENV["test_email_1"], ENV["test_email_2"]]
    emails.each do |a|
      mail :to => a, :subject => subject
    end
  end
end
