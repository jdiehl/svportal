class Category < ActiveRecord::Base
  belongs_to :conference
  has_many :tasktypes
  
  validates_presence_of :name
end
