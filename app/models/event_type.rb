class EventType < ActiveRecord::Base
  def self.get_type(event_name)
    EventType.where(:event_name => event_name).first
  end
end
