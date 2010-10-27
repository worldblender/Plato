class Bomb < ActiveRecord::Base
  include BombsHelper

  acts_as_mappable :default_units => :kms,
                   :default_formula => :sphere,
                   :distance_field_name => :distance,
                   :lat_column_name => :latitude,
                   :lng_column_name => :longitude
  def setDuration
    self.owner_id = User.where(:bomb_id => self.id).first.id
    self.duration = serverCalcDuration(self.distance_from(User.find(self.owner_id), :units => :kms) * 1000)
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
      user.kill
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
