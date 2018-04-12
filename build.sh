#!/usr/bin/env bash

FTP_URL='ftp://ftp.ntpsec.org/pub/releases'
VERSION=${VERSION:-1.1.0}
TAG="${DOCKER_PROJECT:-devananda/ntpsec}:$VERSION"

GPG=$(which gpg || (echo "Error: gpg not found in path"; exit 1))
WGET=$(which wget || (echo "Error: wget not found in path"; exit 1))
SHA=$(which sha256sum || (echo "Error: sha256sum not found in path"; exit 1))
DOCKER=$(which docker || (echo "Error: docker not found in path"; exit 1))

CWD=$(pwd)
WD=$(mktemp -d)
trap "rm -rf $WD" SIGTERM SIGKILL SIGINT
pushd $WD

# Ideally, this should already be present on the build system -- and TRUSTED!
echo
echo "================================================================="
echo "=                 Importing NTPSec signing key                  ="
echo "================================================================="
echo
$GPG --batch --recv-keys 0x05D9B371477C7528

# Fetch the files
$WGET -nv ${FTP_URL}/ntpsec-${VERSION}.tar.gz
$WGET -nv ${FTP_URL}/ntpsec-${VERSION}.tar.gz.asc
$WGET -nv ${FTP_URL}/ntpsec-${VERSION}.tar.gz.sum
$WGET -nv ${FTP_URL}/ntpsec-${VERSION}.tar.gz.sum.asc

# Validate SHA and signatures
echo
echo "================================================================="
echo "=                    Validating signatures                      ="
echo "================================================================="
echo
p=$($SHA ntpsec-${VERSION}.tar.gz | cut -d ' ' -f 1)
q=$(cat ntpsec-${VERSION}.tar.gz.sum.asc | grep ntpsec | cut -d ' ' -f 1)
if [ "$p" != "$q" ]; then
  echo "Error: bad SHA256 checksum. Aborting build."
  exit 1
fi
$GPG --verify ntpsec-${VERSION}.tar.gz.asc ntpsec-${VERSION}.tar.gz || \
    (echo "Error: Bad GPG signature. Aborting build."; exit 1)
$GPG --verify ntpsec-${VERSION}.tar.gz.sum.asc || \
    (echo "Error: Bad GPG signature. Aborting build."; exit 1)

# Copy bits into temp dir and build!
cp $CWD/Dockerfile .
cp $CWD/config .

echo
echo "================================================================="
echo "= NTPSec build $VERSION downloaded and verified; initiating build  ="
echo "= Temporary files will automatically be removed when finished   ="
echo "================================================================="
echo

$DOCKER build --tag $TAG .
rm -rf $WD
trap - SIGTERM SIGKILL SIGINT

echo
echo "================================================================="
echo "=                       Build completed                         ="
echo "================================================================="
echo
