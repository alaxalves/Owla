App.questionChannel = App.cable.subscriptions.create('QuestionsChannel', {
  received: function(data) {
    if (data.action === 'create_question'){
      return this.createQuestion(data);
    }
    else if (data.action === 'update_question'){
      return this.updateQuestion(data);
    }
    else if (data.action === 'delete_question'){
      return this.deleteQuestion(data);
    }
  },
  createQuestion: function(data) {
    if(data.slide_id){
      return $("#slide-" + data.slide_id)
             .find("#topic-question-box-" + data.topic_id)
             .append(data.html);
    } else {
      return $("#topic-question-box-" + data.topic_id)
             .append(data.html);
    }
  },
  updateQuestion: function(data) {
    return $("#question-" + data.question_id)
           .find(".question-content")
           .html(data.content);
  },
  deleteQuestion: function(data) {
   // this.updateQuestionCounter(data);
   // return $("#box-answer-" + data.answer_id).hide();
  },
});
