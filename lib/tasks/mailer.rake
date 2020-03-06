namespace :mailer do
  desc "TODO"
  task send_email: :environment do
    # emails = ["kgunadhi@berkeley.edu"]
    # emails.each do |email|
    PostingMailer.new_listings("body", "subject", User.find_by(email: "kgunadhi@berkeley.edu"))
    # end
  end

end
