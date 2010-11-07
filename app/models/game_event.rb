class GameEvent < ActiveRecord::Base
  serialize :fields, Array
  scope :since, lambda{|time| where(["created_at> ?",time])}
end
