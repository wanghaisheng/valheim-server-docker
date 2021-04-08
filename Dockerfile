FROM cm2network/steamcmd:latest

# Install Python to allow parsing VDF format (https://developer.valvesoftware.com/wiki/KeyValues)
# Python VDF parser: https://github.com/ValvePython/vdf
#USER root
#RUN apt-get update && apt-get install python3-pip -y && pip3 install vdf

# where Steam is installed
ENV STEAM_SERVER_DIR = "/home/steam/Steam"
# where steamcmd is installed
ENV STEAM_CMD_DIR = "/home/steam/steamcmd"
# where the Valheim server is installed to
ENV VALHEIM_SERVER_DIR "/home/steam/valheim-server"

# install the Valheim server
RUN ./steamcmd.sh +login anonymous \
+force_install_dir $VALHEIM_SERVER_DIR \
+app_update 896660 \
validate +exit

# changes the uuid and guid to 1000:1000, allowing for the files to save on GNU/Linux
USER 1000:1000

# where world data is stored, map this to the host directory where your worlds are stored
# e.g. docker run -v /path/to/host/directory:/home/steam/valheim-data
ENV VALHEIM_DATA_DIR "/home/steam/valheim-data"
# don't change the port unless you know what you are doing
ENV VALHEIM_PORT 2456
# server and world name are truncated after 1st white space
# you must set values to the server and world name otherwise the container will exit immediately
ENV VALHEIM_SERVER_NAME=""
ENV VALHEIM_WORLD_NAME=""
ENV VALHEIM_PASSWORD "password"

# the server needs these 3 ports exposed by default
EXPOSE 2456/udp
EXPOSE 2457/udp
EXPOSE 2458/udp

VOLUME ${VALHEIM_DATA_DIR}

# copy over the modified server start script
COPY start-valheim-server.sh ${VALHEIM_SERVER_DIR}
WORKDIR ${VALHEIM_SERVER_DIR}

ENTRYPOINT ["./start-valheim-server.sh"]
