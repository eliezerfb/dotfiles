#!/usr/bin/env bash

"${RUNR_DIR:-$PWD}"/installers/setupds.sh
"${RUNR_DIR:-$PWD}"/recipes/sshkeygen.sh
"${RUNR_DIR:-$PWD}"/recipes/sshmodes.sh