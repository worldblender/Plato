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
      current_user.bomb_id = @bomb.id
      bomb.save
      current_user.save
    end
  end

  def playerMoved
    current_user.latitude = params[:lat]
    current_user.longitude = params[:lng]
    current_user.save
  end
end
