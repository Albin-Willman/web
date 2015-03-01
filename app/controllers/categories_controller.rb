class CategoriesController < ApplicationController
  # before_action :login_required!
  # before_action :authenticate
  before_action :set_categories, only: [:index]
  before_action :set_category, except: [:index, :new]


  def index
    @categories = Category.sups
    @subcategories = Categorys.subs
    @notice_grid = initialize_grid(@notices)
  end

  def show

  end

  def new
    @category = Category.new
  end

  def edit

  end

  def create
    @category = Category.new(category_params)
    respond_to do |format|
      if @category.save
        format.html { redirect_to @category, notice: %(#{t(:notice)} #{t(:success_create)}.)}
        format.json { render action: 'show', status: :created, location: @category }
      else
        format.html { render action: 'new' }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @category.update(category_params)
        format.html { redirect_to @category, notice: %(#{t(:notice)} #{t(:success_update)}.) }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @category.destroy
    respond_to do |format|
      format.html { redirect_to category_url }
      format.json { head :no_content }
    end
  end

private
  def category_params
    params.require(:category).permit(:title,:description,:sub)
  end

  def set_categories
    if
      @categories = Category.sups
      @subcategories = Category.subs
    end
  end
  def set_category
    @category = Category.find_by_id(params[:id])
  end
end
