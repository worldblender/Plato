class Dmailer < ActionMailer::Base
  default :from => "WorldBlender Founders <founders@worldblender.com"

  def send_text(message,user)
    recipients "#{user.name} <#{user.email}>"
    subject "[plato] New game notification"
    sent_on Time.now
    body message
  end
end
