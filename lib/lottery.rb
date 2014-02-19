# The lottery assigns a random order to all enrolled students and accepts or waitlists them
# according to the number of sv spots in the conference.
# 
# When running the lottery a second time, numbering starts where it was left off.
class Lottery
  
  # constructor
  def initialize(conference)
    @conference = conference
  end
  
  # run the lottery
  def run
    random_users.each do |enroll|
      assign_number enroll
    end
  end
      
  
  protected
  
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
  
  # fetch enrolled users in random order
  def random_users
    Enrollment.find :all,
      :conditions => 'status = %i and conference_id = %i and lottery IS NULL' % [Status::ENROLLED, @conference.id],
      :order => 'rand()'
  end
  
  
  
end