class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :resolveStatus
  @@lastResolve = nil

  def resolveStatus
    # explode the bombs which need to explode, and kill ppl caught in the radius
    curTime = DateTime.now
    if(@@lastResolve == nil || curTime-@@lastResolve < 5.seconds)
      if @@lastResolve == nil
        @@lastResolve = curTime - 1.day
      end
      explodingBombs = Bomb.where(:detonatetime => nil).explodeDurring(DateTime.now-1.day,DateTime.now)
      @@lastResolve = curTime
      explodingBombs.each do |bomb|
        # select all users in range of this bomb who are alive and kill them
        bomb.explode
      end
    end
  end
end
