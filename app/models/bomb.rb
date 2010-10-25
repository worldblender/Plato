class Bomb < ActiveRecord::Base
  acts_as_mappable
  def explode(curTime)
    # cause this bomb to blow, kill people caught in radius
    User.where(:deadtime => nil).within(BOMB_RADIUS/1000, :origin => [self.latitude,self.longitude]).each do |user|
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

  scope :explodeDurring, lambda{|startTime,endTime| where({:createtime => (startTime-BOMB_TIME.seconds)..(endTime-BOMB_TIME.seconds)})}
end
