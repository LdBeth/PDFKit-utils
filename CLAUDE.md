# PDFKit CLI tools (pdftotext, pdftoppm)

## Layout

- `Sources/PDFToolsCore/` — shared `PDFTextExtractor`, `PDFRenderer`
  (PDFKit-backed).
- `Sources/pdftotext/`, `Sources/pdftoppm/` — thin `ArgumentParser` front-ends.
- Requires Swift 6.0 toolchain, macOS 14+.

## Build & test

- Build: `swift build` (release: `swift build -c release`)
- Tests: `./run-tests.sh` (or `swift test` with the same flags). Plain
  `swift test` fails with `plugin for module 'TestingMacros' not found`: the
  macro plugin lives in `plugins/testing/` under the CLT host plugin dir, which
  the compiler does not search by default. The wrapper is just `swift test`
  with `-Xswiftc -plugin-path` pointed at it.
- SourceKit/LSP does not see the `-plugin-path` flag, so `Testing` shows as a
  missing-module diagnostic in the editor. Ignore it; the wrapper run is
  authoritative.

## Fixture coupling

- `Tests/PDFToolsCoreTests/PDFToolsCoreTests.swift` uses `README.pdf` as a
  fixture and hard-codes `doc.pageCount`. When README.md/README.pdf changes page
  count, update the `#require(doc.pageCount == N)` calls and `parts.count`
  expectation.

## CLI conventions

- Both tools follow poppler semantics: `pdftotext` derives `.txt` from input
  when output is omitted and treats `-` as stdout; `pdftoppm` treats input `-`
  as stdin.
