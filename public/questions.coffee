if window.ANP is undefined then window.ANP = {}
{div, input, button, h1, ol, li, span} = React.DOM

window.ANP.Questions = React.createClass
  displayName: 'Questions'
  getInitialState: ->
    questions: []
    isEdit: false
    buttonMessage: '編集'

  get: ->
    aja()
      .url '/api/questions'
      .on 'success', (res)=>
        @setState
          questions: res
      .go()

  componentDidMount: -> @get()

  new: ->
    aja()
      .method 'post'
      .url '/api/questions'
      .data
        body: @refs.newQuestionInput.getDOMNode().value
      .on 'success', (res)=> if res is null then @get()
      .go()

  update: (event)->
    id = event.target.getAttribute 'data-id'
    aja()
      .method 'post'
      .url "/api/question/#{id}"
      .data
        body: @refs[id].getDOMNode().value
      .on 'success', (res)=> if res is null then @get()
      .go()

  remove: (event)->
    id = event.target.getAttribute 'data-id'
    aja()
      .method 'post'
      .url "/api/question/#{id}/remove"
      .on 'success', (res)=> if res is null then @get()
      .go()

  editToggle: ->
    msg = if !@state.isEdit then '完了' else '編集'
    @setState
      isEdit: !@state.isEdit
      buttonMessage: msg

  styles:
    edit:
      button:
        fontSize: '.5em'
        padding: '.2em'
      errorButton:
        backgroundColor: '#B8232A'
        color: '#fff'
        padding: '.2em'
      primaryButton:
        padding: '.2em'

  questionElements: ->
    qs = if @state.questions.length is 0
      []
    else
      @state.questions.map (question)=>
        if @state.isEdit
          li {key: "#{question._id}"}, [
            input {key: "#{question._id}-input", defaultValue: question.body, ref: question._id}
            button {key: "#{question._id}-button", className: 'pure-button pure-button-primary', style: @styles.edit.primaryButton, onClick: @update, 'data-id': question._id}, '更新'
            button {key: "#{question._id}-button-remove", className: 'pure-button', style: @styles.edit.errorButton, onClick: @remove, 'data-id': question._id}, '削除'
          ]
        else
          li {key: "#{question._id}"}, [
            input {key: "#{question._id}-input", defaultValue: question.body, disabled: true, ref: question._id}
          ]
    if @state.isEdit
      qs.push li {key: 'QuestionsNew'}, [
        input {key: 'question-new-input', ref: 'newQuestionInput'}
        button {key: 'question-new-button', className: 'pure-button pure-button-primary', style: @styles.edit.primaryButton, onClick: @new}, '追加'
      ]
    ol {key: 'QuestionsOl'}, qs

  render: ->
    div {key: 'QuestionsContainer'}, [
      h1 {key: 'QuestionsTitle'}, [
        span {key: 'QuestionsTitleBody'}, '質問一覧'
        button {key: 'QuestionsTitleButton', className: 'pure-button pure-button-primary', style: @styles.edit.button, onClick: @editToggle}, @state.buttonMessage
      ]
      @questionElements()
    ]
