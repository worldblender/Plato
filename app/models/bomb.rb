class Bomb < ActiveRecord::Base
  include BombsHelper
  include ApplicationHelper

  acts_as_mappable :default_units => :kms,
                   :default_formula => :sphere,
                   :distance_field_name => :distance,
                   :lat_column_name => :latitude,
                   :lng_column_name => :longitude
  def setDuration
    self.duration = serverCalcDuration(self.distance_from(User.find(self.owner_id), :units => :kms) * 1000)
    self.detonatetime = self.createtime + self.duration.seconds
    self.save
  end


  def isExploded?
    if self.did_explode == nil || self.did_explode == false
      return false
    else
      return true
    end
  end

  def explode(curTime)
    # cause this bomb to blow, kill people caught in radius
    self.usersInRange.each do |user|
      damage = damageFor(self.distance_from(user, :units => :kms))
      user.hitWith(damage)
      if user.hp <= 0
        event(:type => 'kill', :data => 'lat: ' + self.latitude.to_s + '; long: ' + self.longitude.to_s + '; target_id: ' + user.id.to_s + '; bomb_id: ' + self.id.to_s + ';');
      else
        event(:type => 'hit', :data => damage.to_s + '; hp: ' + user.hp.to_s + '; lat: ' + user.latitude.to_s + '; long: ' + user.longitude.to_s + '; target_id:' + user.id.to_s + '; bomb_id: ' + self.id.to_s + ';')
      end
      user.notify(sprintf("You just got hit by a bomb which was thrown by %s.  This did %d damage to you and you now have %d hitpoints left", User.find(self.owner_id).name, damage, user.hp))
    end
    self.did_explode=true
    self.save
    User.where(:bomb_id => self.id).each do |u|
      u.bomb_id = nil
      u.save
    end
  end

  def usersInRange
    return User.where(["hp > 0"]).within(BOMB_RADIUS, :origin => [self.latitude,self.longitude])
  end

  def timeLeft
    timeLeft = self.duration.seconds-(Time.now-self.createtime) # this will result in the seconds left till it explodes
    if(timeLeft < 0)
      return 0
    else
      return timeLeft
    end
  end
  scope :explodeBefore, lambda{|endTime| where(["detonatetime < ? and did_explode = false",endTime])}
end
