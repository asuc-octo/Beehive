# Configure the Action Mailer.
$smtp_username ||= ENV['SMTP_USERNAME']
$smtp_password ||= ENV['SMTP_PASSWORD']

unless $smtp_username and $smtp_password
    $stderr.puts "WARNING: SMTP credentials have not been set as env vars! See #{__FILE__}"
end

ResearchMatch::Application.configure do
  ActionMailer::Base.smtp_settings = {
    :address              => "smtp.sendgrid.net",
    :port                 => 587,
    :user_name            => $smtp_username,
    :password             => $smtp_password,
    :authentication       => :plain,
    :enable_starttls_auto => true
  }
end
