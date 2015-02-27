class CategoriesController < ApplicationController
  before_action :login_required!
  before_action :authenticate
  before_action :set_owner
  before_action :set_categories, only: [:index]
  before_action :set_category

  def index
  end

  def show
  end

  def update
  end

  def create
  end

  def destroy
  end

private
  def set_owner
    #lite fulfix
    parent_class = %w[faq album]
    if klass = parent_class.detext {|pk| params[:"#{pk}_id"].present?}
      @owner = klass.camelize.constantize.find_by_id params[:"#{klass}_id"]
    end
  end

  def set_categories
    if !@owner.nil?
      @categories = @owner.categories.sups
    else
      @categories = Category
    end
  end

  def set_category
    @category = Category.find_by_id(params[:category_id])
  end
end
