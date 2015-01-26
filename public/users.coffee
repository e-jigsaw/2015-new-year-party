if window.ANP is undefined then window.ANP = {}
{div, ul, ol, li, label, input, button} = React.DOM

window.ANP.Users = React.createClass
  displayName: 'Users'
  new: ->
    aja()
      .method 'post'
      .url '/api/users'
      .data
        name: @refs["#{@props.teamId}-new-user-name"].getDOMNode().value
        picture: @refs["#{@props.teamId}-new-user-picture"].getDOMNode().value
        _team: @props.teamId
      .on 'success', (res)=>
        @props.teamGet()
        @refs["#{@props.teamId}-new-user-name"].getDOMNode().value = ''
        @refs["#{@props.teamId}-new-user-picture"].getDOMNode().value = ''
      .go()

  update: (event)->
    id = event.target.getAttribute 'data-id'
    aja()
      .method 'post'
      .url "/api/user/#{id}"
      .data
        name: @refs["#{id}-name"].getDOMNode().value
        picture: @refs["#{id}-picture"].getDOMNode().value
        _team: @props.teamId
      .on 'success', => @props.teamGet()
      .go()

  remove: (event)->
    id = event.target.getAttribute 'data-id'
    aja()
      .method 'post'
      .url "/api/user/#{id}/remove"
      .on 'success', (res)=> @props.teamGet()
      .go()

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

  answerElements: (user)->
    as = user.answers.map (answer, i)->
      li {key: "#{user._id}-answer-#{i}"}, answer
    ol {key: "#{user._id}-answer-ol"}, as

  userElements: ->
    us = if @props.users.length is 0
      []
    else
      @props.users.map (user)=>
        u = [
          label {key: "#{user._id}-name-label"}, '名前:'
          input {key: "#{user._id}-name", defaultValue: user.name, disabled: !@props.isEdit, ref: "#{user._id}-name"}
        ]
        if @props.isEdit
          u = u.concat [
            label {key: "#{user._id}-picture-label"}, '写真URL:'
            input {key: "#{user._id}-picture", defaultValue: user.picture, ref: "#{user._id}-picture"}
            button {key: "#{user._id}-update", className: 'pure-button pure-button-primary', style: @styles.edit.primaryButton, onClick: @update, 'data-id': user._id}, '更新'
            button {key: "#{user._id}-remove", className: 'pure-button', style: @styles.edit.errorButton, onClick: @remove, 'data-id': user._id}, '削除'
          ]
        u.push @answerElements user
        li {key: user._id}, u
    if @props.isEdit
      us.push li {key: 'UsersNew'}, [
        label {key: 'UsersNewNameLabel'}, '名前:'
        input {key: "#{@props.teamId}-new-user-name", ref: "#{@props.teamId}-new-user-name"}
        label {key: 'UsersNewPictureLabel'}, '写真URL:'
        input {key: "#{@props.teamId}-new-user-picture", ref: "#{@props.teamId}-new-user-picture"}
        button {key: "#{@props.teamId}-new-user-button", className: 'pure-button pure-button-primary', style: @styles.edit.primaryButton, onClick: @new}, '追加'
      ]
    ul {key: 'UsersUl'}, us

  render: ->
    div {key: 'UsersContainer'}, [
      @userElements()
    ]
