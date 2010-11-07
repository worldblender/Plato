class GameController < ApplicationController
  include BombsHelper
  include ApplicationHelper
  def index
    current_user.last_poll = DateTime.now
    current_user.save
    @bombs = Bomb.all
    @players = User.all
  end

  def restart
    current_user.resurrect
    redirect_to '/'
  end

  def pollGameState
    @jsonObjects=GameEvent.since(current_user.last_poll)
    current_user.last_poll = DateTime.now
    render :json => @jsonObjects
  end

  def dropBomb
    if current_user.bomb_id == nil && current_user.deadtime == nil
      bomb = Bomb.new
      bomb.createtime = DateTime.now
      bomb.latitude = params[:lat]
      bomb.longitude = params[:lng]
      bomb.srcLat = current_user.latitude
      bomb.srcLng = current_user.longitude
      bomb.owner_id = current_user.id
      bomb.save
      current_user.bomb_id = bomb.id
      current_user.save
      bomb.setDuration
      bomb.usersInRange.each do |u|
        damage = damageFor(bomb.distance_from(u, :units => :kms))
        u.notify(sprintf("%s dropped a bomb near you! It will detonate in %.0f seconds and do %d damage reducing you to %d hitpoints, unless you move.", current_user.name, bomb.duration.to_s,damage,u.hp-damage))
      end
      updateValues = Array.new
      updateValues << ['0', bomb.latitude.to_s]
      updateValues << ['1', bomb.longitude.to_s]
      updateValues << ['2', (bomb.timeLeft * 1000).to_s]
      updateValues << ['5', current_user.id.to_s]
      updateValues << ['6', current_user.latitude.to_s]
      updateValues << ['7', current_user.longitude.to_s]
      updateValues << ['8', bomb.id.to_s]
      jsonEvent('dropBomb',updateValues.to_s)
    end
  end

  def playerMoved
    current_user.latitude = params[:lat]
    current_user.longitude = params[:lng]
    event(:type => 'move', :data => 'lat: ' + current_user.latitude.to_s + '; long: ' + current_user.longitude.to_s + '; id:' + current_user.id.to_s + ';')
    updateValues = Array.new
    updateValues << ['0', current_user.latitude.to_s]
    updateValues << ['1', current_user.longitude.to_s]
    updateValues << ['3', current_user.facebook_id.to_s]
    jsonEvent('updatePlayer',updateValues)
    current_user.save
  end

  def savePhone
    current_user.phone = params[:num]
    current_user.save
  end
end
