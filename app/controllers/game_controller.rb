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
      bomb.owner_id = current_user.id
      bomb.save
      current_user.bomb_id = bomb.id
      current_user.save
      bomb.setDuration
      bomb.usersInRange.each do |u|
        damage = damageFor(bomb.distance_from(u, :units => :kms))
        u.notify(sprintf("%s dropped a bomb near you! It will detonate in %.0f seconds and do %d damage reducing you to %d hitpoints, unless you move.", current_user.name, bomb.duration.to_s,damage,u.hp-damage))
      end
    end
  end

  def playerMoved
    current_user.latitude = params[:lat]
    current_user.longitude = params[:lng]
    event(:type => 'move', :data => 'lat: ' + current_user.latitude.to_s + '; long: ' + current_user.longitude.to_s + '; id:' + current_user.id.to_s + ';')
    current_user.save
  end
end
