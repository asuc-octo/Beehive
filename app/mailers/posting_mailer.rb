class PostingMailer < ApplicationMailer
  def three_day_expire_notice job
    @job = job
    mail(:to => @job.user.email, :subject => "Your Beehive job posting is about to expire").deliver
  end

  def long_time_no_update_notice email
    mail(:to => email, :subject => "Please update your Beehive job posting").deliver
  end

  def new_listings(body,subject,recipient)
    # emails = User.all.collect(&:email).select{|email| email.present?}
    @body = body
    @recipient = recipient
    @listing_1 = Job.order("created_at").last
    @listing_2 = Job.order("created_at").last(2).first
    mail(:to => @recipient.email, :subject => subject)
  end
end
