# ssh-client

Run the OpenSSH client in a container.

There are various use cases, one of which is to create a local SOCKS proxy on
the Podman host. This proxy forwards traffic through the SSH target host to the
destination.

## Build

```shell
cd ssh-client
podman build -t ssh-client .
```

## Run

### Show SSH Client Version

```shell
podman run --rm -it --name ssh-client ssh-client -V # runs `ssh -V`
```

### SOCKS Proxy

#### Basic

Create a SOCKS proxy listening on `127.0.0.1:1080` on the host that proxies
traffic through the SSH server at `target.example.com`.

```shell
podman run --rm -it \
  --name ssh-client \
  -p 127.0.0.1:1080:1080 \
  ssh-client \
  -D 0.0.0.0:1080 -4 -N target.example.com
```

#### Share Host's .ssh Folder and Agent Socket

To provide the container with your local `~/.ssh/` folder and SSH agent socket,
use Podman.

Unlike Docker, Podman offers a `--userns` option that lets container processes
run under your local user ID and group ID, allowing the SSH client to access
your local folder and agent socket.

```shell
podman run --rm -it \
  --name ssh-client \
  --userns=keep-id:uid=65532,gid=65532 \
  -v $HOME/.ssh:/home/nonroot/.ssh:ro \
  -v $SSH_AUTH_SOCK:/ssh-agent:ro \
  -e SSH_AUTH_SOCK=/ssh-agent \
  -p 127.0.0.1:1080:1080 \
  ssh-client \
  -D 0.0.0.0:1080 -4 -N target.example.com
```

The volumes are mounted read-only.
Drop the `:ro` suffix in the `-v` command for the `.ssh` folder to allow the
SSH client to write to the `.ssh/known_hosts` file, if desired:
`-v $HOME/.ssh:/home/nonroot/.ssh`

#### Test

To test whether the SOCKS proxy works, run the following command on your host
to ensure the IP address shown is the one from the SSH target host:
```shell
curl -x socks5h://127.0.0.1:1080 https://check.torproject.org/api/ip
```

DNS is resolved remotely by the SSH target host.
