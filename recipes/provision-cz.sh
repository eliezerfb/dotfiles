#!/usr/bin/env bash

PROGNAME="provision-cz.sh"


_step_base_system () {
  ${STEP_BASE_SYSTEM_DONE:-false} && return
  [ -e /etc/sudoers ] && ! sudo grep -q "$USER" /etc/sudoers && (echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers)
  mkdir ~/workspace >/dev/null 2>&1 ; ls -d -l ~/workspace || exit $?
  bash -c "$(curl -LSf "https://bitbucket.org/stroparo/runr/raw/master/entry.sh" || curl -LSf "https://raw.githubusercontent.com/stroparo/runr/master/entry.sh")" entry.sh apps shell
  source "${DS_HOME:-$HOME/.ds}/ds.sh" || exit $?
  export STEP_BASE_SYSTEM_DONE=true
}


_step_custom () {
  dsplugin.sh "bitbucket.org/stroparo/ds-cz"

  export PROVISION_OPTIONS="${PROVISION_OPTIONS} xfce"
  runr provision-stroparo

  stsetupautostart.sh
  runr setupkeybk380
  cz-conf-git.sh

  echo; echo "==> czsetup.sh <=="
  echo
  echo "Review script \$DS_HOME/.../cz*filesystem*.sh" 1>&2
  echo "... and only then run czsetup.sh." 1>&2
  echo
}


_main () {
  _step_base_system
  _step_custom
}


_main "$@"
