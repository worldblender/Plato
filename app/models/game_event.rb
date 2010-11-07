class GameEvent < ActiveRecord::Base
  scope :since, lambda{|time| where(["created_at> ?",time])}
end
