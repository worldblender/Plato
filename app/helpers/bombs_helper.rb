module BombsHelper
  VELOCITY = 2.08333333 # the number of meters traveled per second, so 500 meters covered in 30 seconds => 1000 m/min = 16.67 m/s
  ACCELERATION = 0.00868055554 #  accel = meter/second/second, this means that in 60 seconds is will have increased m/s by 16.67 m/s if a=.2778

  def serverCalcDuration(distance)
    time = (-VELOCITY+Math.sqrt(VELOCITY*VELOCITY+2*ACCELERATION*distance))/(ACCELERATION)
    time = time / 10 # TODO(jeff): remove this for the real game, this is for debugging
    return time
  end

  def clientCalcDuration
    # this should return a function which is the 'duration' function so it can be called in javascript from the client
    timeStr = "(-#{VELOCITY}+Math.sqrt(#{VELOCITY}*#{VELOCITY}+2*#{ACCELERATION}*distance))/(#{ACCELERATION})"
    timeStr = timeStr + "/10" # TODO(jeff): remove this for the real game, this is for debugging
    return timeStr
  end

  def damageFor(distance)
    # the danage dealt across the BOMB_RADIUS changes from 1 to 0 as one moves away from the epicenter
    # so a perfect direct hit will kill a person instantly, but any little bit off, and they will take at least another shot
    (BOMB_RADIUS-distance)/BOMB_RADIUS
  end
end
