class QuestionsCommentsController < ApplicationController
  before_action :find_comment_source

  helper :questions

  def create
    raise Unauthorized unless @comment_source.commentable?

    @comment = Comment.new
    @comment.safe_attributes = params[:comment]
    @comment.author = User.current
    if @comment_source.comments << @comment
      @comment_source.touch
      flash[:notice] = l(:label_comment_added) unless request.xhr?
    end

    respond_to do |format|
      format.html { redirect_to_question }
      format.js
    end
  end

  def edit
    @comment = @comment_source.comments.find(params[:id])
  end

  def update
    @comment = @comment_source.comments.find(params[:id])
    @comment.safe_attributes = params[:comment]
    if @comment.save
      flash[:notice] = l(:notice_successful_update)
      redirect_to_question
    else
      render :action => 'edit'
    end
  end

  def destroy
    @comment_source.comments.find(params[:id]).destroy
    redirect_to_question
  end

  private

  def find_comment_source
    comment_source_type = params[:source_type]
    comment_source_id = params[:source_id]

    klass = Object.const_get(comment_source_type.camelcase)
    @comment_source = klass.find(comment_source_id)
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def redirect_to_question
    question = @comment_source.is_a?(QuestionsAnswer) ? @comment_source.question : @comment_source
    redirect_to question_path(question, :anchor => @comment.blank? ? "#{@comment_source.class.name.underscore}_#{@comment_source.id}" : "comment_#{@comment.id}")
  end
end
