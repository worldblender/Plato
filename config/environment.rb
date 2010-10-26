# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Plato::Application.initialize!

ActionMailer::Base.smtp_settings = {
  :address        => "smtp.sendgrid.net",
  :port           => "25",
  :authentication => :plain,
  :user_name      => "jeff@worldblender.com",
  :password       => "DoomBrain",
  :domain         => "worldblender.com"
}
