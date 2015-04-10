
##
# Setup Handlebars
Handlebars = require('handlebars')

module.exports = ->
  
  ##
  # Player mailer templates
  mailPlayerSummarySubject: (player) ->
    source = "[scrumbot] Today\'s summary"
    template = Handlebars.compile(source)
    template(player)
    
  mailPlayerSummaryBody: (team)->
    source = """
      Player summary for <strong>{{name}}</strong>:
      <ul>
      {{#each players}}
        <li><strong>{{real_name}}</strong> ({{score}})</li>
      {{/each}}
      </ul>
    """
    template = Handlebars.compile(source)
    template(team)
  
  ##
  # Team mailer templates
  mailTeamSummarySubject: (team) ->
    source = "[scrumbot] Weekly summary for {{name}}"
    template = Handlebars.compile(source)
    template(team)
    
  mailTeamSummaryBody: (team)->
    source = """
      Team summary for <strong>{{name}}</strong>:
      <ul>
      {{#each players}}
        <li><strong>{{real_name}}</strong> ({{score}})</li>
      {{/each}}
      </ul>
    """
    template = Handlebars.compile(source)
    template(team)

  ##
  # Message templates
  messageTeamSummaryBody: (team)->
    source = """
      Team summary for *{{name}}*:
      {{#each players}}
        • *{{real_name}}* ({{score}})
      {{/each}}
    """
    template = Handlebars.compile(source)
    template(team)

  messagePlayerReminderBody: (player) ->
    source = """
      Hey {{name}}, you didn't finish your scrum today!
    """
    template = Handlebars.compile(source)
    template(player)

  messagePlayerPromptBody: (player) ->
    source = """
      Hey {{name}}, are you ready to do your scrum?! Message me back with `scrum help` if you need any details on how to do your scrum.
    """
    template = Handlebars.compile(source)
    template(player)

