# encoding:UTF-8
class NewsController < ApplicationController
  load_and_authorize_resource
  
  def index  
    @news = News.all.order('updated_at desc').limit 5
  end

  def show    
  end

  def new
  end

  def edit
  end

  def create
    @news.profile = current_user.profile        
    @news.save!
    redirect_to News
  end

  def update
    @news.save!
    redirect_to @news
  end

  def destroy
    @news.destroy!
    redirect_to News
  end
end
