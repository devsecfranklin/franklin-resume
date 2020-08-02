# Testing

## Tox & Pytest

Create Docker Instance to Log in and Run `pytest`

- You must have Docker installed and running locally.
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

## Test Coverage Reporting
