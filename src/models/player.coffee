client = require('../redis-store')
templates = require('../templates')

##
# Set up your free mailgun account here: TODO
# Setup Mailgun
Mailgun = require('mailgun').Mailgun
mailgun = new Mailgun(process.env.HUBOT_MAILGUN_APIKEY)
from = process.env.HUBOT_SCRUM_MAILGUN_EMAIL || 'scrumbot@example.com'

class Player

  ##
  # Class functions
  @.find = (robot, name) ->
    users = robot.brain.usersForFuzzyName(name)
    if users.length is 1
      user = users[0]
    return new Player(user)

  @.fromMessage = (msg) ->
    return new Player(msg.envelope.user)

  @.dm = (robot, name, message) ->
    users = robot.brain.usersForFuzzyName(name)
    if users.length is 1
      user = users[0]
    robot.send { room: user.name }, message

  ##
  # Constructor
  constructor: (user) ->
    @real_name = user.real_name
    @name = user.name
    @email = user.email_address
    @score = 0

  # Adds the player's entry to the category
  entry: (category, message) ->
    @.givePoints(@email, category)
    key = @email + ":" + category
    client().lpush(key, message)

 # if the player has filled out a required category reward them
  givePoints: (category) ->
    unit = 5
    key = @email + ":" + category
    unless client().exists(key) is 0 and ["today", "yesterday"].indexOf(category)
      client().zadd("scrum", unit, @email)
      @score += unit

  getScore: ->
    updateScore()
    return @score

  setScore: (redis_score) ->
    console.log("Setting Score to #{redis_score} from #{@score}")
    @score = redis_score

  updateScore: ->
    client().zscore("scrum", @name, (err, resp) ->
      console.log("I am in updateScore, resp is: #{resp}")
      return @.setScore(resp)
    )

  awardPoints: ->
    client().zadd("scrum", 10, @name)

  stats: ->
    console.log("#{@name} has #{@points} Points!")

  today: (message) ->
    scrum.entry(@name, "today", message)

  yesterday: (message) ->
    scrum.entry(@name, "yesterday", message)

  blockers: (message) ->
    scrum.entry(@name, "blockers", message)

  ##
  # Mail everyone on the team the same subject and body
  mail: (subject, body) ->
    if mailgun._apiKey
      to = "#{@real_name} <#{@email}>"
      mailgun.sendRaw from, [to]
        , "From: #{from}" +
          "\nTo: " + to +
          "\nContent-Type: text/html; charset=utf-8" +
          "\nSubject: #{subject}" +
          "\n\n#{body}"
      , (err) ->
        if err
          console.error "[mailgun] Oh noes: " + err
        else
          console.log "[mailgun] Email sent to: #{to}"
      return
    else
      console.warn('[mailgun] api_key not found, set the env var HUBOT_MAILGUN_APIKEY')
      return

  ##
  # Mail everyone on the team the the team summary email
  mailSummary: (team) ->
    subject = templates().mailPlayerSummarySubject(@)
    body = templates().mailPlayerSummaryBody(team)
    @.mail(subject, body)

  mailSeasonEnd: ->

module.exports = Player

