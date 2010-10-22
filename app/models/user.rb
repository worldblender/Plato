class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :oauthable
  devise :database_authenticatable, :oauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me

  scope :near, lambda{|latitude,longitude| where({:latitude => laitude-BOMB_RADIUS..latitude+BOMB_RADIUS} && {:longitude => longitude-BOMB_RADIUS..longitude-BOMB_RADIUS}) }

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
      user
    end
  end

  def setLocation(latitude,longitude)
    if self[:deadtime] == nil
      self[:latitude] = latitude
      self[:longitude] = longitude
      self.save
    end
  end

  def photoUrl
    return "http://graph.facebook.com/" + self[:facebook_id] + "/picture"
  end

  def kill
    if self[:deadtime] == nil
      self[:deadtime] == DateTime.now
      self.save
    end
  end
end
