#!/usr/bin/env bash

set -e

PROGNAME="setupzeal.sh"

if !(uname -a | grep -i -q linux) ; then
  echo "SKIP: Only Linux is supported." 1>&2
  exit
fi

echo
echo "################################################################################"
echo "Zeal dev docs manager setup..."

# #############################################################################
# Globals

WORKDIR="${HOME}"

export APTPROG=apt-get; which apt >/dev/null 2>&1 && export APTPROG=apt
export RPMPROG=yum; which dnf >/dev/null 2>&1 && export RPMPROG=dnf

ZEAL_URL="https://github.com/zealdocs/zeal/archive/master.zip"

# #############################################################################
# Build functions


_install_system_deps () {
  echo ${BASH_VERSION:+-e} "\n==> Installing dependencies..."
  if egrep -i -q -r 'centos|fedora|oracle|red *hat' /etc/*release ; then
    # sudo $RPMPROG install -y TODO
    echo "${PROGNAME:+$PROGNAME: }SKIP: Enterprise Linux distributions still not supported." 1>&2
    exit
  elif egrep -i -q -r 'debian|ubuntu' /etc/*release ; then
    sudo $APTPROG install -y cmake extra-cmake-modules libqt5webkit5-dev libqt5x11extras5-dev libarchive-dev libsqlite3-dev libxcb-keysyms1-dev
  fi
}


_build_main () {
  if which zeal >/dev/null 2>&1 && [ -d "${WORKDIR}"/."zeal" ] ; then
    echo "${PROGNAME:+$PROGNAME: }SKIP: zeal likely already built and installed." 1>&2
    return
  fi

  _install_system_deps

  cd "${WORKDIR}"
  if [ ! -e "${WORKDIR}/.zeal.zip" ] ; then
    curl -LSfs -o "${WORKDIR}/.zeal.zip" "${ZEAL_URL}"
  fi
  unzip "${WORKDIR}/.zeal.zip" -d "${WORKDIR}"
  mv "${WORKDIR}/zeal-master" "${WORKDIR}/.zeal"
  cd "${WORKDIR}/.zeal"
  mkdir build && cd build
  cmake ..
  make
  sudo make install
}


# #############################################################################
# Ubuntu Helpers

_add_ppa_repo () {

  typeset ppa="$1"
  if [ -z "$ppa" ] ; then return ; fi

  echo ${BASH_VERSION:+-e} "\n==> ls /etc/apt/sources.list.d/${ppa%/*}*.list"

  if ! eval ls -l "/etc/apt/sources.list.d/${ppa%/*}*.list" 2>/dev/null ; then
    sudo add-apt-repository -y "ppa:$ppa"
  fi
}

_install_apt_packages () {
  for package in "$@" ; do
    echo "Installing '$package'..."
    if ! sudo ${APTPROG} install -y "$package" >/tmp/pkg-install-${package}.log 2>&1 ; then
      echo "${PROGNAME:+$PROGNAME: }WARN: There was an error installing package '$package' - see '/tmp/pkg-install-${package}.log'." 1>&2
    fi
  done
}

# #############################################################################
# Main

if egrep -i -q -r 'ubuntu' /etc/*release ; then
  if ! dpkg -s zeal ; then
    _add_ppa_repo 'zeal-developers/ppa'
    sudo ${APTPROG} update
    _install_apt_packages zeal
  fi
else
  echo "${PROGNAME:+$PROGNAME: }INFO: Building from source..." 1>&2
  _build_main
fi

echo "////////////////////////////////////////////////////////////////////////////////"
echo
