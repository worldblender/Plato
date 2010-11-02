module ApplicationHelper
  def event(params)
    event_type = EventType.get_type(params[:type])
    event = Event.new(params)
    event.event_type=event_type.id
    event.save
  end
end
