{div, h1, a, img, span, table, tbody, tr, td} = React.DOM

Container = React.createClass
  displayName: 'UserSelector'
  getInitialState: ->
    users: []

  get: ->
    aja()
      .method 'get'
      .url '/api/users'
      .on 'success', (res)=>
        @setState
          users: res
      .go()

  componentDidMount: -> @get()

  styles:
    title:
      fontSize: '4.5em'
      backgroundColor: '#F9D800'
      marginTop: '0'
      paddingBottom: '3%'
      textAlign: 'center'
    row:
      fontSize: '6em'
    td:
      paddingTop: '3%'
      paddingBottom: '3%'
    a:
      textDecoration: 'none'
      color: '#0661ad'
    img:
      width: '80px'
      height: '80px'
      marginLeft: '.6em'

  usersElements: ->
    @state.users.map (user, i)=>
      trClass = if (i % 2) is 1 then 'pure-u-1 pure-table-odd' else 'pure-u-1'
      tr {key: "#{user._id}-tr", className: trClass, style: @styles.row, 'data-id': user._id}, [
        td {key: "#{user._id}-td-picture", className: 'pure-u-5-24', style: @styles.td}, [
          img {key: "#{user._id}-picture", src: user.picture, style: @styles.img}
        ]
        td {key: "#{user._id}-td-name", className: 'pure-u-3-4', style: @styles.td}, [
          a {key: "#{user._id}-name", href: "/user/#{user._id}", style: @styles.a}, user.name
        ]
      ]

  render: ->
    div {key: 'container', className: 'pure-g'}, [
      h1 {key: 'title', className: 'pure-u-1', style: @styles.title}, '自分の名前を選んでください'
      table {key: 'table', className: 'pure-u-1 pure-table-horizontal'}, [
        tbody {key: 'tbody', className: 'pure-u-1'}, [
          @usersElements()
        ]
      ]
    ]

React.render React.createElement(Container), document.body
