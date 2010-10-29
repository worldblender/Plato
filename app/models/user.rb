class User < ActiveRecord::Base
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
    return curTime-self.createtime
  end

  def photoUrl
    return "http://graph.facebook.com/" + self[:facebook_id] + "/picture"
  end

  def acceptText?
    return self.phone != nil
  end

  def notify(textMessage,title = 'Game notification from ' + GAME_NAME)
    if self.acceptText?
      # send a text message
      sendText(textMessage,self)
    else
      # send an email
      Dmailer.send_text(textMessage,self,title).deliver
    end
  end

  def kill
    curTime = Time.now
    thisScore = curScore(curTime)
    if(self.top_score == nil || self.top_score < thisScore)
      self.top_score = thisScore
    end
    self.deadtime = curTime
    self.save
  end

  def hitWith(dmg)
    if (self.hp == nil)
      self.hp=1
    end
    self.hp = self.hp-dmg
    if hp<=0
      self.kill
    end
    self.save
  end

  def resurrect
    self.hp = 1
    self.bomb_id = nil
    self.deadtime = nil
    self.createtime = DateTime.now
    self.save
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
