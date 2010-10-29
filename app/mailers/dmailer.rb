class Dmailer < ActionMailer::Base
  default :from => "WorldBlender Founders <founders@worldblender.com"

  def send_text(message,user_id,title)
    user = User.find(user_id)
    @message = message
    recipients "#{user.name} <#{user.email}>"
    from "WorldBlender <customer-service@worldblender.com>"
    subject title
    sent_on Time.now
    body
  end
end
