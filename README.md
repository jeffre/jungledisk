# Docker image for Jungle Disk
This container runs 3 applications:
1) VNC server (port 5900)
2) Web-based VNC client (port 6080)
3) Jungle Disk (Formerly Workgroup Edition)

The reason for the VNC components is that the Jungle Disk strongly recommends
using their GUI to generate the configuration file.

# Examples
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

