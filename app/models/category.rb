#encoding: UTF-8
class Category < ActiveRecord::Base
  has_and_belongs_to_many :albums
  #Lägga till fler modeller som vill kategoriseras här

  validates_presence_of :title,:description
  validates_uniqueness_of :title, :sub

  def self.subs
    where(sub: true)
  end

  def self.sups
    where(sub: false)
  end
end
