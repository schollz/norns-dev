# `norns-test-dummy`

This image runs the full Norns stack (`crone`, `maiden` and `matron`), but without any sound output. It uses the `dummy` `jackd` sound driver.

Please view the `Dockerfile` to see the steps taken. In particular note that we've created a `we` user account and home directory.

It is possible to use this image to get sound output and grid functionality on Linux.

## Quick start

Run the following (it is not necessary to have cloned this repo):

```
docker run --rm -it \
    --ulimit rtprio=95 --ulimit memlock=-1 --shm-size=256m \
    -p 5000:5000 -p 5555:5555 -p 5556:5556 \
    samdoshi/norns-test-dummy
```

Then visit http://127.0.0.1:5000/maiden/ in your browser.

The above command will pull a copy of `samdoshi/norns-test-dummy` from [Docker Hub](https://hub.docker.com/r/samdoshi/norns-test-dummy/) if it doesn't exist locally. See below for details to build it yourself.

**Type `Ctrl-b d` to quit [`tmux`][] and the Docker session.**

## Summary of `Makefile` targets

Please view the `Makefile` to see the exact options given to the `docker` commands.

 - **`build`**: builds the Docker image and tags it as `samdoshi/norns-test-dummy`.
 - **`run`**: runs the image leaving you in a [`tmux`][] session with `jackd`, `crone`, `matron` and `maiden` running in individual panes.
 - **`run-audio`**: same as `run` but with audio exported. Tested on Linux, your mileage may vary.
 - **`run-bash`**: runs the image but doesn't start the [`tmux`][] session.
 - **`run-bash-root`**: as `run-bash` but starts a `root` `bash` shell, instead of the `we` user.
 - **`shell`**: starts a shell in an _already running_ Docker process, it is useful with the `run` target.
 - **`shell-root`**: as `shell` but starts as `root`.

## Getting sound output on Linux with ALSA pass-through

You can also use this image to produce audio on Linux, as it's running in a container and not a virtual machine, performance should be nearly identical to running it on the host OS. However we will need to dedicate a sound card to the image (i.e. it cannot be in use by either Jack or PulseAudio).

Broadly speaking we need to do the following:

 1. Share `/dev/snd` with the container.

    This is achieved by adding `--device /dev/snd` to the `docker run` command.

 1. Provide a new `/etc/jackdrc` to the container.

    Either we can create a new `Dockerfile` deriving from this, or we can use the `-v` option with `docker run` to provide the new file from the local filesystem.

 1. Ensure that the `we` user has the correct permissions to access the sound card.

    This is achieved by adding `--group-add <gid of host audio group>` to the `docker run` command.

As an example with my own setup:

`/tmp/jackdrc`:

```
/usr/local/bin/jackd -R -d alsa -d hw:Crimson
```

(I recommend using hardware names, you can find them by running `cat /proc/asound/cards`)

Then I can use the following `docker run` command:

```
docker run --rm -it \
    --device /dev/snd \
    --group-add $(shell getent group audio | cut -d: -f3) \
    --ulimit rtprio=95 --ulimit memlock=-1 --shm-size=256m \
    -p 5000:5000 \
    -p 5555:5555 \
    -p 5556:5556 \
    -v /tmp/jackdrc:/etc/jackdrc \
    --name norns \
    samdoshi/norns-test-dummy
```

(We use the `$(getent...)` as we need to use the `gid` of the group from the host)

If all has gone well, you'll see the 4 panes inside [`tmux`][] appear, and once all the applications have started running you can visit http://127.0.0.1:5000/maiden/ and run a script. I would suggest starting with `tehn/awake.lua`.

## Connecting a grid with Linux

This is done in a similar way to getting ALSA sound working.

 1. Share the grid serial device with the container.

 1. Ensure that the `we` user has permissions to access the device.

We need to determine what the grid device is, and also what group it's owned by.

Firstly, the easiest way to determine the device path is running `dmesg` just after plugging it in:

```
$ dmesg
...
[22512.286363] usb 1-3.3: Detected FT232RL
[22512.286593] usb 1-3.3: FTDI USB Serial Device converter now attached to ttyUSB0
```

Here we can see that the device is attached to `ttyUSB0`, which is actually at `/dev/ttyUSB0`.

To determine the group:

```
$ ls -la /dev/ttyUSB0
crw-rw---- 1 root uucp 188, 0 Sep  8 14:08 /dev/ttyUSB0
```

We can see that the group is `uucp`, this is distro specific, the example given is from my computer running Arch Linux.

Using that information we can add the following to a `docker run` command to pass the grid through: `--device /dev/ttyUSB0 --group-add $(getent group uucp | cut -d: -f3)`

For my own personal setup (and combined with the audio from above), my `docker run` command becomes:

```
docker run --rm -it \
    --device /dev/snd \
    --group-add $(getent group audio | cut -d: -f3) \
    --device /dev/ttyUSB0 \
    --group-add $(getent group uucp | cut -d: -f3) \
    --ulimit rtprio=95 --ulimit memlock=-1 --shm-size=256m \
    -p 5000:5000 \
    -p 5555:5555 \
    -p 5556:5556 \
    -v /tmp/jackdrc:/etc/jackdrc \
    --name norns \
    samdoshi/norns-test-dummy
```

I recommend running the `tehn/earthsea.lua` script to test the grid functionality.

[`tmux`]: https://github.com/tmux/tmux

## Norns in the cloud instructions

### Get a server

Get a Docker droplet or similar.

### Get a domain name

Free domain names are at [duckdns](http://www.duckdns.org/).

I'll assume your domain name is `yourwebsite.com`. Make sure to point the domain name to your server address.


### Setup reverse proxy

```
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo tee /etc/apt/trusted.gpg.d/caddy-stable.asc
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install -y caddy
```

And then copy the following to `/etc/caddy/Caddyfile`, making sure to change `yourwebsite.com` to your website:

```Caddyfile
yourwebsite.com {
        reverse_proxy localhost:8889
        reverse_proxy /radio.mp3 localhost:8000
        reverse_proxy /maiden/* localhost:5000
        reverse_proxy /api/* localhost:5000
        handle_path /matron {
                rewrite * /
                reverse_proxy localhost:5555
        }
        reverse_proxy /supercollider localhost:5556
}
```

Then restart caddy:

```
systemctl restart caddy
```

### Setup and run norns

First install pre-requisites, like Docker:

```
sudo apt install -y liblua5.3-dev make apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
```

Setup swap (optional):

```
sudo fallocate -l 2G /swapfile
sudo dd if=/dev/zero of=/swapfile bs=1024 count=2097152
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

First make the base image (takes awhile):

```
git clone https://github.com/schollz/norns-dev
cd ~/norns-dev
git checkout play
cd ~/norns-dev/norns-dev
make build
```

Then to make the running image:

```
cd ~/norns-dev/norns-test-dummy
```

Edit the `repl-endpoints.json` and change `play.norns.online` to your domain name `yourwebsite.com`.

Now make a user to share the directory:

```
adduser we
```

Now build and run (first time takes awhile):

```
make build
make dust
sudo chown -R we:we dust
make pub # or `make run` for terminals
```

Thats it! Now open your `yourwebsite.com`.

