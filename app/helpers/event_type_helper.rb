module EventTypeHelper
  def get_type(event_name)
    return EventType.where(:event_name => event_name)
  end
end
