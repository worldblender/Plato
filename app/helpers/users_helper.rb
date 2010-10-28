module UsersHelper
  def scoreChartScore
    score = 0
    if(self.top_score != nil)
      score = u.top_score
    end
    if(self.curScore > score)
      score = curScore
    end
end
