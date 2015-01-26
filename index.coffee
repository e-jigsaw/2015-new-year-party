express = require 'express'
bodyParser = require 'body-parser'
stylus = require('stylus').middleware
coffee = require 'coffee-middleware'
app = express()

http = require('http').Server app
io = require('socket.io')(http)

mongoose = require 'mongoose'
db = mongoose.createConnection process.env.MONGOLAB_URI

User = db.model 'User',
  name: String
  picture: String
  answers: [String]
  _team:
    type: mongoose.Schema.Types.ObjectId
    ref: 'Team'

Question = db.model 'Question',
  body: String

Team = db.model 'Team',
  name: String
  score: Number
  members: [{type: mongoose.Schema.Types.ObjectId, ref: 'User'}]

Screen = db.model 'Screen',
  status: String
  timer: Number
  currentQuestion: Number

app.set 'views', "#{__dirname}/views"
app.set 'view engine', 'jade'
app.use bodyParser.urlencoded
  extended: false
app.use coffee
  src: "#{__dirname}/public"
app.use stylus
  src: "#{__dirname}/public"
app.use express.static "#{__dirname}/public"

localBodyParser = (body)->
  str = Object.keys(body)[0] + '=' + body[Object.keys(body)[0]]
  str = str.split '\n\r'
  res = {}
  str.forEach (item)->
    item = item.split '='
    if item[0].length > 0 then res[item[0]] = item[1]
  res

app.get '/', (req, res)-> res.render 'index'
app.get '/users', (req, res)-> res.render 'users'
app.get '/user/:id', (req, res)-> res.render 'userpage'
app.get "/#{process.env.CONSOLE_HASH}", (req, res)-> res.render 'console'
app.get '/screen', (req, res)-> res.render 'screen'

app.get '/api/questions', (req, res)-> Question.find {}, (err, questions)-> res.json questions
app.post '/api/questions', (req, res)->
  body = localBodyParser req.body
  question = new Question
    body: body.body
  question.save (err)->
    res.send err
    io.emit 'questionUpdate'
app.post '/api/question/:id', (req, res)->
  body = localBodyParser req.body
  Question.findByIdAndUpdate req.params.id, {body: body.body}, (err)->
    res.send err
    io.emit 'questionUpdate'
app.post '/api/question/:id/remove', (req, res)-> Question.findByIdAndRemove req.params.id, (err)->
  res.send err
  io.emit 'questionUpdate'
app.get '/api/teams', (req, res)-> Team.find({}).populate('members').exec (err, teams)-> res.json teams
app.post '/api/teams', (req, res)->
  body = localBodyParser req.body
  team = new Team
    name: body.name
    score: body.score
    members: []
  team.save (err)-> res.send err
app.post '/api/team/:id', (req, res)->
  body = localBodyParser req.body
  Team.findByIdAndUpdate req.params.id, {score: body.score}, (err)->
    res.send err
    io.emit 'scoreUpdate'
app.post '/api/team/:id/remove', (req, res)->
  Team.findById req.params.id, (err, team)->
    if err? then return res.send err
    team.members.forEach (id)-> User.findByIdAndRemove id, (err)->
    Team.findByIdAndRemove req.params.id, (err)-> res.send err
app.get '/api/users', (req, res)-> User.find {}, (err, users)-> res.json users
app.get '/api/user/:id', (req, res)-> User.findById(req.params.id).populate('_team').exec (err, user)-> res.json user
app.post '/api/users', (req, res)->
  body = localBodyParser req.body
  user = new User
    name: body.name
    picture: body.picture
    _team: body._team
  user.save (err)->
    if err? then return res.send err
    Team.findById body._team, (err, team)->
      team.members.push user._id
      team.save (err)-> res.send err
app.post '/api/user/:id', (req, res)->
  body = localBodyParser req.body
  User.findByIdAndUpdate req.params.id, {name: body.name, picture: body.picture}, (err)-> res.send err
app.post '/api/user/:id/remove', (req, res)-> User.findByIdAndRemove req.params.id, (err)-> res.send err
app.post '/api/user/:id/answer', (req, res)->
  body = localBodyParser req.body
  User.findByIdAndUpdate req.params.id, {answers: JSON.parse(body.answers)}, (err)->
    res.send err
    io.emit 'userUpdate'
app.get '/api/screen', (req, res)-> Screen.findOne {}, (err, screen)-> res.json screen
app.post '/api/screen/question', (req, res)->
  body = localBodyParser req.body
  Screen.findOneAndUpdate {}, {currentQuestion: body.question}, (err)->
    res.send err
    io.emit 'changeQuestion'
app.post '/api/screen/status', (req, res)->
  body = localBodyParser req.body
  Screen.findOneAndUpdate {}, {status: body.status}, (err)->
    res.send err
    io.emit 'statusUpdate'
app.post '/api/screen/timer', (req, res)->
  body = localBodyParser req.body
  Screen.findOneAndUpdate {}, {timer: body.timer}, (err)->
    res.send err
    io.emit 'timerUpdate'

port = process.env.PORT || 3000
http.listen port, -> console.log "Listening on #{port}"
