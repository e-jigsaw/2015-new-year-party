if window.ANP is undefined then window.ANP = {}
{div, h1, form, input, ul, li, label, select, option, span} = React.DOM
socket = io()

window.ANP.ScreenController = React.createClass
  displayName: 'ScreenController'
  getInitialState: ->
    status: 'title'
    timer: 60
    currentQuestion: 0
    questionLength: 1

  checkedElement: ->
    for ref in ['title', 'result', 'question-ready', 'question-countdown', 'question-result']
      if @refs[ref].getDOMNode().checked then return @refs[ref].getDOMNode()

  get: ->
    aja()
      .method 'get'
      .url '/api/screen'
      .on 'success', (screen)=>
        @setState
          status: screen.status
          timer: screen.timer
          currentQuestion: parseInt(screen.currentQuestion) + 1
      .go()

  changeDisplay: ->
    aja()
      .method 'post'
      .url '/api/screen/status'
      .data
        status: @checkedElement().value
      .on 'success', => @get()
      .go()

  changeQuestion: (event)->
    aja()
      .method 'post'
      .url '/api/screen/question'
      .data
        question: parseInt(event.target.value) - 1
      .on 'success', => @get()
      .go()

  timerUpdate: (event)->
    timer = event.target.value
    @setState
      timer: timer
    aja()
      .method 'post'
      .url '/api/screen/timer'
      .data
        timer: timer
      .on 'success', => @get()
      .go()

  questionUpdate: ->
    aja()
      .method 'get'
      .url '/api/questions'
      .on 'success', (res)=>
        @setState
          questionLength: res.length
      .go()

  componentDidMount: ->
    @get()
    @questionUpdate()
    socket.on 'questionUpdate', => @questionUpdate()

  screenStatus: (opt)->
    check = if @state.status is opt.value then true else false
    li {key: "ScreenController#{opt.value}"}, [
      input {key: "ScreenController#{opt.value}Radio", id: opt.value, type: 'radio', name: 'status', value: opt.value, checked: check, onChange: @changeDisplay, ref: opt.value}
      label {key: "ScreenController#{opt.value}Label", htmlFor: opt.value}, opt.label
    ]

  render: ->
    options = for i in [1..@state.questionLength]
      option {key: "ScreenControllerOption#{i}",value: i}, i
    div {key: 'ScreenControllerContainer'}, [
      h1 {key: 'ScreenControllerTitle'}, 'スクリーン操作'
      form {key: 'ScreenControllerForm'}, [
        ul {key: 'ScreenControllerUl'}, [
          @screenStatus.apply @, [{value: 'title', label: 'タイトル'}]
          @screenStatus.apply @, [{value: 'result', label: '結果発表'}]
          @screenStatus.apply @, [{value: 'question-ready', label: 'お題表示'}]
          @screenStatus.apply @, [{value: 'question-countdown', label: 'お題開始'}]
          @screenStatus.apply @, [{value: 'question-result', label: 'お題結果'}]
          li {key: 'ScreenControllerChangeQuestion'}, [
            span {key: 'ScreenControllerCangeQuestionTitle'}, 'お題の変更:'
            select {key: 'ScreenControllerChangeQuestionSelect', value: @state.currentQuestion, onChange: @changeQuestion}, options
          ]
          li {key: 'ScreenControllerChangeTimer'}, [
            span {key: 'ScreenControllerChangeTimerLabel'}, 'タイマー:'
            input {key: 'ScreenControllerChangeInput', value: @state.timer, onChange: @timerUpdate, size: 4}
            span {key: 'ScreenControllerChangeTimerSuffix'}, 'sec'
          ]
        ]
      ]
    ]
