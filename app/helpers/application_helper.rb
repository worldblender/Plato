module ApplicationHelper
  def event
    event = Event.new(params)
    event.save
  end
end
