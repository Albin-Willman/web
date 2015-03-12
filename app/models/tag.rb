class Tag < ActiveRecord::Base
  has_many :taggings
  has_many :documents, through: :taggings
end