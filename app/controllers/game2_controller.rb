class Game2Controller < ApplicationController
  require 'json'
  def index
    current_user.last_poll = DateTime.now
    current_user.save
    @bombs = Bomb.all
    @players = User.all
  end

  def getEvents
    @jsonObjects=GameEvent.since(current_user.last_poll).where(:client => true)
    current_user.last_poll = DateTime.now
    render :json => @jsonObjects, :layout => false
  end

  def createEvent
    # params contain all the new event info
    fields = JSON.parse(params[:fields])
    sendToClient = ['updatePlayer','createMissle'].include?(fields[:fxn])
    event = GameEvent.new(:fields => fields,Time.now, :handler => Game2Controller.stateMachine, :client => sendToClient).save
  end

  def fireEvents
    GameEvent.transaction do
      events = GameEvent.where(:fired => false).before(Time.now)
      event.each do |event|
        event.fire
      end
    end
  end

  def Game2Controller.stateMachine(fields)
    case fields[:fxn]
    when "updatePlayer"
      player = User.find(fields[:id])
      if(propPair[:lat] != nil && propPair[:lng] != nil) # player move
        player.latitude = fields[:lat]
        player.longitude = fields[:lng]
        player.save
      end
      if(player.hp == 0 && propPair[:ressurect] == true) # ressurect player
        player.ressurect
      end
    when "createMissle"
      user = User.find(fields[:userId]) # send missle
      bomb = Bomb.new(:createTime => Time.now,
                      :latitude => fields[:lat],
                      :longitude => fields[:lng],
                      :srcLat => user.latitude,
                      :srcLng = user.longitude,
                      :ownew_id => user.id).save
      bomb.setDuration
      user.bomb_id = bomb.id
      user.save
      bomb.usersInRange.each do |u|
        damage = damageFor(bomb.distance_from(u, :units => :kms))
        u.notify(sprintf("%s dropped a bomb near you! It will detonate in %.0f seconds and do %d damage reducing you to %d hitpoints, unless you move.", current_user.name, bomb.duration.to_s,damage,u.hp-damage))
      end
    when "explodeMissle"
      bomb = Bomb.find(fields[:id]) # blow up the missle
      Bomb.transaction do
        bomb.explode(Time.now)
      end
    end
  end
end
