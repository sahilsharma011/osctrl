#!/bin/sh
#
# Tool to quick remove OSX/Linux nodes from osctrl
#
# IMPORTANT! osquery will not be removed.

_PROJECT="{{ .Project }}"
_SECRET_LINUX=/etc/osquery/osquery.secret
_SECRET_OSX=/private/var/osquery/osquery.secret
_FLAGS_LINUX=/etc/osquery/osquery.flags
_CERT_LINUX=/etc/osquery/certs/${_PROJECT}.crt
_FLAGS_OSX=/private/var/osquery/osquery.flags
_CERT_OSX=/private/var/osquery/certs/${_PROJECT}.crt
_PLIST_OSX=/Library/LaunchDaemons/com.facebook.osqueryd.plist
_OSQUERY_SERVICE_LINUX="osqueryd"
_OSQUERY_SERVICE_OSX="com.facebook.osqueryd"

_SECRET_FILE=""
_FLAGS=""
_CERT=""
_SERVICE=""

fail() {
  echo "[!] $1"
  exit 1
}

log() {
  echo "[+] $1"
}

whatOS() {
	OS=$(echo `uname`|tr '[:upper:]' '[:lower:]')
  log "OS=$OS"
  if [ "$OS" = "linux" ]; then
    _SECRET_FILE="$_SECRET_LINUX"
    _FLAGS="$_FLAGS_LINUX"
    _CERT="$_CERT_LINUX"
    _SERVICE="$_OSQUERY_SERVICE_LINUX"
  fi
  if [ "$OS" = "darwin" ]; then
    _SECRET_FILE="$_SECRET_OSX"
    _FLAGS="$_FLAGS_OSX"
    _CERT="$_CERT_OSX"
    _SERVICE="$_OSQUERY_SERVICE_OSX"
  fi
  log "_SECRET_FILE=$_SECRET_FILE"
  log "_FLAGS=$_FLAGS"
  log "_CERT=$_CERT"
  log "_SERVICE=$_SERVICE"
  log "IMPORTANT! osquery will not be removed."
}

stopOsquery() {
  if [ "$OS" = "linux" ]; then
    log "Stopping $_OSQUERY_SERVICE_LINUX"
    sudo systemctl stop "$_OSQUERY_SERVICE_LINUX"
    sudo systemctl disable "$_OSQUERY_SERVICE_LINUX"
  fi
  if [ "$OS" = "darwin" ]; then
    log "Stopping $_OSQUERY_SERVICE_OSX"
    if launchctl list | grep -qcm1 "$_OSQUERY_SERVICE_OSX"; then
      sudo launchctl unload "$_PLIST_OSX"
      sudo rm -f "$_PLIST_OSX"
    fi
  fi
}

removeSecret() {
  log "Removing osquery secret: $_SECRET_FILE"
  sudo rm -f "$_SECRET_FILE"
}

removeFlags() {
  log "Removing osquery flags: $_FLAGS"
  sudo rm -f "$_FLAGS"
}

removeCert() {
  log "Removing osquery certificate"
  sudo rm -f "$_CERT"
}

bye() {
  result=$?
  if [ "$result" != "0" ]; then
    echo "[!] Fail to remove $_PROJECT node"
  fi
  exit $result
}

trap "bye" EXIT
whatOS
set -e
stopOsquery
removeSecret
removeFlags
removeCert

log "Congratulations! The node has been removed from $_PROJECT"
log "IMPORTANT! $_SERVICE has been stopped and disabled."

# EOF