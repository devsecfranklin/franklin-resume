```
 _____                _    _ _         ____                                
|  ___| __ __ _ _ __ | | _| (_)_ __   |  _ \ ___  ___ _   _ _ __ ___   ___ 
| |_ | '__/ _` | '_ \| |/ / | | '_ \  | |_) / _ \/ __| | | | '_ ` _ \ / _ \
|  _|| | | (_| | | | |   <| | | | | | |  _ <  __/\__ \ |_| | | | | | |  __/
|_|  |_|  \__,_|_| |_|_|\_\_|_|_| |_| |_| \_\___||___/\__,_|_| |_| |_|\___|
                                                                           
```

[![Build Status](https://travis-ci.org/theDevilsVoice/franklin-resume.svg?branch=master)](https://travis-ci.org/theDevilsVoice/franklin-resume) [![CircleCI](https://circleci.com/gh/theDevilsVoice/franklin-resume/tree/master.svg?style=svg)](https://circleci.com/gh/theDevilsVoice/franklin-resume/tree/master)

## Testing 

#### Run App on Localhost via Docker

- Type 'make local' to start the docker environment.
- Navigate to http://0.0.0.0:5000/

#### Create Docker Instance to Log in and Run `pytest`

- Type 'make local-dev' to build dev env. 
- Docker will setup up container and put you in the project directory. 
- Test like so:

```
pytest
py.test
```

## Heroku

Log in to see what's up: 

```
heroku run bash --app franklin-resume
```

Tail the logs

```
heroku logs --tail -a franklin-resume
```

Heroku Releases

```
curl -n https://api.heroku.com/apps/franklin-resume/releases/ \
          -H "Accept: application/vnd.heroku+json; version=3"
```
