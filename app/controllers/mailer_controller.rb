class MailerController < ApplicationController
  def mail_path
     body = params[:body]
     subject = params[:subject]
     AdvertisingMailer.execute(body,subject).deliver
   end
end
