class GameEvent < ActiveRecord::Base
  serialize :fields
  scope :since, lambda{|time| where(["created_at> ?",time])}
end
