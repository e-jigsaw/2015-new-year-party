{div} = React.DOM
{Questions, ScreenController, Teams} = window.ANP

Console = React.createClass
  displayName: 'console'
  render: ->
    div {key: 'container'}, [
      React.createElement ScreenController, {key: 'screenController'}
      React.createElement Questions, {key: 'questions'}
      React.createElement Teams, {key: 'teams'}
    ]

React.render React.createElement(Console), document.body
