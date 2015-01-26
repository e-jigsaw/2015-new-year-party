{div, h1, p, img, span, svg, rect, text} = React.DOM
socket = io()

Container = React.createClass
  displayName: 'Container'
  getInitialState: ->
    teams: []
    sortedTeams: []
    status: 'title'
    currentQuestion: 0
    questions: []
    currentTime: 0
    timer: 0

  get: ->
    aja()
      .method 'get'
      .url '/api/screen'
      .on 'success', (res)=>
        @setState
          currentQuestion: res.currentQuestion
          timer: res.timer
          status: res.status
        , =>
          if res.status is 'question-countdown'
            @setState
              currentTime: 0
            , => @timer()
          else if res.status is 'question-ready'
            @setState
              currentTime: 0
      .go()

  teamGet: ->
    aja()
      .method 'get'
      .url '/api/teams'
      .on 'success', (res)=>
        cloneRes = [].concat res
        cloneRes.sort (x, y)-> x.score < y.score
        @setState
          teams: res
          sortedTeams: cloneRes
      .go()

  questionGet: ->
    aja()
      .method 'get'
      .url '/api/questions'
      .on 'success', (res)=>
        @setState
          questions: res
      .go()

  componentDidMount: ->
    @get()
    @teamGet()
    @questionGet()
    socket.on 'statusUpdate', => @get()
    socket.on 'scoreUpdate', => @teamGet()
    socket.on 'changeQuestion', => @get()
    socket.on 'questionUpdate', => @questionGet()
    socket.on 'userUpdate', => @teamGet()
    socket.on 'timerUpdate', => @get()

  style:
    title:
      container:
        backgroundColor: '#262626'
        height: '100%'
        overflow: 'hidden'
      h1:
        textAlign: 'center'
        color: '#e2e2e2'
        fontSize: '5em'
      p:
        textAlign: 'center'
        color: '#e2e2e2'
        fontSize: '4em'
      img:
        textAlign: 'center'
      span:
        color: '#e2e2e2'
        fontSize: '4em'
        position: 'relative'
        top: '-0.8em'
    result:
      img:
        width: "#{parseInt(window.innerHeight / 5)}px"
        height: "#{parseInt(window.innerHeight / 5)}px"
      span:
        fontSize: '8em'
        color: '#f0f0f0'
    questionReady:
      container:
        textAlign: 'center'
      p:
        fontSize: '5em'
        color: '#f0f0f0'
        marginBottom: '0'
    questionResult:
      team: (index)->
        height: "#{parseInt(window.innerHeight / 2)}px"
        backgroundColor: switch index
          when 0 then '#0f9611'
          when 1 then '#1C2192'
          when 2 then '#b2580b'
          when 3 then '#992784'
      h1:
        color: '#f0f0f0'
      p:
        color: '#f0f0f0'
        marginBottom: '0'
      answer:
        color: '#f0f0f0'
        fontSize: '3em'
        margin: '0'
        wordBreak: 'break-all'
      img:
        width: '50px'
        height: '50px'
      span:
        position: 'relative'
        top: '-20px'
        paddingLeft: '5px'

  showTitle: ->
    div {key: 'titleContainer', className: 'pure-g', style: @style.title.container}, [
      div {className: 'pure-u-1', style: @style.title.img}, [
        span {key: 'logo', style: @style.title.span}, 'ロゴ'
      ]
      h1 {key: 'title', className: 'pure-u-1', style: @style.title.h1}, 'New-year Party'
      p {key: 'url', className: 'pure-u-1', style: @style.title.p}, 'http://anp.jgs.me'
    ]

  showResult: ->
    ts = for team, i in @state.sortedTeams
      div {}, [
        img {src: "/rank#{i+1}.png", style: @style.result.img}
        span {style: @style.result.span}, "#{team.name}チーム - #{team.score}pt"
      ]
    div {key: 'resultContainer'}, ts

  showQuestionReady: ->
    diff = 100 - ((100 / @state.timer) * @state.currentTime)
    div {style: @style.questionReady.container}, [
      p {style: @style.questionReady.p}, if @state.questions.length > 0 then @state.questions[@state.currentQuestion].body
      svg {viewBox: '0 0 400 400'}, [
        rect {x: 160, y: 0, width: 70, height: 100, fill: '#737373'}
        rect {x: 160, y: 100 - diff, width: 70, height: diff, fill: '#ece524'}
        text {x: 180, y: 95, fill: '#ea0000'}, "#{@state.timer - @state.currentTime}秒"
      ]
    ]

  showQuestionResult: ->
    ts = for team, i in @state.teams
      us = for user in team.members
        div {className: "pure-u-1-#{team.members.length}", style: @style.questionResult.p}, [
          img {src: user.picture, style: @style.questionResult.img}
          span {style: @style.questionResult.span}, user.name
          p {style: @style.questionResult.answer}, user.answers[@state.currentQuestion]
        ]
      div {className: 'pure-u-1-2', style: @style.questionResult.team(i)}, [
        h1 {style: @style.questionResult.h1}, "#{team.name}チーム"
        us
      ]
    div {className: 'pure-g'}, ts

  showQuestionCountDown: ->
    @showQuestionReady()

  timer: ->
    setTimeout =>
      @setState
        currentTime: @state.currentTime + 1
      , =>
        if (@state.currentTime < @state.timer) and @state.status is 'question-countdown' then @timer()
    , 1000

  statusSwitcher: ->
    switch @state.status
      when 'title' then @showTitle()
      when 'result' then @showResult()
      when 'question-ready' then @showQuestionReady()
      when 'question-countdown' then @showQuestionCountDown()
      when 'question-result' then @showQuestionResult()

  render: ->
    div {style: @style.title.container}, [
      @statusSwitcher()
    ]

React.render React.createElement(Container), document.body
