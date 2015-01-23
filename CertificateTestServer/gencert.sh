#!/usr/bin/env bash
# gencert.sh <filename> <id> <name> <email> <pass> <bit-size>

set -e            # fail fast
set -o pipefail   # don't ignore exit codes when piping output
# set -x          # enable debugging

# Configure directories
filename=$1
id=$2
name=$3
email=$4
pass=$5
bit_size=$6

TMP_DIR=$(mktemp -d -t node.XXXXXX)
# clean up leaking environment
unset GIT_DIR

openssl genrsa -out "$TMP_DIR/$filename.pem" $bit_size

openssl req -new -key "$TMP_DIR/$filename.pem" -out "$TMP_DIR/$filename.csr" -subj "/CN=$id/emailAddress=$email/O=$name"

openssl x509 -req -days 730 -in "$TMP_DIR/$filename.csr" -CA .secret/NetIdentityCA.crt -CAkey .secret/NetIdentityCA.key -CAserial .secret/NetIdentityCA.srl -out "$TMP_DIR/$filename.crt"

openssl pkcs12 -export -out "cert/$filename.p12" -passout "pass:$pass" -inkey "$TMP_DIR/$filename.pem" -in "$TMP_DIR/$filename.crt" -chain -CAfile .secret/NetIdentityCA.crt

rm -fr "$TMP_DIR"
