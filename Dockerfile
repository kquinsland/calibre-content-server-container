# We need glibc for Calibre to run, no MUSL or alpine here :(.
##
FROM debian:bookworm-slim

# The root location for the Calibre library
ENV CALIBRE_LIB_ROOT=/library

# Version to install; 8.1.1. is latest as of 2025.04
# See: https://github.com/kovidgoyal/calibre/releases
ARG CALIBRE_VERSION=8.1.1

# Installer needs to unpack xz tar, python and a few image/font libraries
# TODO: disable the WARN from apt about not having a stable API...
RUN apt update && apt install -y \
    ca-certificates \
    wget \
    python3 \
    xz-utils \
    libegl1 \
    libopengl0 \
    libxcb-cursor0 \
    libfreetype6 \
    libfontconfig1 \
    libglx0 \
    libxkbcommon0

# Add Calibre to PATH and library path for runtime linking
ENV PATH="$PATH:/opt/calibre/bin" \
    LD_LIBRARY_PATH="/opt/calibre/lib"

##
# Download and install Calibre in isolated mode, then clean up installer cache
RUN wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh \
    | sh /dev/stdin isolated=y version=${CALIBRE_VERSION} && \
    rm -rf /tmp/calibre-installer-cache

# Expose Calibre content server port
EXPOSE 8080

# Set up a bare bones library in /library; just enough to get the content server running
RUN /opt/calibre/calibredb --with-library ${CALIBRE_LIB_ROOT} list

# Default command to run the Calibre server on the library
# Use non-array form of CMD to avoid issues with the var expansion
CMD /opt/calibre/calibre-server ${CALIBRE_LIB_ROOT}
