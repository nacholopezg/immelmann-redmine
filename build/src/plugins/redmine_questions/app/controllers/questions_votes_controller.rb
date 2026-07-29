class QuestionsVotesController < ApplicationController
  before_action :find_vote_source

  helper :questions

  def create
    if !QuestionsSettings.vote_own? && @vote_source.author == User.current
      render_403
      return false
    end

    voter = User.current.becomes(Principal)
    if !User.current.voted_on?(@vote_source)
      params[:up] ? @vote_source.vote_up(voter) : @vote_source.vote_down(voter)
      flash[:notice] = l(:label_questions_vote_added) unless request.xhr?
    elsif User.current.voted_up_on?(@vote_source) && params[:down] || User.current.voted_down_on?(@vote_source) && params[:up]
      @vote_source.unvote_by(voter)
      flash[:notice] = l(:label_questions_vote_removed) unless request.xhr?
    end

    respond_to do |format|
      format.html { redirect_to_question }
      format.js
    end
  end

  private

  def find_vote_source
    vote_source_type = params[:source_type]
    vote_source_id = params[:source_id]

    klass = Object.const_get(vote_source_type.camelcase)
    @vote_source = klass.find(vote_source_id)
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def redirect_to_question
    question = @vote_source.is_a?(QuestionsAnswer) ? @vote_source.question : @vote_source
    redirect_to question_path(question, :anchor => @vote_source.is_a?(QuestionsAnswer) ? "question_item_#{@vote_source.id}" : '')
  end
end
