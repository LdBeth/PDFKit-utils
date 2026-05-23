#!/bin/sh
# Build pdftotext / pdftoppm for release and strip non-global symbols from
# the linked binaries. Cuts each artifact from ~1.55 MB to ~820 KB without
# affecting runtime behavior (debug info still lives in the .dSYM bundle).
#
# `-Xlinker -x` was tried first but is silently overridden by the `-g`
# SwiftPM passes for dSYM generation, so the strip step runs post-link.
#
# Note: `-disable-reflection-metadata` would shave another ~16 KB but breaks
# swift-argument-parser, which relies on Mirror to discover @Argument /
# @Option property wrappers. Do not add it back.

set -e

swift build -c release "$@"

strip -x .build/release/pdftotext .build/release/pdftoppm
