FROM openjdk:8-jre-alpine

# See: https://pkgs.alpinelinux.org/packages?name=openjdk8-jre&branch=edge

# Set MY_LIB_DIR - You can use this directory for copying derived image files.
ENV MY_LIB_DIR /opt/mylib
RUN mkdir -p $MY_LIB_DIR
ENV CLASSPATH $MY_LIB_DIR

COPY app.jar $MY_LIB_DIR/.
COPY resources/ $MY_LIB_DIR/.

WORKDIR $MY_LIB_DIR

# Default: start in dev mode.
ENTRYPOINT ["./run-dev-mode.sh"]
