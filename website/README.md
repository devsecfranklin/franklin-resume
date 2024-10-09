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
