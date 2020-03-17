#!/bin/bash

set -e
set -o pipefail

DISTRIBUTION_GROUP="Collaborators"
APK="build/app/outputs/apk/development/debug/app-development-debug.apk"
APP_CENTER_APP="open-xchange/OX-COI-Messenger-Dev"

appcenter distribute release --app "${APP_CENTER_APP}" --file ${APK} --group ${DISTRIBUTION_GROUP} --output json