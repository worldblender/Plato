class GameController < ApplicationController
  def index
    @bombs = Bomb.all
    @players = User.all
  end

  def dropBomb
    if current_user.bomb_id == nil && current_user.deadtime == nil
      bomb = Bomb.new
      bomb.createtime = DateTime.now
      bomb.latitude = params[:lat]
      bomb.longitude = params[:lng]
      bomb.detonatetime = nil
      bomb.save
      current_user.bomb_id = bomb.id
      current_user.save
      bomb.usersInRange.each do |u|
        u.notify("bomb incoming, it will detonate on you in " + BOMB_TIME.to_s + " seconds unless you move")
      end
    end
  end

  def playerMoved
    current_user.latitude = params[:lat]
    current_user.longitude = params[:lng]
    current_user.save
  end
end
