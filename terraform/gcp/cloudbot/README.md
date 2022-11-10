# cloudbot

[![Bandit Python Security Check](https://github.com/DEAD10C5/bot-n0ctilucent/actions/workflows/bandit.yml/badge.svg)](https://github.com/DEAD10C5/bot-n0ctilucent/actions/workflows/bandit.yml)

* Type `make` to build the docker image.
  * Type `docker image ls` to see it in your list.
  * Tag the image like so: `docker tag <IMAGE_ID> frank378/cloudbot:dev_franklin_cloudbot`
* Type `docker login --username frank378` to log in to docker hub.
  * Use personal access token as pass since 2fa is enabled.
* Push the tagged image to dockerhub
  * Example: `docker push frank378/cloudbot:dev_franklin_cloudbot`

## testing

```sh
python3 -m venv venv
. venv/bin/activate.fish
python3 -m pip install -rrequirements.txt
python3 -m cloudbot
```

## Heroku

* The `Procfile` is how the app gets started on Heroku
