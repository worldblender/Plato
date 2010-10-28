module FacebookHelper
  def orderedScoreChart
    users = User.all.sort!{|a,b| a.scoreChartScore <=> b.scoreChartScore }
    return users
  end
end
