class GameEvent < ActiveRecord::Base
  serialize :fields, Array
  scope :since, lambda{|time| where(["created_at> ?",time])}
  scope :fireBefore, lambda{|time| where(["fire_time < ?",time])}
  scope :fireSince lambda{|time| where(["fire_time > ?",time])}

  def fire
    Game2Controller.stateMachine(self.fields)
    if self.client
      # send to client channel via socket
    end
  end
end
