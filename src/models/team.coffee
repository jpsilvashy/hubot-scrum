client = require('../redis-store')
templates = require('../templates')

SCRUM_ROOMS = process.env.HUBOT_SCRUM_ROOMS || ["general"]

Player = require('./player')

class Team
  constructor: (robot) ->
    @robot = robot

  save: ->
    attrs =
      name: @name
      score: @score
    @robot.brain.set 'astroscrum-team', attrs
  
  name: ->
    @robot.adapter.client.team.name

  score: ->
    10

  players: ->
    players = []
    for own key, user of @robot.brain.data.users
      roles = user.roles or []
      if 'scrum' in roles
        players.push new Player(user)
    return players

  dm: (message) ->
    for player in @players()
      Player.dm(@robot, player.name, message)

  ##
  # Mail everyone on the team the the team summary email
  mailSummary: ->
    subject = templates().mailTeamSummarySubject(@)
    body = templates().mailTeamSummaryBody(@)
    for player in @players()
      player.mail(subject, body)

  ##
  # Send message to user if they don't have a scrum today
  messagePrompt: ->
    for player in @players()
      message = templates().messagePlayerPromptBody(player)
      Player.dm(@robot, player.name, message)

  ##
  # Send message to user if they don't have a scrum today
  messageReminder: ->
    for player in @players()
      message = templates().messagePlayerReminderBody(player)
      Player.dm(@robot, player.name, message)

  ##
  # Post the result of the scrum in the SCRUM_ROOMS
  postSummary: ->
    body = templates().messageTeamSummaryBody(@)
    for room in SCRUM_ROOMS
      @robot.send { room: room }, body

module.exports = Team

