class AddTestData < ActiveRecord::Migration

  # fetch a random country
  def self.random_country
    @countries     ||= Country.find :all
    @country_count ||= Country.count
    
    @countries[rand(@country_count)]
  end
  
  # create a user
  def self.create_user(firstName, lastName, university, tshirt_size, email = nil, country = nil)
    country  ||= random_country
    password = 'swordfish' 
    email    ||= '%s@rwth.de' % firstName.downcase
    
    
    User.create :first_name => firstName, 
                :last_name => lastName, 
                :university => university, 
                :home_country_id => country.id,
                :password => password,
                :email => email,
                :gender => 'm',
                :tshirt_size_id => tshirt_size.id,
                :spoken_languages => 'en',
                :past_conferences => 'none'
  end
  
  # create a conference
  def self.create_conference(name, url, year, start_string, end_string)
    Conference.create :name => name,
                      :short_name => url,
                      :year => year,
                      :start_date => start_string.to_date,
                      :end_date => end_string.to_date,
                      :email => 'not@set.de',
                      :status => Conference::Enrollment
  end
  
  def self.up
    srand Time.now.to_i
    
    # create conferences
    chi09 = create_conference 'CHI 2009', 'chi09', 2009, '2009-04-05', '2009-04-10'
    chi09 = Conference.find :first
    
    # create TshirtSizes
    TshirtSize.create :name => 'M'
    TshirtSize.create :name => 'L'
    TshirtSize.create :name => 'XL'
    TshirtSize.create :name => 'XXL'

    # retrieve Tshirt sizes
    tshirt_sizes = TshirtSize.all

    # create admins
    AdminUser.create :login => 'chi09',   :password => 'chi09', :status => 2, :conference_id => chi09.id
    
    # create users
    max      = create_user 'Max', 'Mustermann', 'RWTH Aachen', tshirt_sizes[0]
    peter    = create_user 'Peter', 'Schmidt', 'FH Aachen', tshirt_sizes[0]
    mathilda = create_user 'Mathilda', 'Grün', 'Uni München', tshirt_sizes[0]
    gundula  = create_user 'Gundula', 'Gittemann', 'RWTH Aachen', tshirt_sizes[0]
    berthold = create_user 'Berthold', 'Grenzpfahl', 'RWTH Aachen', tshirt_sizes[0]
    
    # create some more random users
    1.upto(50) do |i|
      u = create_user 'Random', 'Person %i' % i, 'Some University', tshirt_sizes[rand(tshirt_sizes.size)], '%i@random.de' % i
      u.enroll_in_conference chi09
    end
    
    # enroll users
    max.enroll_in_conference chi09
    peter.enroll_in_conference chi09
    mathilda.enroll_in_conference chi09
    gundula.enroll_in_conference chi09
    berthold.enroll_in_conference chi09
        
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
