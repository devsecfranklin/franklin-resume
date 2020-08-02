# Platform as a Service

There is a Python3 Flask application running on Heroku.

## Testing

### Log in to Heroku to See What's Up

```bash
heroku run bash --app franklin-resume
```

### Tail the logs

```bash
heroku logs --tail -a franklin-resume
```

### Heroku Releases

```bash
curl -n https://api.heroku.com/apps/franklin-resume/releases/ \
          -H "Accept: application/vnd.heroku+json; version=3"