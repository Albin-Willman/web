#encoding: UTF-8
class Category < ActiveRecord::Base

  # Associations
  has_many :images
  has_and_belongs_to_many :albums
  #More models here

  # Validations
  validates_presence_of :title,:description
  validates_uniqueness_of :title, scope: [:sub]

  # Scopes
  scope :cats, -> {order(title: :asc)}
  scope :sups, -> {cats.where(sub: false)}
  scope :subs, -> {cats.where(sub: true)}

  # Methods

  def print
    if(sub?)
      %(#{self.title} - underkategori)
    else
      self.title
    end
  end
  def sub?
    self.sub
  end
end
