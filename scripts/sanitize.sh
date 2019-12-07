#!/bin/bash
set -e

LUET_REPO="${LUET_REPO:-/root/repo}"
echo "Running sanitizer script"

# Drop noisy output from yaml
find "${LUET_REPO}" -path "$LUET_REPO"/.git -prune -o -type f -print0 | xargs -0 sed -i 's/State: .*//g'
find "${LUET_REPO}" -path "$LUET_REPO"/.git -prune -o -type f -print0 | xargs -0 sed -i 's/set: false//g'
find "${LUET_REPO}" -path "$LUET_REPO"/.git -prune -o -type f -print0 | xargs -0 sed -i 's/.*: null//g'
find "${LUET_REPO}" -path "$LUET_REPO"/.git -prune -o -type f -print0 | xargs -0 sed -i '/^$/d'



