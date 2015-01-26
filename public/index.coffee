{div, h1, p, a, button, img, span} = React.DOM

Container = React.createClass
  displayName: 'LandingPage'
  styles:
    container:
      textAlign: 'center'
    img:
      margin: '0 auto'
    h1:
      fontSize: '4em'
      marginTop: '0'
      marginBottom: '4em'
      backgroundColor: '#F9D800'
      padding: '5%'
    a:
      fontSize: '5em'
      margin: '0 auto'
    span:
      fontSize: '5em'
      position: 'relative'
      top: '-0.3em'

  render: ->
    div {key: 'container', className: 'pure-g', style: @styles.container}, [
      div {key: 'logoContainer', className: 'pure-u-1'}, [
        span {key: 'logo', style: @styles.span}, 'ロゴ'
      ]
      h1 {key: 'title', className: 'pure-u-1', style: @styles.h1}, 'New-year Party'
      a {key: 'link', href: '/users', className: 'pure-button pure-button-primary', style: @styles.a}, 'ユーザ選択'
    ]

React.render React.createElement(Container), document.body
