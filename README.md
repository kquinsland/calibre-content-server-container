# calibre-content-server-container

A super simple container for running the [Calibre Content Server](https://manual.calibre-ebook.com/server.html).
This is meant to be a **headless** install; there is no GUI or desktop environment included in the container.

## Usage

You need two things:

- An exposed port (default is 8080) to access the Calibre Content Server from your browser.
- A directory on your host machine that contains your Calibre library, which will be mounted into the container.

By default, the container comes with a `/library` directory that is is devoid of books; it contains just the Calibre metadata files.

If you run the container image without mounting a library:

```shell
❯ podman run --name ccs --rm -it -p 8080:8080 ghcr.io/kquinsland/calibre-content-server-container:someVersionTagHere
```

And then open up `http://localhost:8080` in your browser and you should see a blank calibre library.

Likewise, if you have a valid Calibre library already, mount it into the container:

```shell
❯ podman run --name ccs --rm -it -p 8080:8080 -v /some/host/path/to/your/library:/library ghcr.io/kquinsland/calibre-content-server-container:someVersionTagHere
```

And then open up `http://localhost:8080` in your browser and you should see your Calibre library loaded up.

### k8s

If you're deploying this into a Kubernetes cluster, I have a basic [`deployment`](./deploy/k8s/service.yaml) and [`service`](./deploy/k8s/deployment.yaml) manifest.
They're quite basic and meant to be a starting point.

The critical point is that all configuration is done via command line arguments to the `calibre-server` binary in the `args` section of the `deployment.yaml` file.

### User Management

By default, the Calibre Content Server does not have any user management enabled.
In this state, it is read-only and anyone who can access the server can view your library.
If you want to restrict access or enable write access to the library, you will need to add the `--userdb` and `--enable-auth` flags.

The file that `--userdb` points to will need to exist.
You may find it easiest to [create the userdb file from within the container itself](https://manual.calibre-ebook.com/server.html#managing-user-accounts-from-the-command-line-only), especially if you're using a mounted library

```shell
# Or whatever the name of your container is
❯ podman exec -it ccs bash
#<...>
root@6cf9acf73a4f:/opt/calibre# calibre-server --manage-users -- add someUserNameHere somePasswordHere
root@6cf9acf73a4f:/opt/calibre# calibre-server --manage-users -- list
someUserNameHere
```

## TODOs

There's quite a bit of room for improvement w/ this.

_Ideally_ docker images would be built automatically on new releases of Calibre from upstream.
Lacking that, it would be nice to automate the process of building new versions of the container when a new version of Calibre is released.

- [ ] Automate building new versions of the container when a new version of Calibre is released.
  - GHA on a cron to check for new releases of Calibre and build the container if a new version is found, likely
- [ ] Build args for Dockerfile
  - [ ] Version
  - [ ] Other cli flags
  - [x] Library location
