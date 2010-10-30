class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :resolveStatus

  def resolveStatus
    # explode the bombs which need to explode, and kill ppl caught in the radius
    curTime = DateTime.now
    Bomb.transaction do
      User.transaction do
        explodingBombs = Bomb.explodeBefore(curTime)
        explodingBombs.each do |bomb|
          # select all users in range of this bomb who are alive and kill them
          bomb.explode(curTime)
        end
      end
    end
  end
end
