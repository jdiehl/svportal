# The auction assigns tasks to students in accordence with their bids.
class Auction
  attr_accessor :day, :conference
  
  # constructor
  def initialize(day)
    @day = day
    @conference = day.conference
  end
  
  # run the auction
  def run
#    bid_on_high_priority_tasks
#    bid_on_regular_tasks
    
    # run the auction as long as there are bids being assigned
    assigned = 1
    while assigned > 0
      assigned = 0

      # process all bids in pre-randomized order
      bids_by_importance.each do |key, bids|
        
        # each bidder can have multiple bids
        bids.each do |bid_list|
          next if bid_list.empty?
      
          # each bidder can have multiple bids, get a random
          bid = bid_list.delete_at rand(bid_list.length)
      
          # check that the bid is valid
          if bid.check_for_conflict
            bid.conflict!
            retry
          end
      
          # assign the bid
          bid.assign!
          assigned += 1
        end # done with a bid
        
      end # done with a bid importance group
      
    end # done with all bids
    
  end

  
  protected
  
  # retrieve and order all bids
  def bids_by_importance
    return @bids if @bids
    raw = Bid.find :all,
      :include => :task,
      :conditions => 'bids.status=%i and tasks.conference_id=%i and tasks.day=%i' % [Bid::OPEN, @conference.id, @day.id]
      
    # order bids by preference and enrollment
    @bids = {}
    raw.each do |b|
      key = '%i_%i' % [b.task.priority, b.preference]
      @bids[key] ||= {}
      @bids[key][b.enrollment_id] ||= []
      @bids[key][b.enrollment_id] << b
    end
    
    # randomize the bids
    @bids.each do |key, bids|
      @bids[key] = randomize_array(bids.values)
    end
    
    @bids.sort
  end
  
  # randomize an array
  def randomize_array(values)
    random_values = []
    random_values << values.delete_at(rand(values.length)) while !values.empty?
    random_values
  end
  
  # high priority tasks first
  def bid_on_high_priority_tasks
    random_bids('priority=0').each do |bid|
      bid.assign!
    end
  end
  
  # rest of the tasks
  def bid_on_regular_tasks
    users = random_users
    [Bid::HIGH, Bid::MEDIUM, Bid::LOW].each do |preference|
      bid_assigned = false
      users.each do |enroll|
        next unless bid = random_bid(enroll, preference)
        redo unless bid.assign!
        bid_assigned = true
      end
      redo if bid_assigned
    end
  end
  
  # retrieve a random bid
  def random_bids(cond = nil)
    cond = [cond].compact
    cond << 'bids.status=%i' % Bid::OPEN
    cond << 'tasks.conference_id=%i' % conference.id
    cond << 'day=%i' % day.id
    Bid.find :all,
      :include => [:task, :enrollment],
      :conditions => cond.join(' and '),
      :order => 'preference, rand()'
  end
  
  # retrieve a random bid for enrollment
  def random_bid(enroll, preference)
    query = 'select b.* from bids b, tasks t where t.id=b.task_id and ' +
      'b.enrollment_id=%i and t.day=%i and b.status=%i and b.preference=%i ' % [enroll.id, day.id, Bid::OPEN, preference] +
      'order by rand() limit 1'
    bids = Bid.find_by_sql query
    bids.empty? ? nil : bids.first
  end
  
  # fetch random users
  def random_users
    query = 'select *, ' +
    '(select sum(hours) from assignments a where a.enrollment_id = e.id) as hours ' +
    'from enrollments e where e.status = %i and e.conference_id = %i ' % [Status::REGISTERED, conference.id] +
    'order by hours, rand()'
    Enrollment.find_by_sql query
  end
  
end