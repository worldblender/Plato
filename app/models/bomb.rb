class Bomb < ActiveRecord::Base
  VELOCITY = 2.08333333 # the number of meters traveled per second, so 500 meters covered in 30 seconds => 1000 m/min = 16.67 m/s
  ACCELERATION = 0.00868055554 #  accel = meter/second/second, this means that in 60 seconds is will have increased m/s by 16.67 m/s if a=.2778
  acts_as_mappable :default_units => :kms,
                   :default_formula => :sphere,
                   :distance_field_name => :distance,
                   :lat_column_name => :latitude,
                   :lng_column_name => :longitude
  def setDuration
    self.owner_id = User.where(:bomb_id => self.id).first.id
    self.duration = calculateDuration
    self.detonatetime = self.createtime + self.duration.seconds
    self.save
  end

  def calculateDuration
    distance = self.distance_from(User.find(self.owner_id), :units => :kms) * 1000
    time = (-VELOCITY+Math.sqrt(VELOCITY*VELOCITY+2*ACCELERATION*distance))/(ACCELERATION)
    return time
  end

  def shouldExplode?(curTime)
    return (self.createtime + duration.seconds) > curTime
  end

  def isExploded?
    return self.detonatetime <= DateTime.now
  end

  def explode(curTime)
    # cause this bomb to blow, kill people caught in radius
    self.usersInRange.each do |user|
      user.deadtime = curTime
      user.save
    end
    User.where(:bomb_id => self.id).each do |u|
      u.bomb_id = nil
      u.save
    end
  end

  def usersInRange
    return User.where(:deadtime => nil).within(BOMB_RADIUS, :origin => [self.latitude,self.longitude])
  end

  def timeLeft
    timeLeft = self.duration.seconds-(Time.now-self.createtime) # this will result in the seconds left till it explodes
    if(timeLeft < 0)
      return 0
    else
      return timeLeft
    end
  end



  scope :explodeDurring, lambda{|startTime,endTime| where({:detonatetime => startTime..endTime})}
end
