# Tared Ltd web app

## Deployment

The Compose service joins the external Docker network named `docker` so the
reverse proxy can reach it on port `3001`. Create or connect the reverse proxy
to that network before starting this app, then deploy with:

```sh
docker network inspect docker
docker compose up --build -d
```
