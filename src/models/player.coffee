Module = require('../module')
Store = require('../store')

class Player extends Module
  @extend Store

  ##
  # Class functions
  @.find = (robot, name) ->
    users = robot.brain.usersForFuzzyName(name)
    if users.length is 1
      user = users[0]
    return new Player(user)

   @.dm = (robot, name, message) ->
    users = robot.brain.usersForFuzzyName(name)
    if users.length is 1
      user = users[0]
    robot.send { room: user.name }, message

  ##
  # Constructor
  constructor: (user) ->
    @name = user.name
    @email = user.email_address
    @score = 0

  ##
  # Instance functions
  prompt: (message) ->
    console.log message

  getScore: ->
    updateScore()
    return @score

  setScore: (redis_score) =>
    console.log("Setting Score to #{redis_score} from #{@score}")
    @score = redis_score

  updateScore: ->
    Store.client().zscore("scrum", @name, (err, resp) ->
      console.log("I am in updateScore, resp is: #{resp}")
      return @.setScore(resp)
    )

  awardPoints: ->
    Store.client().zadd("scrum", 10, @name)

  stats: ->
    console.log("#{@name} has #{@points} Points!")

  today: (message) ->
    scrum.entry(@name, "today", message)

  yesterday: (message) ->
    scrum.entry(@name, "yesterday", message)

  blockers: (message) ->
    scrum.entry(@name, "blockers", message)
  
  mail: (subject, body) ->
    mailgun.sendText "noreply+scrumbot@example.com", [
      ["#{@name} <#{@email}>"]
    ], subject, body, "noreply+scrumbot@example.com", {}, (err) ->
      if err
        console.log "[mailgun] Oh noes: " + err
      else
        console.log "[mailgun] Success!"
      return

module.exports = Player