# Proxy Configuration

1. Determine which proxy server to use, for example `153.2.227.107`
2. echo your username and pass to base64 then encrypt it, like so:
    `echo "username:password" | base64 | openssl enc -aes-128-cbc -a`
3. Export this to your shell environment.

## Issues

- Opened case 03028240 for proxy issues in sandbox.
  - [Configuration for update server when static update server is used in Firewall](https://knowledgebase.paloaltonetworks.com/KCSArticleDetail?id=kA14u0000001UtRCAU)
