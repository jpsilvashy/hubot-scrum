# Scrumbot!

Remember Funscrum!? Of course you do! Wouldn't it be great if you could do a daily scrum by talking directly to your bot on Slack or Hipchat?!

Scrumbot bugs your teammembers every morning, then annouces everyone's scrum at a specific time.

http://tech.co/wp-content/uploads/2012/12/Screen-Shot-2012-12-06-at-2.03.43-PM.png

## Installing

Add dependency to `package.json`:

```console
$ npm install --save hubot-scrum
```

Include package in Hubot's `external-scripts.json`:

```json
["hubot-scrum"]
```

## Configuration

Scrumbot has some default settings, if you want to recieve emails you need to provide a Mailgun api key and a few other details. These are optional to use scrumbot, but greatly improve the experience!
    
    HUBOT_SCRUM_MAILGUN_APIKEY=key-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    HUBOT_SCRUM_MAILGUN_EMAIL=scrumbot@example.com

If you don't have a mailgun api key, [get one here](https://mailgun.com/signup).

## Commands

    hubot scrum                            # start scrum
    hubot what is <username> doing today?  # what has <username> entered for their scrum today?
    hubot scrum help                       # displays this help message


## Development

The best way is to use `npm link`:

```
hubot-scrum$ npm link
hubot-scrum$ cd /path/to/your/hubot
hubot$ npm link hubot-scrum
hubot$ bin/hubot
