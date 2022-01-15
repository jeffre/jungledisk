# Docker image for Jungle Disk
This container runs 3 applications:
1) VNC server (port 5900)
2) Web-based VNC client (port 6080)
3) Jungle Disk (Formerly Workgroup Edition)

The reason for the VNC components is that Jungle Disk recommends
using their GUI to generate the configuration file.

# Create docker image
1. Clone this repository

        $ git clone git@github.com:jeffre/jungledisk.git

2. Run docker build

        $ docker build ./jungledisk -t jeffre/jungledisk

    alternatively, a version can be specified

        $ docker build ./jungledisk -t jeffre/jungledisk --build-arg VERSION=3.32.0


# Run docker container
Create a basic container

    $ docker run -d \
        -p 5900:5900 \
        -p 6080:6080 \
        -e JD_VNC_PASSWORD=changeme \
        jeffre/jungledisk

Mount configuration directory to the docker host and restrict the VNC ports
so that only localhost can connect.

    $ docker run -d \
        -p 127.0.0.1:5900:5900 \
        -p 127.0.0.1:6080:6080 \
        -e JD_VNC_PASSWORD=changeme \
        -v $(pwd)/jungledisk:/jungledisk \
        jeffre/jungledisk


Or, if docker-compose is preferred, have a look at [docker-compose.yml](docker-compose.yml)


# Configuration
After starting the container for the first time, you will need to login to the VNC server by going to http://{IP-OF-HOST}:6080/vnc.html and using the password you set with JD_VNC_PASSWORD.

Give the application some time to start, as the whole desktop environment has to start up along with it too. But before long you will be greeted with the setup guide and be on your way.


# Environment Variables

Use these environment variables to change the default behavior of the container.

|Parameter|Description|
|---------|-----------|
| `JD_UID=1000` | Change the linux user id |
| `JD_GID=1000` | Change the linux group id |
| `JD_NOVNC_PORT=6080` | The port that noVNC listens on |
| `JD_VNC_PASSWORD=changeme` | Password used to login to VNC |
| `JD_VNC_PORT=5900` | The port that VNC listens on |
| `JD_START_VERBOSE=0` | Increase the logging verbosity |