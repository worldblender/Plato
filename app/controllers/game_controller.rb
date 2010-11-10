class GameController < ApplicationController
  include BombsHelper
  include ApplicationHelper
  def index
    @bombs = Bomb.all
    @players = User.all
  end

  def restart
    current_user.resurrect
    redirect_to '/'
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
        h = bomb.heading_from(u)
	heading = "error"
        case h
        when 0..22
	  heading = "north"
	when 23..67
	  heading = "northeast"
	when 68..112
	  heading = "east"
	when 113..157
	  heading = "southeast"
	when 158..202
	  heading = "south"
	when 203..247
	  heading = "southwest"
	when 248..292
	  heading = "west"
	when 293..337
	  heading = "northwest"
	when 338..360
	  heading = "north"
	end
        bombDistance = bomb.distance_from(u, :units => :kms)
        damage = damageFor(bombDistance)
        u.notify("%s dropped a bomb %d meters %s of you! It will detonate in %.0f seconds and do %d damage reducing you to %d hitpoints, unless you move.", current_user.name, bombDistance * 1000, heading, bomb.duration.to_s,damage,u.hp-damage))
      end
    end
  end

  def playerMoved
    current_user.latitude = params[:lat]
    current_user.longitude = params[:lng]
    event(:type => 'move', :data => "lat: #{current_user.latitude.to_s}; long: #{current_user.longitude}; id: #{current_user.id};")
    current_user.save
  end

  def savePhone
    current_user.phone = params[:num]
    current_user.save
  end
end
