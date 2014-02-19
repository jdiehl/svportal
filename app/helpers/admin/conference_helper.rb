module Admin::ConferenceHelper

  def lottery_config_select_options()
    [['Yes: Required', 4], ['Yes: 3 tickets', 3], ['Yes: 2 tickets', 2], ['Yes: 1 ticket', 1], ['No effect', 0], ['No: 1 ticket', -1], ['No: 2 tickets', -2], ['No: 3 tickets', -3], ['No: required', -4]]
  end

end
