# Preview all emails at http://localhost:3000/rails/mailers/advertising_mailer
class AdvertisingMailerPreview < ActionMailer::Preview
  def advertising_email
    AdvertisingMailer.advertising_email("body here", "Hello", User.find_by(email: "leon.ming@berkeley.edu"))
  end
end
