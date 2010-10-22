class Bomb < ActiveRecord::Base
  def explode
    # cause this bomb to blow, kill people caught in radius
    User.where(:deadtime => nil).near(self.latitude,self.longitude).each do |user|
      user.deadtime = curTime
      user.save
    end
    # set the detonatetime
    self.detonatetime = curTime
    self.save
    userWhoDroppedBomb = User.where(:bomb_id => self.id)
    userWhoDroppedBomb.bomb_id = nil
    userWhoDroppedBomb.save
  end

  scope :explodeDurring, lambda{|startTime,endTime| where({:createtime => startTime..endTime}) }
end
