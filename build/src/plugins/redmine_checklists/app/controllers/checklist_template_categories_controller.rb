class ChecklistTemplateCategoriesController < ApplicationController
  unloadable

  before_action :find_category, :only => [:destroy, :update, :edit]

  def create
    @category = ChecklistTemplateCategory.new
    @category.safe_attributes = params[:category]
    if @category.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to_list
    else
      render :action => 'new'
    end
  end

  def destroy
    @category.destroy
    redirect_to_list
  rescue
    flash[:error] = l(:label_finance_can_not_delete_category)
    redirect_to_list
  end

  def update
    @category.safe_attributes = params[:category]
    @category.insert_at(@category.position) if @category.position_changed?
    if @category.save
      respond_to do |format|
        format.html do
          flash[:notice] = l(:notice_successful_update)
          redirect_to_list
        end
        format.js { head 200 }
      end
    else
      respond_to do |format|
        format.html { render :action => 'edit' }
        format.js { head 422 }
      end
    end
  end

private

  def find_category
    @category = ChecklistTemplateCategory.find(params[:id])
  end

  def redirect_to_list
    redirect_to :action =>"plugin", :id => "redmine_checklists", :controller => "settings", :tab => 'checklist_template_categories'
  end
end
