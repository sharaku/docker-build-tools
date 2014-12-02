FROM sharaku/debian-sshd
MAINTAINER sharaku

# ############################################################################
# installation of develop

# ----------------------------------------------------------------------
# update
RUN \
  apt-get update

# ----------------------------------------------------------------------
# install base tools.
RUN apt-get install -y wget git vim bzip2 nkf unzip bc

# ----------------------------------------------------------------------
# install build tools
RUN \
  apt-get install -y build-essential libtool ncurses-dev kmod libproc-processtable-perl uboot-mkimage

# ----------------------------------------------------------------------
# install cppcheck
RUN apt-get install -y cppcheck

# ----------------------------------------------------------------------
# jenkins client (java sdk)
RUN apt-get install -y default-jdk

# ############################################################################
# settings

