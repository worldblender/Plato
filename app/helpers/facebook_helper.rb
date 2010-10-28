module FacebookHelper
  def orderedScoreChart
    users = User.all.sort!{|a,b| b.scoreChartScore <=> a.scoreChartScore }
    return users
  end
end
