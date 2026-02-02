# About

Collection of various Dockerfiles.

See sub-folders for README.md files.

# Podman Versus Docker

Consider Podman instead of Docker, as Podman is daemonless and is designed to
run rootless containers.

Additionally, Podman offers useful features like `userns`, which enables
remapping user IDs and group IDs within the container. This allows for host
volume access with the permissions of the host user.

# Useful Commands

For most `podman` commands in this repositoriy, `docker` can be used instead.

## Show Images

```shell
podman images
```

## Show Running Containers

```shell
podman ps
```

## Show Logs

```shell
podman logs container-id # prefix of ID or name found
```

## Determine Image Entrypoint and Cmd

```shell
podman inspect image-name
podman inspect -f '{{.Config.Entrypoint}}' image-name
podman inspect -f '{{.Config.Cmd}}' image-name
```

## Get a Shell in Container

In case the image has a shell, you can try to run a container with a shell like `sh` or `bash` as the entrypoint:
```shell
podman run --entrypoint sh --rm -it image-name
podman run --entrypoint bash --rm -it image-name
```

## Stop Containers

```shell
podman stop container-id # prefix of ID or name found
```

## Free Up Space

Do not run this command unless you want to free up space by removing currently
unused resources, such as dangling images, unused networks, stopped containers,
and build caches:
```shell
podman system prune     # only deletes dangling images
podman system prune -a  # -a deletes all images not used by a running container
podman system prune -f  # -f to force running the command without confirmation
podman system prune -af # delete all unused images without confirmation
```
