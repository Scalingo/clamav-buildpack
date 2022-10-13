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
https://github.com/Scalingo/apt-buildpack.git
https://github.com/Frzk/sclng-buildpack-clamav.git#main
# Probably more buildpacks here. Otherwise your ClamAV won't start!
```

2. Still at the root of your project, add a file named `Aptfile` with the
following content:

```
clamav
clamav-daemon
clamav-freshclam
```

3. Setup your other buildpacks. Make sure the software(s) interacting with
ClamAV do it through the local unix socket on which clamd is listening.

4. Add a `start.sh` (for example) script to your project. It should contain
instructions to:

  - Start `clamd`. Something like `clamd --config-file="${HOME}/clamav/clamd.conf"`
    should do the job.
  - Start `freshclam`. Something like `freshclam --daemon --config-file="${HOME}/clamav/freshclam.conf"`
    should be enough.
  - Start the other processes that will communicate with ClamAV.

5. Add a `Procfile` to your project and ask it to use the `start.sh` script:

```
web: bash start.sh
```

6. Trigger a deployment.

