# Local Resume

## Run Python3/Flask Application in local Docker Container

- You must have Docker installed on your machine.
- Type 'make app' to start the docker environment.
- Navigate to [http://0.0.0.0:5000/](http://0.0.0.0:5000/)

## Create Docker Instance to Log in and Run `pytest`

- Type 'make docker' to build the local environment.
- Docker will setup up container and put you in the project directory.
- Test like so:

```fish
make local-dev
pytest
py.test
tox -e pylint
tox -e venv
```
