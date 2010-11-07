module ApplicationHelper
  def event(params)
    event_type = EventType.get_type(params[:type])
    Event.new(:data => params[:data], :event_type => event_type.id).save
  end
  def jsonEvent(function,propertyArray)
    event = GameEvent.new
    event.fields << { :fxn => function }
    propertyArray.each do |propPair|
      event.fields << { propPair[0] => propPair[1] }
    end
    event.save
  end
end
