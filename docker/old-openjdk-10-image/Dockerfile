FROM openjdk:10

# Using openjdk Docker base image which is not that slim but as of writing this
# there is no openjdk 10 Alpine Linux Docker image yet.
# We could have compiled to target Java 8, but since this is a demo let's not worry about the image size too much.

# Install Emacs. This is a demo, in production we would use as slim image as possible. Using Emacs for debugging inside container.
RUN apt update
RUN apt install -y emacs-nox

# Set MY_LIB_DIR - You can use this directory for copying derived image files.
ENV MY_LIB_DIR /opt/mylib
RUN mkdir -p $MY_LIB_DIR
ENV CLASSPATH $MY_LIB_DIR

COPY app.jar $MY_LIB_DIR/.
COPY resources/ $MY_LIB_DIR/.

WORKDIR $MY_LIB_DIR

# Default: start in dev mode.
ENTRYPOINT ["./run-dev-mode.sh"]
