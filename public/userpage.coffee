{div, h1, input, a, ol, li, form} = React.DOM

Container = React.createClass
  displayName: 'Container'
  getInitialState: ->
    user:
      name: ''
      answers: []
      _team:
        name: ''
    questions: []

  getUser: ->
    id = location.pathname.split('/')[2]
    aja()
      .method 'get'
      .url "/api/user/#{id}"
      .on 'success', (res)=>
        if res.answers.length < @state.questions.length
          for i in [1..(@state.questions.length - res.answers.length)]
            res.answers.push ''
        @setState
          user: res
      .go()

  getQuestions: (callback)->
    aja()
      .method 'get'
      .url '/api/questions'
      .on 'success', (res)=>
        @setState
          questions: res
        , -> callback()
      .go()

  send: ->
    id = location.pathname.split('/')[2]
    qs = for i in [0..@state.questions.length-1]
      @refs["answer#{i}"].getDOMNode().value
    aja()
      .method 'post'
      .url "/api/user/#{id}/answer"
      .data
        answers: JSON.stringify qs
      .on 'success', (err)=> console.log err
      .go()

  componentDidMount: -> @getQuestions => @getUser()

  styles:
    title:
      fontSize: '4.5em'
      backgroundColor: '#F9D800'
      marginTop: '0'
      paddingBottom: '3%'
      textAlign: 'center'
    answer:
      fontSize: '3em'
      marginLeft: '5%'
      marginBottom: '3%'

  questionsElement: ->
    qs = for answer, i in @state.user.answers
      li {key: "questions#{i}-container", style: @styles.answer}, [
        input {key: "questions#{i}", defaultValue: answer, ref: "answer#{i}"}
        a {key: "questions#{i}-button", onClick: @send, className: 'pure-button pure-button-primary', href: '#'}, '回答'
      ]
    ol {key: 'questions', className: 'pure-u-1'}, [
      form {key: 'form', className: 'pure-form'}, qs
    ]

  render: ->
    div {key: 'container', className: 'pure-g'}, [
      h1 {key: 'teamAndName', className: 'pure-u-1', style: @styles.title}, "#{@state.user._team.name}チーム/#{@state.user.name}さん"
      @questionsElement()
    ]

React.render React.createElement(Container), document.body
