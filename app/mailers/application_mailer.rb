class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("COURT_USERNAME")
  layout "mailer"
end
