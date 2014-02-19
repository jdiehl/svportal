class AddTestData < ActiveRecord::Migration

  # fetch a random country
  def self.random_country
    @countries     ||= Country.find :all
    @country_count ||= Country.count
    
    @countries[rand(@country_count)]
  end
  
  # create a user
  def self.create_user(firstName, lastName, university, tshirt_size, password = nil, email = nil, country = nil)
    country  ||= random_country
    # password must be at least 6 characters long
    password = 'swordfish' 
    email    ||= '%s@rwth.de' % firstName.downcase
    
    
    User.create :first_name => firstName, 
                :last_name => lastName, 
                :university => university, 
                :home_country_id => country.id,
                :password => password,
                :email => email,
                :gender => 'm',
                :tshirt_size_id => tshirt_size.id
  end
  
  # create a conference
  def self.create_conference(name, year, start_string, end_string)
    Conference.create :name => name,
                      :year => year,
                      :start_date => start_string.to_date,
                      :end_date => end_string.to_date,
                      :status => Conference::Enrollment
  end
  
  def self.up
    srand Time.now.to_i
    
    # create conferences
    chi08 = create_conference 'CHI 2008', 2008, '2008-04-05', '2008-04-10'
    chi07 = create_conference 'CHI 2007', 2007, '2007-04-05', '2007-04-10'
    
    # create TshirtSizes
    TshirtSize.create :name => 'M'
    TshirtSize.create :name => 'L'
    TshirtSize.create :name => 'XL'
    TshirtSize.create :name => 'XXL'

    # retrieve Tshirt sizes
    tshirt_sizes = TshirtSize.all

    # create admins
    AdminUser.create :login => 'admin',   :password => 'admin', :status => 2, :conference_id => chi08.id
    AdminUser.create :login => 'chi08',   :password => 'chi08', :status => 1, :conference_id => chi08.id
    AdminUser.create :login => 'chi08sv', :password => 'chi08', :status => 0, :conference_id => chi08.id
    AdminUser.create :login => 'chi07',   :password => 'chi07', :status => 1, :conference_id => chi07.id
    AdminUser.create :login => 'chi07sv', :password => 'chi07', :status => 0, :conference_id => chi07.id
    
    # create users
    max      = create_user 'Max', 'Mustermann', 'RWTH Aachen', tshirt_sizes[0]
    peter    = create_user 'Peter', 'Schmidt', 'FH Aachen', tshirt_sizes[0]
    mathilda = create_user 'Mathilda', 'Grün', 'Uni München', tshirt_sizes[0]
    gundula  = create_user 'Gundula', 'Gittemann', 'RWTH Aachen', tshirt_sizes[0]
    berthold = create_user 'Berthold', 'Grenzpfahl', 'RWTH Aachen', tshirt_sizes[0]
    
    # create some more random users
    1.upto(50) do |i|
      u = create_user 'Random', 'Person %i' % i, 'Some University', tshirt_sizes[rand(tshirt_sizes.size)], 'xxx', 'random%i@rwth.de' % i
      u.enroll! chi08
    end
    
    # enroll users
    max.enroll! chi08
    peter.enroll! chi08
    mathilda.enroll! chi08
    gundula.enroll! chi08
    gundula.enroll! chi07
    berthold.enroll! chi07
        
  end

  def self.down
    truncate :assignments
    truncate :enrollments
    truncate :users
    truncate :admin_users
    truncate :tasks
    truncate :conferences
  end
end
