class Album < ActiveRecord::Base

  # Associations
  has_many :images, dependent: :destroy
  has_many :profiles
  has_and_belongs_to_many :categories

  #has_and_belongs_to_many :album_categories
  #has_and_belongs_to_many :subcategories

  # Validations
  validates_presence_of :start_date, :title

  # Methods

  # To wipe out images in an album
  # /d.wessman
  def destroy_images
    self.images.destroy_all
    return true
  end



  def to_date
    if(self.start_date) && (self.end_date) && (self.start_date.to_date != self.end_date.to_date)
      self.start_date.to_date.to_s + " till " +self.end_date.to_date.to_s
    elsif (self.start_date)
      self.start_date.to_date.to_s
    elsif (self.end_date)
      self.end_date.to_date.to_s
    else
      false
    end
  end
end
