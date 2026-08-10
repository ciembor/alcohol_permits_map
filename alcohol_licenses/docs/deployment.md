# Deployment

Deployment is handled by the manual GitHub Actions workflow:

`Alcohol licenses deploy`

The workflow runs tests, builds a production container smoke test, and then calls
`scripts/deploy.sh` from the `alcohol_licenses` directory.

## GitHub configuration

Required repository variables:

- `ALCOHOL_LICENSES_DEPLOY_HOST` - SSH host used by the deploy job.

Optional repository variables:

- `ALCOHOL_LICENSES_PUBLIC_BASE_URL` - public base URL checked after deploy, for
  example `https://example.org`. When blank, deploy smoke checks only the local
  service on the server.

Required repository secrets:

- `SSH_PRIVATE_KEY_B64` - base64-encoded private key for the deploy user.
- `SSH_KNOWN_HOSTS` - known-hosts entry for `ALCOHOL_LICENSES_DEPLOY_HOST`.

## Server assumptions

The deploy script expects:

- SSH user `ciembor` by default through `REMOTE_HOST`.
- `podman`, `sudo`, `systemd`, `rsync`, and `curl` installed on the server.
- Writable application directory at `/home/ciembor/alcohol-licenses`.
- `/home/ciembor/alcohol-licenses/.env.local` containing `SECRET_KEY_BASE` with
  at least 64 characters before first deploy.

The systemd unit serves the app on `127.0.0.1:9294`. NGINX or another reverse
proxy should terminate TLS and proxy to that local port.

## Manual local deploy

```sh
REMOTE_HOST=ciembor@example.org scripts/deploy.sh deploy
REMOTE_HOST=ciembor@example.org scripts/deploy.sh rollback
```
