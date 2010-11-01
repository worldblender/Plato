class GameController < ApplicationController
  include BombsHelper
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
      bomb.save
      current_user.bomb_id = bomb.id
      current_user.save
      bomb.setDuration
      bomb.usersInRange.each do |u|
      damage = damageFor(bomb.distance_from(u, :units => :kms))
      u.notify(sprintf("%s dropped a bomb near you! It will detonate in %.0f seconds and do %d damage reducing you to %d hitpoints, unless you move.", u.name, bomb.duration.to_s,damage,u.hp-damage))
      end
    end
  end

  def playerMoved
    current_user.latitude = params[:lat]
    current_user.longitude = params[:lng]
    current_user.save
  end
end
