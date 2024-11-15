# website

```sh
make build
docker image ls | grep website # verify
make push
```

## Testing

```sh
docker run -it website bash # get a shell on the container
```

### Node

```sh
npm audit fix
```

### OpenBSD

You can do application testing but there is no `docker` in this build env.

```sh
doas pkg_add node
doas npm install -g npm@latest # upgrade npm
npm -v
npm audit fix # fix sec vulns
```
