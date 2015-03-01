class Faq < ActiveRecord::Base

  has_one :category
  validates :question, presence: true
  
end
