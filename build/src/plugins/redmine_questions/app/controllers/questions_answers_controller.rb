class QuestionsAnswersController < ApplicationController
  unloadable

  before_action :find_question, :only => [:new, :create]
  before_action :find_answer, :only => [:update, :destroy, :edit, :show]

  helper :questions
  helper :watchers
  helper :attachments

  include QuestionsHelper

  def new
    @answer = QuestionsAnswer.new(:question => @question_item)
  end

  def edit
    (render_403; return false) unless @answer.editable_by?(User.current)
  end

  def update
    (render_403; return false) unless @answer.editable_by?(User.current) || User.current.allowed_to?(:accept_answers, @project)
    @answer.safe_attributes = params[:answer]
    @answer.save_attachments(params[:attachments])
    if @answer.save
      flash[:notice] = l(:label_answer_successful_update)
      respond_to do |format|
        format.html { redirect_to_question }
      end
    else
      respond_to do |format|
        format.html { render :edit}
      end
    end
  end

  def create
    @answer = QuestionsAnswer.new
    @answer.author = User.current
    @answer.question = @question_item
    @answer.safe_attributes = params[:answer]
    @answer.save_attachments(params[:attachments])
    if @answer.save
      flash[:notice] = l(:label_answer_successful_added)
      render_attachment_warning_if_needed(@answer)
    end
    redirect_to_question
  end

  def destroy
    if @answer.destroy
      flash[:notice] = l(:notice_successful_delete)
      respond_to do |format|
        format.html { redirect_to_question }
        format.api { render_api_ok }
      end
    else
      flash[:error] = l(:notice_unsuccessful_save)
    end
  end

  def preview
    if params[:id].present? && answer = Question.find_by_id(params[:id])
      @previewed = answer
    end
    @text = (params[:answer] ? params[:answer][:content] : nil)
    render :partial => 'common/preview'
  end

  private

  def redirect_to_question
    redirect_to question_path(@answer.question, :anchor => "questions_answer_#{@answer.id}")
  end

  def find_answer
    @answer = QuestionsAnswer.find(params[:id])
    @question_item = @answer.question
    @project = @question_item.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_question
    @question_item = Question.visible.find(params[:question_id]) unless params[:question_id].blank?
    @project = @question_item.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
