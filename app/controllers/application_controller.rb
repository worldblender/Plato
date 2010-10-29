class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :resolveStatus
  @@lastResolve = nil

  def resolveStatus
    # explode the bombs which need to explode, and kill ppl caught in the radius
    curTime = DateTime.now
    puts "LR" + @@lastResolve.to_s + " CT" + curTime.to_s
    if(@@lastResolve == nil || curTime-@@lastResolve > 5.seconds)
      if @@lastResolve == nil
        @@lastResolve = curTime - 1.day
      end
      explodingBombs = Bomb.explodeDurring(@@lastResolve,curTime)
      @@lastResolve = curTime
      explodingBombs.each do |bomb|
        # select all users in range of this bomb who are alive and kill them
        bomb.explode(curTime)
      end
    end
  end
end
