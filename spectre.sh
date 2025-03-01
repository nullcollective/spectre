#!/usr/bin/env bash

# spectre
# Yubikey Injection Tool
####################################################################
# Usage: ./spectre.sh [your-script.sh]
# Depends on [ykman]
####################################################################
# Copyright 2025 nullcollective
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#---------------- CONFIG ----------------#
ykman_bin="/snap/bin/ykman"
object_id="0x5f0000"
slot_id="1"

#---------------- FUNCTIONS ----------------#
init () {
    # Check to make sure ykman is installed
    if ! [[ -f ${ykman_bin} ]]; then
        echo "Please install ykman" ; exit 1
    fi
    # Verify Yubikey is Available
    echo -n "Checking For Yubikey..."
    ykman info > /dev/null 2>&1
    if ! [ $? -eq 0 ]; then
        echo "NOT FOUND" ; exit 1;
    fi
    echo "FOUND"
}
yubikey_setup () {
    ykman list ; echo "-----------------"
    read -p "Import $1 into your Yubikey and overwrite OTP Slot ${slot_id}? [Y/N] " -n 1 -r
    echo -e "\n"
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ykman piv objects import ${object_id} $1
        ykman otp static ${slot_id} -k US "ykman piv objects export ${object_id} -|sh"
    else
        exit
    fi
}

#---------------- MAIN ----------------#
VERSION="0.1.1"
HEADER="+++ Spectre Yubikey Injection Tool v${VERSION} +++"
echo "${HEADER}"

if [ $# -gt 0 ]; then
    if ! [ -f $1 ]; then
        echo "File $1 does not exist" ; exit 1
    fi
    init ; yubikey_setup $1
    echo -e "\nScript $1 has been written to Yubikey"
    echo "This will run on pressing Slot ${slot_id} OTP"
else
    echo "Please Provide Script"
    echo "Usage: ./spectre.sh [your-script.sh]"
fi