# Testing

## Call Cloud Function from external

* Test with CURL from your local machine.
* Your [service account must be a valid "invoker"](https://cloud.google.com/functions/docs/securing/authenticating) for the Cloud Function.

```sh
gcloud config set account fdiaz-bot@gcp-gcs-pso.iam.gserviceaccount.com
gcloud auth login
curl -X POST https://us-central1-gcp-gcs-pso.cloudfunctions.net/cloudbot-franklin  -H "Content-Type:application/json"  -d '{"message":"franklin"}' -H "Authorization: Bearer $(gcloud auth print-identity-token)"
```

## Test with nix-shell

```sh
nix-shell
python3 -m pip install tox
tox -e flake8
tox -e py38
```

## security test

```sh
bandit --configfile .bandit -x .tox,docs,.coveragerc,.dockerignore,_build -s B101,B105,B108,B320,B410,B501 -r src/
safety check -r src/requirements.txt
safety check -r tests/requirements-test.txt
safety check -r test/requirements-security.txt
```

## Container Image

* Type `make` to build the docker image.
  * Type `docker image ls` to see it in your list.
  * Tag the image like so: `docker tag <IMAGE_ID> frank378/cloudbot:dev_franklin_cloudbot`
* Type `docker login --username frank378` to log in to docker hub.
  * Use personal access token as pass since 2fa is enabled.
* Push the tagged image to dockerhub
  * Example: `docker push frank378/cloudbot:dev_franklin_cloudbot`
