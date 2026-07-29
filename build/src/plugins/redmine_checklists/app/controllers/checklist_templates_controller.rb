class ChecklistTemplatesController < ApplicationController
  unloadable

  before_action :find_checklist_template, :except => [:new, :create, :index]
  before_action :find_optional_project, :only => [:new, :create, :add, :destroy, :edit, :update]
  before_action :require_admin, :only => [:index]

  def new
    @checklist_template = ChecklistTemplate.new
    @checklist_template.user = User.current
    @checklist_template.project = @project
    @checklist_template.is_public = false unless User.current.allowed_to?(:manage_checklist_templates, @project) || User.current.admin?
  end

  def create
    @checklist_template = ChecklistTemplate.new
    @checklist_template.safe_attributes = params[:checklist_template]
    @checklist_template.user = User.current
    @checklist_template.project = params[:checklist_template_is_for_all] && User.current.admin? ? nil : @project
    @checklist_template.is_public = false unless User.current.allowed_to?(:manage_checklist_templates, @project) || User.current.admin?

    if @checklist_template.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to_project_or_global
    else
      render :action => 'new', :layout => !request.xhr?
    end
  end

  def edit
  end

  def update
    @checklist_template.safe_attributes = params[:checklist_template]
    @checklist_template.project = nil if params[:checklist_template_is_for_all]
    @checklist_template.project = @project if params[:checklist_template][:is_public] == '1' && !User.current.admin?
    @checklist_template.project = (params[:checklist_template_is_for_all] && User.current.admin?) ? nil : @project
    @checklist_template.is_public = false unless User.current.allowed_to?(:manage_checklist_templates, @project) || User.current.admin?

    if @checklist_template.save
      flash[:notice] = l(:notice_successful_update)
      redirect_to_project_or_global
    else
      render :action => 'edit'
    end
  end

  def destroy
    @checklist_template.destroy
    redirect_to_project_or_global
  end

private
  def redirect_to_project_or_global
    redirect_to @project ? settings_project_path(@project, :tab => 'checklist_template') : {:action => "plugin", :id => "redmine_checklists", :controller => "settings", :tab => 'checklist_templates'}
  end

  def find_issue
    @issue = Issue.find(params[:issue_id])
    @project = @issue.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_checklist_template
    template_scope = ChecklistTemplate.where(:id => params[:id].to_i)
    template_scope = template_scope.where('user_id = ? OR is_public = ?', User.current.id, true) unless User.current.admin?
    @checklist_template = template_scope.first
    raise ActiveRecord::RecordNotFound unless @checklist_template.present?
    @project = @checklist_template.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end

end
