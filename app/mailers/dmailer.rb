class Dmailer < ActionMailer::Base
  default :from => "WorldBlender Founders <founders@worldblender.com"

  def send_text(message,user)
    @message = message
    recipients "#{user.name} <#{user.email}>"
    from "WorldBlender Founders <founders@worldblender.com"
    subject "[plato] New game notification"
    sent_on Time.now
    body :user => user
  end
end
