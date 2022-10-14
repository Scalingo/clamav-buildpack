# buildpack: ClamAV

## Usage

This buildpack is not meant to be use as a standalone one but rather in a
multi-buildpack deployment, along with other softwares such as nginx (as front)
and clammit (as link between nginx and ClamAV).

### Behaviour

The configuration deployed will ensure that:

- `clamd` will run in background
- `clamd` will listen on a local unix socket (`/app/run/clamd.sock`)
- `freshclam` will check for updates 12 times per day
- `freshclam` will use the default `database.clamav.net` mirror, unless
  specified otherwise (see [Environment variables](#environment-variables)
  below).

### Environment variables

The following environment variable is available for you to tweak the ClamAV
setup:

- `CLAMD_DATABASE_MIRROR`: ClamAV database mirror to use. Defaults to
  `database.clamav.net`.

### How to use

1. In your project root, create a file named `.buildpacks` with the following
content:

```
https://github.com/Scalingo/clamav-buildpack.git
# Probably more buildpacks here. Otherwise your ClamAV won't start!
```

2. Setup your other buildpacks. Make sure the software(s) interacting with
ClamAV do it through the local unix socket on which clamd is listening.

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

