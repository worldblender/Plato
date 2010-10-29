class GameController < ApplicationController
  include BombsHelper
  def index
    @bombs = Bomb.all
    @players = User.all
  end

  def restart
    current_user.resurrect
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
        damage = damageFor(bomb.distance_from(u))
        u.notify(sprintf("bomb incoming, it will detonate on you in %4f seconds unless you move, and do %4f damage reducing you to %4f hitpoints",bomb.duration.to_s[0,4,],damage,u.hp-damage))
      end
    end
  end

  def playerMoved
    current_user.latitude = params[:lat]
    current_user.longitude = params[:lng]
    current_user.save
  end
end
