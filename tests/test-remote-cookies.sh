#!/bin/bash
#
# Copyright (C) 2013 Jeremy Whiting <jeremy.whiting@collabora.com>
# Copyright (C) 2016 Sjoerd Simons <sjoerd@luon.net>
#
# SPDX-License-Identifier: LGPL-2.0+
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library. If not, see <https://www.gnu.org/licenses/>.

set -euo pipefail

echo '1..4'

. $(dirname $0)/libtest.sh

setup_fake_remote_repo1 "archive" "" \
  --expected-cookies foo=bar \
  --expected-cookies baz=badger

assert_fail (){ 
  if $@; then
    (echo 1>&2 "$@ did not fail"; exit 1)
  fi
}

cd ${test_tmpdir}
rm repo -rf
mkdir repo
ostree_repo_init repo
${CMD_PREFIX} ostree --repo=repo remote add --set=gpg-verify=false origin $(cat httpd-address)/ostree/gnomerepo

# Sanity check the setup, without cookies the pull should fail
assert_fail ${CMD_PREFIX} ostree --repo=repo pull origin main

echo "ok, setup done"

# Add 2 cookies, pull should succeed now
${CMD_PREFIX} ostree --repo=repo remote add-cookie origin 127.0.0.1 / foo bar
${CMD_PREFIX} ostree --repo=repo remote add-cookie origin 127.0.0.1 / baz badger
assert_file_has_content repo/origin.cookies.txt foo.*bar
assert_file_has_content repo/origin.cookies.txt baz.*badger
${CMD_PREFIX} ostree --repo=repo pull origin main

echo "ok, initial cookie pull succeeded"

# Delete one cookie, if successful pulls will fail again
${CMD_PREFIX} ostree --repo=repo remote delete-cookie origin 127.0.0.1 / baz badger
assert_file_has_content repo/origin.cookies.txt foo.*bar
assert_not_file_has_content repo/origin.cookies.txt baz.*badger
assert_fail ${CMD_PREFIX} ostree --repo=repo pull origin main

echo "ok, delete succeeded"

# Re-add the removed cooking and things succeed again, verified the removal
# removed exactly one cookie
${CMD_PREFIX} ostree --repo=repo remote add-cookie origin 127.0.0.1 / baz badger
assert_file_has_content repo/origin.cookies.txt foo.*bar
assert_file_has_content repo/origin.cookies.txt baz.*badger
${CMD_PREFIX} ostree --repo=repo pull origin main

echo "ok, second cookie pull succeeded"
