#!/bin/bash

gpg --keyserver hkp://subkeys.pgp.net --recv-keys  $1 || gpg --keyserver keyserver.ubuntu.com --recv $1
gpg --export --armor $1 | sudo apt-key add -

for KEY in `apt-get update 2>&1 |grep NO_PUBKEY|awk  '{print $NF}'`; do gpg --keyserver keyserver.ubuntu.com --recv $KEY; gpg --export --armor $KEY|apt-key add -;done
