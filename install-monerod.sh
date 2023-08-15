#!/bin/bash
# Base on https://github.com/jonathancross/jc-docs.git
source install-lxc-basic.sh
source dist-upgrade-nala.sh

mkdir /root/bin

# git clone https://github.com/jonathancross/jc-docs.git
source jc-docs/upgrade-monero.sh

# Folder locations, please change as needed:
TMP=/tmp    # Folder (without trailing slash) where files are downloaded to.
DEST=~/bin  # Destination (without trailing slash) where we will install.

# File containing release hashes.  This tells us the version number as well:
HASHES_URL='https://www.getmonero.org/downloads/hashes.txt'

# egrep pattern for Linux archive file (unfortunately this changes regularly):
NEW_VERSION_PATTERN='monero-linux-x64-v[0-9.]+.tar.bz2'

# Prefix (without version number) of the folder extracted from the bzip archive:
EXTRACTED_FOLDER_PREFIX="monero-x86_64-linux-gnu-"

# URL prefix containing the release (without filename):
BZIP_URL_PREFIX='https://downloads.getmonero.org/cli/'

WARNING_MSG="
--------------------------------------------------------------------------------
This may be the result of a download error, dev mistake or foul play.
DO NOT PROCEED until you determine the cause."

echo "
Upgrading the Monero daemon
==========================="

# Make sure DEST exists:
if [[ ! -d "${DEST}/" ]]; then
  echo "ERROR: Could not find DEST ($DEST).
  You must configure this as path to the destination folder.";
  exit 1;
fi

# Make sure TMP exists:
if [[ ! -d "${TMP}/" ]]; then
  echo "ERROR: Could not find TMP ($TMP).
  You must configure this as a full path to the directory used for temp files.";
  mkdir /tmp
  #exit 1;
fi

cd "${TMP}"

# Temporary file name for hashes to make sure unique.
HASHES_FILE="monero_hashes_$$.txt"

# Get HASHES_FILE from HASHES_URL:
if [[ -f "${TMP}/${HASHES_FILE}" ]]; then
  echo "  * Signed Hashes: ${TMP}/${HASHES_FILE}"
else
  echo "  * Downloading Hashes: ${HASHES_URL}"
  if curl --silent "${HASHES_URL}" --output "${HASHES_FILE}"; then
    echo "    Saved as: ${TMP}/${HASHES_FILE}"
    # Check if HASHES_FILE actually downloaded (they keep changing location)
    echo -n "    Signature data?: "
    if grep -q "BEGIN PGP SIGNED MESSAGE" "${HASHES_FILE}"; then
      echo " [CONFIRMED]"
    else
      echo " [ERROR: Not a GPG signature]"
      exit 1
    fi
  else
    echo "ERROR: Could not download ${TMP}/${HASHES_FILE}"
    exit 1
  fi
fi

# Extract version number and file name:
NEW_VERSION_PATTERN_PREFIX="${NEW_VERSION_PATTERN%[*}"
NEW_BZIP=$(egrep --only-matching "${NEW_VERSION_PATTERN}" "${HASHES_FILE}")
# Check if we got something:
if [[ "${NEW_BZIP}" != *"${NEW_VERSION_PATTERN_PREFIX}"* ]]; then
  echo "ERROR: Could not extract new version info from hashes.txt using NEW_VERSION_PATTERN.
       NEW_VERSION_PATTERN = ${NEW_VERSION_PATTERN}
       HASHES_FILE = ${TMP}/${HASHES_FILE}
       Maybe file name format changed?"
  exit 1
fi
# Continue now that we know we have something:
NEW_VER=${NEW_BZIP##*-}     # Strip off prefix
NEW_VER=${NEW_VER%.tar.bz2} # Strip off suffix
# Determine the major version (used later for URLs):
VER_REGEX='v(0\.[0-9][0-9])\.'
[[ $NEW_VER =~ $VER_REGEX ]] && VER_MAJOR="${BASH_REMATCH[1]}"
NEW_TAR="${NEW_VER}.tar"    # Add back the .tar suffix
EXTRACTED_FOLDER_NAME="${EXTRACTED_FOLDER_PREFIX}${NEW_VER}"
NEW_VERSION_FOLDER="monero-${NEW_VER}"
BZIP_URL="${BZIP_URL_PREFIX}${NEW_BZIP}"

echo "  * New version: ${NEW_VER}"
echo "  * Destination: ${DEST}/"

# Check if this version is already installed:
if [[ -d "${DEST}/${NEW_VERSION_FOLDER}" ]]; then
  echo "
Seems this version is already installed:
  ${DEST}/${NEW_VERSION_FOLDER}

Nothing to do, exiting.
"
  exit 0
fi

# Download BZIP file:
if [[ -f "${TMP}/${NEW_BZIP}" ]]; then
  echo "  * Release file already downloaded: ${TMP}/${NEW_BZIP}"
else
  echo "  * Downloading Release: ${BZIP_URL}"
  printf "    "
  if curl --progress-bar "${BZIP_URL}" --output "${TMP}/${NEW_BZIP}"; then
    echo "    Saved as: ${TMP}/${NEW_BZIP}"
  else
    echo "ERROR: Could not download ${TMP}/${NEW_BZIP}"
    exit 1
  fi
fi
echo ''

# Verify file checksums against those in hashes.txt
echo -e "\nVerifying hashes:"

HASH_EXPECTED="$(grep "${NEW_BZIP}" "${HASHES_FILE}")"
HASH_EXPECTED="${HASH_EXPECTED%% *}" # Remove everything after first space.
echo "  * Expected: ${HASH_EXPECTED}"

HASH_ACTUAL="$(openssl dgst -sha256 "${NEW_BZIP}" | cut -d ' ' -f 2)"
HASH_ACTUAL="${HASH_ACTUAL%% *}" # Remove everything after first space.
echo "  * Actual:   ${HASH_ACTUAL}"

if [[ "${HASH_EXPECTED}" != "${HASH_ACTUAL}" ]]; then
  echo "
ERROR: Hashes DO NOT match.
You can manually verify by comparing with hashes found here:
  ${HASHES_URL}
And / or here:
  ${GITIAN_URL}
${WARNING_MSG}"
  exit 1
fi

echo -en "
Extracting files from ${NEW_BZIP}... "
if tar --extract --bzip2 --file "${NEW_BZIP}"; then
  echo "Done."
  echo -n "  - Renaming extracted folder..."
  if [[ -d "${NEW_VERSION_FOLDER}" ]]; then
    echo -en " [cleaning up old files] "
    rm -rf "${NEW_VERSION_FOLDER}"
  fi
  if mv -f "${EXTRACTED_FOLDER_NAME}" "${NEW_VERSION_FOLDER}"; then
    echo " Done."
  else
    echo "ERROR: Failed to rename ${EXTRACTED_FOLDER_NAME} to ${NEW_VERSION_FOLDER}."
    echo "       Script probably needs to be updated with new folder name."
    exit 1
  fi
else
  echo "ERROR: Failed to expand ${NEW_BZIP}"
  exit 1
fi

# Create softlinks if possible:
if [[ -d "${NEW_VERSION_FOLDER}" ]]; then
  echo -en "\nMoving extracted folder to ${DEST}/... "
  cp -Rf "${NEW_VERSION_FOLDER}" "${DEST}/"
  cd "${DEST}/"
  echo -e "Done.\nReplacing soft links:"
  for APP in monerod monero-wallet-cli monero-wallet-rpc; do
    printf '  '
    ln -sfv "${NEW_VERSION_FOLDER}/${APP}" "${APP}"
  done

  echo -en "\nConfirming installation..."
  INSTALLED_VER="$(${DEST}/monerod --version)"
  PATH_VER="$(monerod --version)"
  if [[ "$INSTALLED_VER" == "$PATH_VER" ]]; then
    echo " CONFIRMED: $PATH_VER"
    echo "You can now delete the downloaded files in $TMP"
  else
    echo -e "\nWARNING: ${DEST}/monerod doesn't seem to be in your PATH."
    echo -e "           Instead we found $(which monerod)"
  fi
else
  echo '
NOTE: Folder name has changed, you must manually install:
  NEW_VERSION_FOLDER=new_name_of_extracted_folder_here;
  cp -R "${NEW_VERSION_FOLDER}" "'${DEST}/'";
  cd "'${DEST}/'";
  for APP in monerod monero-wallet-cli monero-wallet-rpc;
    do ln -sfv "${NEW_VERSION_FOLDER}/${APP}" "${APP}";
  done;
  ';
fi

echo -e "\nDONE."
