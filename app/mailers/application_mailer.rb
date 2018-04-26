class ApplicationMailer < ActionMailer::Base

  default from: ENV['SMTP_FROM'], reply_to: ENV['SMTP_REPLY_TO']
  layout 'mailer'
  helper ApplicationHelper

end