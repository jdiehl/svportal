require 'array+randomize.rb'

# The lottery assigns a random order to all enrolled students and accepts or waitlists them
# according to the number of sv spots in the conference.
# 
# When running the lottery a second time, numbering starts where it was left off.
class Lottery
  
  # constructor
  def initialize(conference)
    @conference = conference
    @config = conference.lottery_config
  end
  
  # run the lottery
  def run
    
    # duplicate users according to attributes and config
    enroll_poll = []
    enroll_out = []
    load_enroll.each do |enroll|
      if enroll.lottery_score > 0
        1.upto(enroll.lottery_score) { enroll_poll << enroll }
      else
        enroll_out << enroll
      end
    end
    
    # randomize list
    enroll_poll.randomize!
    
    # assign numbers (track already enrolled)
    while enroll_poll.length > 0
      enroll = enroll_poll.first
      assign_number enroll
      enroll_poll.delete enroll
    end
    
    # assign numbers to svs that were left out
    enroll_out.randomize.each do |enroll|
      assign_number enroll
    end
  end
  
  # reset the lottery run
  def reset
    enroll_list = Enrollment.find :all,
      :conditions => 'conference_id = %i and lottery IS NOT NULL' % [@conference.id]
      
    enroll_list.each do |enroll|
      enroll.status = Status::ENROLLED
      enroll.comment = nil
      enroll.lottery = nil
      enroll.save!
    end
  end
      
  
  protected
  
  # load users from the database
  def load_enroll
    Enrollment.find :all,
      :conditions => 'status = %i and conference_id = %i and lottery IS NULL' % [Status::ENROLLED, @conference.id]
  end
  
  # assign status ACCEPTED or ON_WAITLIST, depending on order..
  def assign_number(enroll)
    enroll.lottery = next_number
    
    # accepted
    if more_free_slots?
      enroll.status = Status::ACCEPTED
      enroll.comment = 'Accepted in lottery'
      
    # waitlist
    else
      enroll.status = Status::WAITLISTED
      enroll.comment = 'Waitlisted in lottery'
    end
    
    enroll.save!
  end
  
  # are there free slots available?
  def more_free_slots?
    return (@slots -= 1) >= 0 if @slots
    
    # count accepted students
    taken = Enrollment.count :conditions => 'conference_id=%i and status >= %i' % [@conference.id, Status::ACCEPTED]
    @slots = @conference.volunteers - taken
    (@slots -= 1) >= 0
  end
  
  # retrieve the next number for the lottery
  def next_number
    return @number += 1 if @number
    
    # read the highest lottery number from the database
    e = Enrollment.find :first, :conditions => {:conference_id => @conference.id}, :order => 'lottery desc'
    @number = e.lottery ? e.lottery : 1
  end
  
end