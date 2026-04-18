#!/bin/sh
# Runs swift-testing tests under CommandLineTools (no Xcode).
# Builds with Testing.framework on the search path, then invokes the test
# helper with DYLD_* set so Testing + lib_TestingInterop resolve at runtime.

set -e

CLT=/Library/Developer/CommandLineTools
F=$CLT/Library/Developer/Frameworks

swift build --build-tests -Xswiftc -F -Xswiftc "$F" -Xlinker -F -Xlinker "$F"

DYLD_FRAMEWORK_PATH=$F \
DYLD_LIBRARY_PATH=$CLT/Library/Developer/usr/lib \
  "$CLT/usr/libexec/swift/pm/swiftpm-testing-helper" \
  --test-bundle-path "$(ls -d .build/*/debug/*.xctest/Contents/MacOS/*PackageTests)" \
  --testing-library swift-testing \
  "$@"
