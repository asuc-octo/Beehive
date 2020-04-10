namespace :mailer do
  desc "Weekly Mailer"
  task send_email: :environment do
    User.where(:user_type => 0, last_login_at: (Time.current - 1.year)..Time.current).each do |user|
      PostingMailer.new_listings("Please check out these recent listings on Beehive!", "New Research Opportunities on Beehive", user).deliver_now
    end
  end

end
