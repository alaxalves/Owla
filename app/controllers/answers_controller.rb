class AnswersController < ApplicationController
  include AnswerHelper
  skip_before_action :verify_authenticity_token if Rails.env.test?
  before_action :authenticate_member
  before_action :show, :only => [:like]

  def index
    @answers = Answer.all
  end

  def new
    @question = Question.find(params[:question_id])
    @answer = Answer.new
  end

  def show
    @answer = Answer.find(params[:id])
  end

  def create
    @question = Question.find(params[:question_id])
    @answer = Answer.new(answer_params)
    @answer.question = @question
    @answer.member = current_member

    if @answer.save
      send_cable @answer, 'create_answer'
    end
  end

  def edit
    @answer = Answer.find(params[:id])

    respond_to do |format|
      format.js {}
    end
  end

  def update
    @answer = Answer.find(params[:id])

    if params[:delete_attachment]
      delete_attachment @answer
    end

    if @answer.update_attributes(answer_params)
     send_cable @answer, 'update_answer'
    end
  end

  def destroy
    @answer = Answer.find(params[:id])
    @question = @answer.question

    if @answer.destroy
      send_cable @answer, 'delete_answer'
    end
  end

  def like
    @answer.member = current_member
    if not current_member.voted_up_on? @answer
      @answer.like_by(current_member)
    else
      @answer.disliked_by(current_member)
    redirect_to :back
    end
  end

  def moderate_answer
    answer = Answer.find(params[:id])
    @topic = answer.question.topic
    if current_member ==  @topic.room.owner
      answer.update_attributes(
        content: "This answer has been moderated because it's content was considered inappropriate",
        moderated: true)

      redirect_to topic_path(@topic)
    else
      flash[:notice] = "You do not have permission!"
    end
  end

  private

    def answer_params
      params.require(:answer).permit(:content, :question_id, :anonymous, :attachment)
    end

    def delete_attachment answer
      answer.attachment.destroy
    end
end
