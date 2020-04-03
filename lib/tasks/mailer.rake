namespace :mailer do
  desc "Weekly Mailer"
  task send_email: :environment do
    Users.each do |user|
      PostingMailer.new_listings("Please check out these recent listings on Beehive!", "New Research Opportunities on Beehive", user).deliver_now
    end
  end

end
