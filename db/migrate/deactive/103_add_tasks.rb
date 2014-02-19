class AddTasks < ActiveRecord::Migration
  
  # create a more or less random task
  def self.create_task(conference, day)
    @index ||= 0
    @index += 1
    name = 'Random generated task to keep the students at the conference busy #%i' % @index
    start_time = 8 + rand(10).to_i
    hours = rand(4).to_i
    attributes = {
      :name => name,
      :conference_id => conference.id,
      :day => day.id,
      :start_time => start_time,
      :end_time => start_time + hours,
      :hours => hours,
      :slots => 1 + rand(7).to_i,
      :priority => rand(2).to_i,
      :description => 'Lorem ipsum dolor sit amet, consectetuer sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.'
    }
    Task.create attributes
  end
  

  def self.up
    
    # create example tasks for all conferences ad days
    Conference.find(:all).each do |conference|
      conference.days.each do |day|
        1.upto(20 + rand(40)) do |i|
          create_task conference, day
        end
      end
    end
    
  end

  def self.down
    truncate :tasks
  end
end
