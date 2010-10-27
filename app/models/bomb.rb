class Bomb < ActiveRecord::Base
  acts_as_mappable :default_units => :kms,
                   :default_formula => :sphere,
                   :distance_field_name => :distance,
                   :lat_column_name => :latitude,
                   :lng_column_name => :longitude
  def after_create
    self.duration = calculateDuration([self.owner.latitude,self.owner.longitude],[self.latitude,self.longitude])
  end

  def calculateDuration(bombLoc, userLoc)

  end

  def isExploded?
    return self.detonatetime == nil
  end

  def explode(curTime)
    # cause this bomb to blow, kill people caught in radius
    self.usersInRange.each do |user|
      user.deadtime = curTime
      user.save
    end
    # set the detonatetime
    self.detonatetime = curTime
    self.save
    User.where(:bomb_id => self.id).each do |u|
      u.bomb_id = nil
      u.save
    end
  end

  def usersInRange
    return User.where(:deadtime => nil).within(BOMB_RADIUS, :origin => [self.latitude,self.longitude])
  end

  def timeLeft
    timeLeft = BOMB_TIME.seconds-(Time.now-self.createtime) # this will result in the timeLeft, but in days as a float
    if(timeLeft < 0)
      return 0
    else
      return timeLeft
    end
  end



  scope :explodeDurring, lambda{|startTime,endTime| where({:createtime => (startTime-BOMB_TIME.seconds)..(endTime-BOMB_TIME.seconds)})}
end
