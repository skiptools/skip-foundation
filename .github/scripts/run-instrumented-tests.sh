#!/bin/bash
# Installs each androidTest APK in $1 and runs its instrumentation on the connected device.
set -euo pipefail
AAPT2=$(ls -d "${ANDROID_HOME}"/build-tools/*/aapt2 | sort -V | tail -1)
status=0
for apk in "$1"/*.apk; do
  pkg=$("${AAPT2}" dump packagename "${apk}")
  # a cached AVD can hold this package signed by another runner's debug key
  adb uninstall "${pkg}" > /dev/null || true
  adb install -t "${apk}"
  runner=$(adb shell pm list instrumentation | tr -d '\r' | sed -n "s#^instrumentation:${pkg}/\([^ ]*\) .*#\1#p")
  out=$(adb shell am instrument -w -r -e disableAnalytics true "${pkg}/${runner}" | tr -d '\r')
  # status -3 is an ignored test and -4 an assumption failure, which is how XCTSkip reaches JUnit
  echo "${out}" | awk -F= '/^INSTRUMENTATION_STATUS: class=/{c=$2} /^INSTRUMENTATION_STATUS: test=/{t=$2} /^INSTRUMENTATION_STATUS_CODE: /{split($0,a,": "); if (a[2]!=1) print "TEST " c "." t " " (a[2]==0?"PASSED":(a[2]==-3||a[2]==-4)?"SKIPPED":"FAILED")}'
  echo "${out}" | grep -v '^INSTRUMENTATION_STATUS'
  grep -q '^OK (' <<<"${out}" || status=1
  adb uninstall "${pkg}" > /dev/null
done
exit ${status}
