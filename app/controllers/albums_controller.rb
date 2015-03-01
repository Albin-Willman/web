# encoding:UTF-8
class AlbumsController < ApplicationController
    
  before_action :login_required
  before_action :authenticate, only: [:new, :create,:edit,:destroy,:update,:settings,:destroy_images]
  before_action :set_album, except: [:index,:new,:create,:settings]
  before_action :categories
  
  def index
    @albums = Album.order(start_date:  :asc)
    @albums_latest = Album.order(created_at: :desc).limit(4)
  end
  
  def edit

  end
  def edit_images
    if(params[:commit]) && (current_user) && (current_user.moderator?(:galleri))
      if(params[:commit] == 'Markera alla')
        @mark = true
      elsif(params[:commit] == 'Ta bort markerade') && (params[:image_ids])
        params[:image_ids].each { |img_id|
          img = Image.find_by_id(img_id)
          if(img)
            img.destroy
          end
        }
        flash.now[:notice] = 'De markerade bilderna togs bort.'
      elsif(params[:commit] == 'Byt kategori') && (params[:image_ids]) && (params[:image_category])
        params[:image_ids].each { |img_id|
          img = Image.find_by_id(img_id)
          if(img)
            img.subcategory_id = params[:image_category]
            img.save()
          end
        }
        flash.now[:notice] = 'De markerade bilderna har nu kategorin: '+Subcategory.find_by_id(params[:image_category]).text
      end
    end
  end

  def show    
    if (@album.images)
      @images = @album.images.order(foto_file_name: :asc)
      if params[:link].present?
        @image = @images.where(id: params[:link]).first
        if @image.nil?
          @image = @images.first
          @status = "Det var en dålig länk"
        end
      else
        @image = @images.first
      end
    end
  end
  def new
    @album = Album.new
  end
  
  def create
      @album = Album.new(album_params)      
      @album.update(author: current_user.profile)    
      respond_to do |format|
        if @album.save                        
          format.html { redirect_to @album, notice: 'Albumet skapades!' }
          format.json { render :json => @album, :status => :created, :location => @album }
        else
          format.html { render action: "new" }
          format.json { render json: @album.errors, status: :unprocessable_entity }
        end
      end
  end
    
  def destroy    
    @album.destroy
    respond_to do |format|
      format.html { redirect_to albums_url,notice: 'Albumet raderades.' }
      format.json { head :no_content }
    end
  end
  def destroy_images
    respond_to do |format|
      if @album.destroy_images
        format.html { redirect_to @album, notice: 'Bilderna tog borts!' }
        format.json { render :json => @album, :location => @album }
      end
    end
  end
  def upload_images
    if (params[:fotos]) && (params[:subcategory_id])
        #===== The magic is here ;)
        @count = 1
        @total = params[:fotos].count
          params[:fotos].each { |foto|
            flash[:notice] =("Laddar upp "+@count.to_s+"/"+@total.to_s)
            @album.images.create(foto: foto,subcategory_id: params[:subcategory_id])
            @count = @count+1;
          }
          flash[:notice] =("Färdig!   Laddat upp "+@total.to_s+" bilder.")
    end    
  end
  def update
    respond_to do |format|
      if @album.update(album_params)
        format.html { redirect_to edit_album_path(@album), :notice => 'Albumet uppdaterades!' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @album.errors, :status => :unprocessable_entity }
      end
    end
  end  
private
  def authenticate
    flash[:error] = t('the_role.access_denied')
    redirect_to(:back) unless (current_user) && (current_user.moderator?(:galleri))
    
    rescue ActionController::RedirectBackError
      redirect_to root_path
  end
  def categories
     @categories = Category.cats
  end
  def set_album
    @album = Album.find_by_id(params[:id])
  end
  def image_params
    params.fetch(:image,{}).permit(:album_id,:subcategory_id)
  end
  def album_params
    params.fetch(:album,{}).permit(:title,:description,:author,:location,:public,:start_date,:end_date,:category_ids => [])
  end
end