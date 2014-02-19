require 'net/http'
require 'fastercsv'

class Importer
  TABLES = %w{countrylist conference tasks people enroll status bids email news}
  
  # custom converters
  CONVERTER_CONFERENCE_STATUS = {'P' => 0, 'E' => 1, 'R' => 2, 'B' => 3, 'O' => 5}
  CONVERTER_ENROLLMENT_STATUS = {'erl' => 1, 'wtl' => 2, 'acc' => 3, 'reg' => 4, 'drp' => 6, 'bnc' => 6, 'dln' => 6}
  CONVERTER_ASSIGNMENT_STATUS = {'assigned' => 1, 'checked-in' => 2, 'done' => 3}
  
  # tshirt sizes
  TSHIRT_SIZES = ['Male: S', 'Male: M', 'Male: L', 'Male: XL', 'Male: XXL', 'Male: XXXL', 'Female: S', 'Female: L', 'Female: M', 'Female: XL', 'Female: XXL', 'Female: XXXL']
  
  # make adjustmens for CHI 2008
  def self.fix_chi08
    print "Fixing Task days...\n"
    chi08 = Conference.find_by_short_name 'CHI2008'
    raise 'CHI 2008 Conference not found. Make sure to import data before running this task.' unless chi08
    ActiveRecord::Base.transaction do
      Task.update_all 'day=day-1 where conference_id=%i' % chi08.id
      chi08.start_date += 1.days
      chi08.save!
    end
  end
  
  # clean up all tables
  def self.wipe
    print "Wiping out the database...\n"
    tables = %w{assignments bids comments drafts enrollments mails news sessions tasks tickets users tshirt_sizes admin_users conferences countries}
    c = ActiveRecord::Base.connection
    ActiveRecord::Base.transaction do
      tables.each { |t| c.execute 'truncate %s' % t }
    end
  end
  
  # helper method to convert tshirt sizes
  def self.convert_tshirts(conversion, cond = {})
    unless @sizes
      @sizes = {}
      TshirtSize.find(:all).each { |o| @sizes[o.name] = o.id }
    end
    conversion.each do |k,v|
      cond[:tshirt_size_id] = @sizes[k]
      User.update_all({:tshirt_size_id => @sizes[v]}, cond)
    end
  end
  
  # convert tshirt sizes
  def self.fix_tshirts
    # prepare conversion hashes
    sizes = %w{S M L XL XXL XXXL}
    c, cm, cf = {}, {}, {}
    sizes.each do |s|
      c['F'+s] = 'Female: '+s
      c['M'+s] = 'Male: '+s
      cm[s] = 'Male: '+s
      cf[s] = 'Female: '+s
    end
    
    ActiveRecord::Base.transaction do
      # create sizes
      new_sizes = []
      order = 0
      TSHIRT_SIZES.each do |name|
        order += 1
        new_sizes << TshirtSize.create(:name => name, :order => order).id
      end
    
      # convert tshirt sizes
      convert_tshirts c
      convert_tshirts cm, :gender => 'm'
      convert_tshirts cm, :gender => 'f'
    
      # delete invalid sizes
      User.update_all({:tshirt_size_id => nil}, 'tshirt_size_id NOT IN (%s)' % new_sizes.join(','))
      TshirtSize.delete_all 'id NOT IN (%s)' % new_sizes.join(',')
    end
  end
  
  # constructor
  def initialize(url)
    @url = url
  end
  
  # perform the import
  def go
    @duplicate_user = {}
    @duplicate_enroll = {}
    ActiveRecord::Base.transaction do
      TABLES.each do |table,conversion|
        send 'before_%s' % table if respond_to? 'before_%s' % table, true
        data = load table
        data.each { |row| send 'parse_%s' % table, row }
        send 'after_%s' % table if respond_to? 'after_%s' % table, true
      end
    end
  end
  
  protected
  
  # load import data
  def load(table)
    print "Importing %s...\n" % table
    
    # get request
    data = Net::HTTP.get URI.parse(@url % table)
    
    # make csv
    csv = FasterCSV.parse data, :col_sep => ';', :headers => true
    
    return csv
  end
  
  # create a rails object
  def create(classObject)
    object = classObject.new
    yield object if block_given?
    object.save!
  end
  
  # map country code to country id
  def country_map(code)
    unless @country_map
      @country_map = {}
      Country.find(:all).each { |c| @country_map[c.code] = c.id }
    end
    @country_map[code]
  end
  
  # map tshirt size to id (or create a new tshirt size)
  def tshirt_map_or_create(name)
    unless @tshirt_map
      @tshirt_map = {}
      TshirtSize.find(:all).each { |c| @tshirt_map[c.name] = c.id }
    end
    @tshirt_map[name] ||= TshirtSize.create(:name => name).id
  end
  
  # parse the countrylist table
  def parse_countrylist(r)
    create Country do |c|
      c.code = r['shortcode']
      c.name = r['name']
    end
  end
  
  # parse conference table
  def parse_conference(r)
    create Conference do |c|
      c.id         = r['idconf']
      c.name       = r['descr']
      c.short_name = r['shortname'].strip
      c.email      = r['chairmail'].strip
      c.status     = CONVERTER_CONFERENCE_STATUS[r['status']]
      c.volunteers = r['svlimit']
      c.volunteer_hours = r['expected_hours'] || 20
      c.year = $1 if /(\d{4})/ =~ r['descr']
    end
  end
  
  # parse task table
  def parse_tasks(r)
    date = Date.parse r['taskdate']
    
    # read conference and update start date if necessary
    if !@conference or @conference.id != r['idconf'].to_i
      @conference = Conference.find r['idconf'].to_i
      @conference.start_date = date
      @conference.save!
    end
    
    # update conference end date
    if !@conference.end_date or date > @conference.end_date
      @conference.end_date = date
      @conference.save!
    end
    
    # write task attributes
    create Task do |t|
      t.id = r['idtask']
      t.conference_id = @conference.id
      t.name = r['shortname'].strip
      t.description = r['description'] ? r['description'].strip : r['shortname'].strip
      t.location = r['taskloc'].strip if r['taskloc']
      t.start_time = r['starttime']
      t.end_time = r['endtime']
      t.slots = r['slots']
      t.hours = r['awardhours']
      t.priority = r['priority']
      t.day = date - @conference.start_date + 1
    end
  end
  
  # parse the user table
  def parse_people(r)
    # check for duplicate users
    if r['email'] and user = User.find_by_email(r['email'])
      @duplicate_user[r['idperson'].to_i] = user.id
      print("Duplicate user with email: %s\n" % user.email)
      return
    end
    
    # create the user
    create User do |u|
      u.id = r['idperson']
      u.first_name = r['fname'].strip
      u.last_name = r['lname'].strip
      u.address = [r['addr1'], r['addr2']].join("\n").strip
      u.phone = r['phone'].strip if r['phone']
      u.department = r['dept'].strip if r['dept']
      u.university = r['univ'] ? r['univ'].strip : 'unknown'
      u.residence_country_id = country_map r['rescountry']
      u.home_country_id = country_map r['passcountry']
      u.gender = r['gender'].strip.downcase if r['gender']
      u.tshirt_size_id = tshirt_map_or_create r['tshirt'].strip if r['tshirt'] and !r['tshirt'].empty?
      u.email = r['email'].strip if r['email']
      u.password = r['passwd']
      # fix validation problems
      unless u.valid?
        u.password = nil if u.errors['password']
        u.email = nil if u.errors['email']
        u.gender = 'm' if u.errors['gender']
      end
    end
  end
  
  # parse the enrollment table
  def parse_enroll(r)
    # duplicate user?
    user_id = @duplicate_user[r['idperson'].to_i]
    user_id ||= r['idperson'].to_i
    
    create Enrollment do |e|
      e.id = r['idenroll']
      e.user_id = user_id
      e.conference_id = r['idconf']
      e.lottery = r['lottery']
    end
  rescue => exception
    print(exception.message + "\n")
  end
  
  # parse the status table
  def parse_status(r)
    return if r['statcode'] != 'P'
    Enrollment.update r['idenroll'], :status => CONVERTER_ENROLLMENT_STATUS[r['code'].downcase], :comment => r['notes']
  rescue => exception
    print exception.message+"\n"
  end
  
  # after status parsing -> remove invalid enrollment records
  def after_status
    Enrollment.delete_all 'status not in(%s)' % CONVERTER_ENROLLMENT_STATUS.values.uniq.join(',')
  end
  
  # parse the bids table (only assignments)
  def parse_bids(r)
    if status = CONVERTER_ASSIGNMENT_STATUS[r['status'].downcase]
      create Assignment do |a|
        a.id = r['idbid']
        a.enrollment_id = r['idenroll']
        a.task_id = r['idtask']
        a.hours = r['actualhours'] ? r['actualhours'] : Task.find(r['idtask']).hours
        a.status = status
      end
    end
  rescue => exception
    print exception.message+"\n"
  end
  
  # parse the email table
  def parse_email(r)
    return if /test/i =~ r['subject']
    create Draft do |m|
      m.id = r['idemail']
      m.conference_id = r['idconf']
      m.subject = r['subject'].strip if r['subject']
      m.text = r['text'].strip if r['text']
      m.created_at = Date.parse r['dtsent']
    end
  rescue => exception
    print exception.message+"\n"
  end
  
  # prase the news table
  def parse_news(r)
    create News do |n|
      n.id = r['idnews']
      n.conference_id = r['idconf']
      n.created_at = r['dtnews']
      n.title = r['title']
      n.text = r['news']
    end
  end
  
end