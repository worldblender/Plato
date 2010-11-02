module ApplicationHelper
  def event(params)
    event_type = EventType.get_type(params[:type])
    Event.new(:data => params[:data], :event_type => event_type.id).save
  end
end
