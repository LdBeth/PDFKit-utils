# PDFKit CLI tools (pdftotext, pdftoppm)

## Build & test

- Build: `swift build` (release: `swift build -c release`)
- Tests: `./run-tests.sh` — NOT `swift test`. swift-testing is resolved via
  `$CLT/Library/Developer/Frameworks`; plain `swift test` errors with
  `no such module 'Testing'`.
- SourceKit/LSP does not see the `-F` framework path, so `Testing` shows as a
  missing-module diagnostic in the editor. Ignore it; the test run is
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
