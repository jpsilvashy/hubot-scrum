# Description:
#   Team members enter their scrum and scrumbot will send a summary.
#
# Dependencies:
#    "cron": "",
#    "time": ""
#
# Configuration:
#   HUBOT_SCRUM_ROOM
#   HUBOT_SCRUM_NOTIFY_AT
#   HUBOT_SCRUM_CLEAR_AT
#   TZ # eg. "America/Los_Angeles"
#
# Commands:
#   hubot scrum
#   hubot what is <username> doing today?
#   hubot scrum help
#
# Optional Environment Variables:
#   TIMEZONE
#
# Notes:
#   We were sad to see funscrum die so we are making this now!
#
# Authors:
#   @jpsilvashy
#   @mmcdaris

##
# What room do you want to post the scrum summary in?
ROOM = process.env.HUBOT_SCRUM_ROOM

##
# Explain how to use the scrum bot
MESSAGE = """
 USAGE:
 hubot scrum                            # start your scrum
 hubot what is <username> doing today?  # look up other team member scrum activity
 hubot scrum help                       # displays help message
"""

##
# Default time to tell users to do their scrum
PROMPT_AT = process.env.HUBOT_SCRUM_PROMPT_AT || '0 0 6 * * *' # 6am everyday

##
# Default scrum reminder time
REMIND_AT = process.env.HUBOT_SCRUM_REMIND_AT || '0 30 11 * * *' # 11am everyday

##
# SEND the scrum at 10 am everyday
SUMMARY_AT = process.env.HUBOT_SCRUM_SUMMARY_AT || '0 0 12 * * *' # noon

##
# These are the keys that are required each day to earn points
REQUIRED_CATEGORIES = ["today", "yesterday"]

##
# Setup cron
CronJob = require("cron").CronJob

##
# Set to local timezone
TIMEZONE = process.env.TZ

# Models
# Team = require('./models/team')
Player = require('./models/player')
Scrum = require('./models/scrum')

##
# Robot
module.exports = (robot) ->

  ##
  # Initialize the scrum
  scrum = new Scrum(robot)

  ##
  # Response section
  robot.respond /today (.*)/i, (msg) ->
    player = Player.fromMessage(msg)
    player.entry("today", msg.match[1])

  robot.respond /whoami/i, (msg) ->
    player = Player.fromMessage(msg)
    msg.reply "Your name is: #{player.name}"

  robot.respond /scrum players/i, (msg) ->
    console.log scrum.players()
    list = scrum.players().map (player) -> "#{player.name}: #{player.score}"
    msg.reply list.join("\n") || "Nobody is in the scrum!"

  ##
  # Testing mailers
  robot.respond /scrum mail player/, (msg) ->
    player = Player.fromMessage(msg)
    player.mailSummary(scrum.team())

  robot.respond /scrum mail team/, (msg) ->
    scrum.team().mailSummary()

  ##
  # Testing mailers
  robot.respond /scrum dm player/, (msg) ->
    player = Player.fromMessage(msg)
    Player.dm(robot, player.name, "dm test to just #{player.real_name}")

  robot.respond /scrum dm team/, (msg) ->
    scrum.team().dm("dm test to team")

  ##
  # Test messages
  robot.respond /scrum prompt/, (msg) ->
    scrum.prompt()

  ##
  # Test messages
  robot.respond /scrum reminder/, (msg) ->
    scrum.reminder()

  ##
  # Test messages
  robot.respond /scrum summary/, (msg) ->
    scrum.summary()

  ##
  # Setup things that need scheduling
  schedule =
    prompt: (time) ->
      new CronJob(time, ->
        scrum.prompt()
        return
      , null, true, TIMEZONE)

    reminder: (time) ->
      new CronJob(time, ->
        scrum.reminder()
        return
      , null, true, TIMEZONE)

    summary: (time) ->
      new CronJob(time, ->
        scrum.summary()
        return
      , null, true, TIMEZONE)

  # Schedule the Reminder with a direct message so they don't forget
  # Don't send this if they already sent it in
  # instead then send good job and leaderboard changes + streak info
  schedule.prompt '0 0 16 * * *' # PROMPT_AT

  ##
  # Schedule reminder to let the user know they only have a little time
  # left to complete their scrum
  schedule.reminder '0 5 16 * * *' # PREMIND_AT

  ##
  # This will deliver the email and reset.
  schedule.summary '0 10 16 * * *' # PSUMMARY_AT

