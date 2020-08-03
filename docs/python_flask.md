# Platform as a Service

Platform as a service (PaaS) or application platform as a service (aPaaS) or platform-based service is a category of cloud computing services that provides a platform allowing customers to develop, run, and manage applications without the complexity of building and maintaining the infrastructure typically associated with developing and launching an app.

[Heroku is a cloud platform](https://www.heroku.com/what) that lets companies build, deliver, monitor and scale applications.

I wrote a [Python3 Flask application and have it running on Heroku](https://franklin-resume.herokuapp.com/).

## Testing

Here are some resources and reminders for myself to manage my resume application.

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
```
