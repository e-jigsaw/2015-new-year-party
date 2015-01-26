if window.ANP is undefined then window.ANP = {}
{Users} = window.ANP
{div, ul, li, label, input, button, h1, span} = React.DOM
socket = io()

window.ANP.Teams = React.createClass
  displayName: 'Teams'
  getInitialState: ->
    teams: []
    isEdit: false
    buttonMessage: '編集'

  get: ->
    aja()
      .url '/api/teams'
      .on 'success', (res)=>
        @setState
          teams: res
      .go()

  new: ->
    aja()
      .method 'post'
      .url '/api/teams'
      .data
        name: @refs.newTeamName.getDOMNode().value
        score: @refs.newTeamScore.getDOMNode().value
      .on 'success', (res)=>
        if res is null then @get()
        @refs.newTeamName.getDOMNode().value = ''
        @refs.newTeamScore.getDOMNode().value = '0'
      .go()

  update: (event)->
    id = event.target.getAttribute 'data-id'
    aja()
      .method 'post'
      .url "/api/team/#{id}"
      .data
        score: @refs["#{id}-score"].getDOMNode().value
      .on 'success', (res)=> if res is null then @get()
      .go()

  remove: (event)->
    id = event.target.getAttribute 'data-id'
    aja()
      .method 'post'
      .url "/api/team/#{id}/remove"
      .on 'success', (res)=> if res is null then @get()
      .go()

  componentDidMount: ->
    @get()
    socket.on 'userUpdate', => @get()

  editToggle: ->
    msg = if !@state.isEdit then '完了' else '編集'
    @setState
      isEdit: !@state.isEdit
      buttonMessage: msg

  teamElements: ->
    ts = if @state.teams.length is 0
      []
    else
      @state.teams.map (team)=>
        t = [
          label {key: '#{team._id}-name-label'}, '名前:'
          input {key: "#{team._id}-name", defaultValue: team.name, disabled: !@state.isEdit, ref: "#{team._id}-name"}
          label {key: "#{team._id}-score-label"}, 'スコア:'
          input {key: "#{team._id}-score", defaultValue: team.score, disabled: !@state.isEdit, ref: "#{team._id}-score"}
        ]
        if @state.isEdit
          t.push button {key: "#{team._id}-button", className: 'pure-button pure-button-primary', style: @styles.edit.primaryButton, onClick: @update, 'data-id': team._id}, '更新'
          t.push button {key: "#{team._id}-button-remove", className: 'pure-button', style: @styles.edit.errorButton, onClick: @remove, 'data-id': team._id}, '削除'
        t.push React.createElement Users, {key: "#{team._id}-users", users: team.members, teamId: team._id, teamGet: @get, isEdit: @state.isEdit}
        li {key: team._id}, t
    if @state.isEdit
      ts.push li {key: 'TeamNew'}, [
        label {key: 'TeamNewNameLabel'}, '名前:'
        input {key: 'team-new-name', ref: 'newTeamName'}
        label {key: 'TeamNewScoreLabel'}, 'スコア:'
        input {key: 'team-new-score', defaultValue: '0', ref: 'newTeamScore'}
        button {key: 'team-new-button', className: 'pure-button pure-button-primary', style: @styles.edit.primaryButton, onClick: @new}, '追加'
      ]
    ul {key: 'TeamsUl'}, ts

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

  render: ->
    div {key: 'TeamsContainer'}, [
      h1 {key: 'TeamsTitle'}, [
        span {key: 'TeamsTitleBody'}, 'チーム一覧'
        button {key: 'TeamsTitleButton', className: 'pure-button pure-button-primary', style: @styles.edit.button, onClick: @editToggle}, @state.buttonMessage
      ]
      @teamElements()
    ]
