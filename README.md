# buildpack: ClamAV

This buildpack installs ClamAV (`clamd` and `freshclam`) into a Scalingo app 
image.

> :warning: **This buildpack is not meant to be use as a standalone but rather in a
multi-buildpack deployment scenario, along with other softwares such as nginx
(as front) and clammit (as link between nginx and ClamAV).**

## Usage

The following instructions should help you get started:

1. In your project root, create a file named `.buildpacks` with the following
content:

```
https://github.com/Scalingo/clamav-buildpack.git
# Probably more buildpacks here. Otherwise your ClamAV won't start!
```

2. Setup your other buildpacks. Make sure the software(s) interacting with
ClamAV do it through the local unix socket on which clamd is listening
(`/app/run/clamd.sock`).

3. Add a `start.sh` (for example) script to your project. It should contain
instructions to:

  - Start `clamd`. Something like `clamd --config-file="${HOME}/clamav/clamd.conf"`
    should do the job.
  - Start `freshclam`. Something like `freshclam --daemon --config-file="${HOME}/clamav/freshclam.conf"`
    should be enough.
  - Start the other processes that will communicate with ClamAV.

4. Add a `Procfile` to your project and ask it to use the `start.sh` script:

```
web: bash start.sh
```

5. Trigger a deployment.

### Deployment workflow

During the build phase, this buildpack:

1. Downloads and installs the `clamav`, `clamav-daemon` and `clamav-freshclam`
   packages.
2. Creates configuration file for `clamd` in`/app/clamav/clamd.conf`.
3. Creates configuration file for `freshclam` in `/app/clamav/freshclam.conf`.
4. Downloads the latest virus database and stores it in the build cache for
   future use.
5. Copies the virus database to the build directory.

:tada: This process results into a scalable image that includes the
configuration, ready to be packaged into a container.

### Behaviour

The configuration deployed will ensure that:

- `clamd` will run in background
- `clamd` will listen on a local unix socket (`/app/run/clamd.sock`)
- `freshclam` will check for updates 12 times per day
- `freshclam` will use the default `database.clamav.net` mirror, unless
  specified otherwise (see [Environment](#environment)
  below).

### Environment

The following environment variables are available for you to tweak your
deployment:

#### CLAMD_DATABASE_MIRROR

ClamAV database mirror to use.\
Defaults to `database.clamav.net`
