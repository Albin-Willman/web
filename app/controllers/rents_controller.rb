# encoding:UTF-8
class RentsController < ApplicationController  
  before_filter :authenticate, only: [:forman]
  before_action :set_rents, only: [:new,:edit,:create,:update]
  before_action :set_rent, except: [:main,:new,:forman,:index,:create]
 # before_action :set_edit, only: [:edit,:show]
  def main
    @faqs =  Faq.where.not(answer: '').where(category: 'Bil')
    respond_to do |format|      
        format.html 
        format.json { render :json => Rent.where(d_from: params[:start].to_date-10.days..params[:end].to_date+10.days).where.not(status:"Nekad")}
    end 
  end
  def new    
    @avtal = Document.where(title: "Regler för Beerit").first
    @rent = Rent.new
    if(current_user)
      @rent.prepare(current_user.profile)
      @utskott = @profile.car_councils
    end    
  end

  def show
  end

  def edit   
    if @rent.profile
      @profile = @rent.profile
      @utskott = @rent.profile.car_councils
      @rents = @rents - [@rent]
      for @post in @profile.posts do
        if @post.car_rent == true
          @utskott << @post.council
        end
      end
    end
    
  end
  def create
    @rent = Rent.new(rent_params)
    if (current_user)
      @rent.profile = current_user.profile
      @rent.status = "Bekräftad"
    end    
    respond_to do |format|
      if @rent.save
        RentMailer.rent_email(@rent).deliver
        if(current_user)        
          format.html { redirect_to @rent, :notice => 'Bokningen skapades!' }
        else
          format.html { redirect_to rents_path, :notice => 'Bokningen skapades, du ska ha fått ett mejl till angiven epostadress (möjligen i skräppost)!' }
        end
          format.json { render :json => @rent, :status => :created, :location => @rent }
        
      else
        @rent.disclaimer = false
        if(current_user)
          @profile = current_user.profile
        end
        format.html { render :action => "new" }
        format.json { render :json => @rent.errors, :status => :unprocessable_entity }
      end
    end
  end
  def update
    respond_to do |format|
      if @rent.update(rent_params)        
        format.html { redirect_to edit_rent_path(@rent), :notice => 'Bokningen uppdaterades.' }
        format.json { render :json => @rent, :status => :created, :location => @rent }
      else        
        format.html { render :action => "edit" }
        format.json { render :json => @rent.errors, :status => :unprocessable_entity }
      end      
    end
  end
  def update_status
    respond_to do |format|
      status = @rent.status
      aktiv = @rent.aktiv
      @rent.attributes = status_params 
      if @rent.save(validate: false)
        if(status != @rent.status) && (@rent.status != "Ej bestämd")
          RentMailer.status_email(@rent).deliver
        end
        if(aktiv != @rent.aktiv)
          RentMailer.active_email(@rent).deliver
        end
        format.html { redirect_to rent_path(@rent), :notice => 'Bokningen uppdaterades.' }
        format.json { render :json => @rent, :status => :created, :location => @rent }
      else        
        format.html { redirect_to :action => "show" }
        format.json { render :json => @rent.errors, :status => :unprocessable_entity }
      end      
    end
  end
  def destroy    
    @rent.destroy
    respond_to do |format|
      format.html { redirect_to :bil,notice: 'Bokningen raderades.' }
      format.json { head :no_content }
    end
  end


  # Varje användares sida om 
  def index
    if (current_user)
      @bokningar = current_user.profile.rents.order('d_from desc')
      render :action => 'user_index'
    else
      redirect_to(action: 'main')
    end
  end
  
  private
    #Till för att se om någon är admin.
    def authenticate
      redirect_to(:bil, alert: t('the_role.access_denied')) unless current_user && current_user.moderator?(:bil)
    end
    #Ser till att ett Rent-objekt hittas för det ID som kommer i parametern, annars gör den redirect.
    def set_rent
      @rent = Rent.find_by_id(params[:id])       
      if(@rent == nil)        
        flash[:notice] = 'Hittade ingen bilbokning med det ID:t.'
        redirect_to(:bil)        
      end
    end
    #@rents används t.ex. för att visa andra bokningar när man själv gör sin bokning
    def set_rents
      id = params[:id] || nil
      @rents = Rent.active.date_overlap(Time.zone.now,Time.zone.now+30.days,id).limit(10).ascending
    end
    def rent_params
      params.require(:rent).permit(:d_from,:d_til,:name,:lastname,:email,:phone,:purpose,:disclaimer,:council_id,:status,:aktiv, :comment,:service)
    end
    def status_params
      params.require(:rent).permit(:status,:aktiv,:comment)
    end
end
