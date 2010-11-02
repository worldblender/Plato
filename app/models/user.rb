class User < ActiveRecord::Base
  require 'notifo'
  acts_as_mappable :default_units => :kms,
                   :default_formula => :sphere,
                   :distance_field_name => :distance,
                   :lat_column_name => :latitude,
                   :lng_column_name => :longitude

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :oauthable
  devise :database_authenticatable, :oauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :latitude, :longitude, :bomb_id, :deadtime

  def scoreChartScore
    score = 0
    if(self.top_score != nil)
      score = self.top_score
    end
    aScore = self.curScore(Time.now)
    if(aScore > score)
      score = aScore
    end
    return score
  end

  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    # Get the user email info from Facebook for sign up
    # You'll have to figure this part out from the json you get back
    data = ActiveSupport::JSON.decode(access_token.get('https://graph.facebook.com/me?'))
    if user = User.find_by_email(data["email"])
      user
    else
      # Create an user with a stub password.
      user = User.create!(:email => data["email"], :password => Devise.friendly_token)
      user.facebook_id = data['id']
      user.name = data['name']
      user.save
      user.resurrect
      user
    end
  end

  def curScore(curTime = Time.now)
    if self.hp != nil && self.hp > 0
      return curTime-self.createtime
    else
      return 0
    end
  end

  def photoUrl
    return "http://graph.facebook.com/" + self[:facebook_id] + "/picture"
  end

  def acceptText?
    return self.phone != nil
  end

  def acceptNotifo?
    return self.notifio_account != nil
  end

  def notify(textMessage,title = 'Game notification from ' + GAME_NAME)
    puts("called with " + textMessage + " as my data")
    if self.acceptText?
      # send a text message
      sendText(textMessage,self)
    else
      if self.acceptNotifo?
        sendNotifo(textMessage,self)
      else
        # send an email
        Dmailer.send_text(textMessage,self.id,title).deliver
      end
    end
  end

  def kill
    curTime = Time.now
    thisScore = curScore(curTime)
    if(self.top_score == nil || self.top_score < thisScore)
      self.top_score = thisScore
    end
    event(:type => 'die', :data => 'lat: ' + self.latitude.to_s + '; long: ' + self.longitude.to_s + '; id:' + self.id.to_s + ';');
    self.deadtime = curTime
    self.save
  end

  def hitWith(dmg)
    if (self.hp == nil)
      self.hp=USER_HITPOINTS
    end
    tempHp = self.hp-dmg
    if tempHp<=0
      self.kill
      tempHp= 0
    end
    self.hp = tempHp
    self.save
  end

  def resurrect
    self.hp = USER_HITPOINTS
    self.bomb_id = nil
    self.deadtime = nil
    self.createtime = DateTime.now
    event(:type => 'respawn', :data => 'lat: ' + self.latitude.to_s + '; long: ' + self.longitude.to_s + '; id:' + self.id.to_s + ';')
    self.save
  end

  def notifoSibscribe(notifo_object)
    if(recipient.notifo_configured == nil || recipient.notifo_configured == false)
      notifo_object.subscribe_user(recipient.notifo_account)
      recipient.notifo_configured = true
      recipient.save
    end
  end

  def sendNotifo(message, recipient)
    notifo = Notifo.new("wargames", "a83e0a7f7bd18ef712b4776dac84b6f55de7254f")
    self.notifoSibscribe(notifo)
    notifo.post(recipient.notifo_account,message)
  end

  def sendText(message,recipient)
    account = Twilio::RestAccount.new(ACCOUNT_SID, ACCOUNT_TOKEN)
    data = {
      'From' => CALLER_ID,
      'To' => recipient.phone,
      'Body' => message,
    }
    resp = account.request("/#{API_VERSION}/Accounts/#{ACCOUNT_SID}/SMS/Messages",'POST', data)
    if !resp.kind_of? Net::HTTPSuccess
      puts('there was a bad number or a 400 error or something with a send message to twillio')
    end
  end
end
