class Image < ActiveRecord::Base
  belongs_to :album  
  belongs_to :category
  has_attached_file :foto, 
                    :styles => { large: "1500x1500>", small: "250x250>"},
                    :path => ":rails_root/storage/gallery/album/:album_id/:style/:filename"
  validates_attachment_content_type :foto, :content_type => /\Aimage\/.*\Z/  
  Paperclip.interpolates :album_id do |a, s|    
    a.instance.album_id    
  end
  def close_images
    self.class.where(album_id: self.album_id).order(foto_file_name: :asc)
  end
  def next
    img = close_images.where("foto_file_name > ?", self.foto_file_name).first
    if img.nil?
      img = close_images.first
    end
    return img
  end

  def previous
    img = close_images.where("foto_file_name < ?", self.foto_file_name).last
    if img.nil?
      img = close_images.last
    end
    return img
  end

end