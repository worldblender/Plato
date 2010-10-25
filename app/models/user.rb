class User < ActiveRecord::Base
  acts_as_mappable :default_units => :kms,
                   :lat_column_name => :latitude,
                   :lng_column_name => :longitude
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :oauthable
  devise :database_authenticatable, :oauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :latitude, :longitude, :bomb_id, :deadtime

  scope :near, lambda{|latitude,longitude| where(:origin =>[latitude,longitude], :within=>BOMB_RADIUS/1000) }

  scope :inRange, lambda{|latitude,longitude| where (  BOMB_RADIUS )}

  def lawOfCosDist(latitude,longitude)
  end

  def haversine_distance(lat1, lon1, lat2, lon2)
    dMeters = -1
    if (lat1 && lon1 && lat2 && lon2)
      dlon = lon2 - lon1
      dlat = lat2 - lat1
      dlon_rad = dlon * RAD_PER_DEG
      dlat_rad = dlat * RAD_PER_DEG
      lat1_rad = lat1 * RAD_PER_DEG
      lon1_rad = lon1 * RAD_PER_DEG
      lat2_rad = lat2 * RAD_PER_DEG
      lon2_rad = lon2 * RAD_PER_DEG
      a = (Math.sin(dlat_rad/2))**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * (Math.sin(dlon_rad/2))**2
      c = 2 * Math.atan2( Math.sqrt(a), Math.sqrt(1-a))
      dMeters = Rmeters * c     # delta in meters
    end
    return dMeters
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
