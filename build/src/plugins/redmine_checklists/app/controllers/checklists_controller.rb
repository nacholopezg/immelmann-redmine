class ChecklistsController < ApplicationController
  unloadable

  before_action :find_checklist_item, :except => [:index, :create]
  before_action :find_issue_by_id, :only => [:index, :create]
  before_action :authorize, :except => [:done]
  helper :issues

  accept_api_auth :index, :update, :destroy, :create, :show

  def index
    @checklists = @issue.checklists
    respond_to do |format|
      format.api
    end
  end

  def show
    respond_to do |format|
      format.api
    end
  end

  def destroy
    @checklist_item.destroy
    respond_to do |format|
      format.api { render_api_ok }
    end
  end

  def create
    @checklist_item = Checklist.new
    @checklist_item.safe_attributes = params[:checklist]
    @checklist_item.issue = @issue
    respond_to do |format|
      format.api {
        if @checklist_item.save
          render :action => 'show', :status => :created, :location => checklist_url(@checklist_item)
        else
          render_validation_errors(@checklist_item)
        end
      }
    end
  end

  def update
    @checklist_item.safe_attributes = params[:checklist]
    respond_to do |format|
      format.api {
        if @checklist_item.save
          render_api_ok
        else
          render_validation_errors(@checklist_item)
        end
      }
    end
  end

  def done
    (render_403; return false) unless User.current.allowed_to?(:done_checklists, @checklist_item.issue.project)

    # <PRO>
    old_checklist_items = @checklist_item.issue.checklists.to_a
    # </PRO>
    @checklist_item.is_done = params[:is_done] == 'true'

    if @checklist_item.save
      # <PRO>
      journal = Journal.new(:journalized => @checklist_item.issue, :user => User.current)
      checklist_items = Checklist.where(:issue_id => @checklist_item.issue.id).to_a
      detail = JournalDetail.new( :property => 'attr',
                                  :prop_key => 'checklist',
                                  :old_value => old_checklist_items.to_json.to_s,
                                  :value => checklist_items.to_json.to_s,
                                  :journal => journal
                                  )
      if JournalChecklistHistory.can_fixup?(detail)
        JournalChecklistHistory.fixup(detail)
      else
        journal.details << detail
      end
      journal.save unless journal.destroyed?
      # </PRO>
      if (Setting.issue_done_ratio == 'issue_field') && RedmineChecklists.issue_done_ratio?
        Checklist.recalc_issue_done_ratio(@checklist_item.issue.id)
        @checklist_item.issue.reload
      end
    end
    respond_to do |format|
      format.js
      format.html { redirect_to :back }
    end
  end

  private

  def find_issue_by_id
    @issue = Issue.find(params[:issue_id])
    @project = @issue.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_checklist_item
    @checklist_item = Checklist.find(params[:id])
    @project = @checklist_item.issue.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
