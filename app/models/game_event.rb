class GameEvent < ActiveRecord::Base
  scope :since, lambda{|time| where(["create_time > ?",time])}
end
