class LotteryConfig < ActiveRecord::Base
  
  # bugfix to allow yesno select
  def degree
    super ? 1 : 0
  end
end
