module ApplicationHelper
  def event(params)
    event_type = EventType.get_type(params[:type])
    Event.new(:data => params[:data], :event_type => event_type.id).save
  end
  def jsonEvent(function,propertyArray)
    text = '{ "fxn": ' + function + ','
    propertyArray.each do |propPair|
      if propPair == propertyArray.first
        text += '"data" : {'
      end
      text += '"'+propPair[0].to_s + '" : "' + propPair[1].to_s + ' " '
      if propPair != propertyArray.last
        text += ','
      else
        text += '}'
      end
    end
    GameEvent.new(:json => text).save
  end
end
