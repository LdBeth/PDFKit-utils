import Foundation
import PDFKit
import Testing

@testable import PDFToolsCore

// MARK: - Helpers

private func renderText(_ text: String) -> NSImage {
  let size = NSSize(width: 200, height: 60)
  let image = NSImage(size: size)
  image.lockFocus()
  NSColor.white.setFill()
  NSRect(origin: .zero, size: size).fill()
  let attr = NSAttributedString(
    string: text,
    attributes: [.font: NSFont.systemFont(ofSize: 12)]
  )
  attr.draw(at: NSPoint(x: 10, y: 20))
  image.unlockFocus()
  return image
}

/// Builds an in-memory PDF with `pageCount` image-backed pages.
private func makePDF(text: String, pageCount: Int = 1) -> PDFDocument {
  let doc = PDFDocument()
  for i in 0..<pageCount {
    if let page = PDFPage(image: renderText("\(text) \(i + 1)")) {
      doc.insert(page, at: i)
    }
  }
  return doc
}

// MARK: - resolvePageRange

@Suite("resolvePageRange")
struct ResolvePageRangeTests {

  @Test func defaults() {
    let doc = makePDF(text: "Hello", pageCount: 3)
    #expect(doc.resolvePageRange() == 0...2)
  }

  @Test func clampsLastPage() {
    let doc = makePDF(text: "Hello", pageCount: 3)
    #expect(doc.resolvePageRange(firstPage: 1, lastPage: 99) == 0...2)
  }

  @Test func clampsFirstPage() {
    let doc = makePDF(text: "Hello", pageCount: 3)
    #expect(doc.resolvePageRange(firstPage: -5, lastPage: 2) == 0...1)
  }

  @Test func emptyReturnsNil() {
    let doc = makePDF(text: "Hello", pageCount: 3)
    #expect(doc.resolvePageRange(firstPage: 3, lastPage: 2) == nil)
  }

  @Test func emptyDocumentReturnsNil() {
    let doc = PDFDocument()
    #expect(doc.resolvePageRange() == nil)
  }

  @Test func singlePage() {
    let doc = makePDF(text: "Hello", pageCount: 5)
    #expect(doc.resolvePageRange(firstPage: 2, lastPage: 2) == 1...1)
  }

  @Test func lastPageZeroIsEmpty() {
    let doc = makePDF(text: "Hello", pageCount: 3)
    #expect(doc.resolvePageRange(firstPage: 1, lastPage: 0) == nil)
  }

  @Test func firstPagePastEndIsEmpty() {
    let doc = makePDF(text: "Hello", pageCount: 3)
    #expect(doc.resolvePageRange(firstPage: 10) == nil)
  }

  @Test func interiorInvertedRangeIsEmpty() {
    let doc = makePDF(text: "Hello", pageCount: 5)
    #expect(doc.resolvePageRange(firstPage: 4, lastPage: 2) == nil)
  }
}

// MARK: - extractText

/// Locates README.pdf at the repo root, relative to this test file.
private func readmePDFURL(file: String = #filePath) -> URL {
  URL(fileURLWithPath: file)
    .deletingLastPathComponent()  // PDFToolsCoreTests
    .deletingLastPathComponent()  // Tests
    .deletingLastPathComponent()  // repo root
    .appendingPathComponent("README.pdf")
}

@Suite("PDFTextExtractor")
struct ExtractTextTests {

  @Test func emptyDocument() {
    let doc = PDFDocument()
    #expect(PDFTextExtractor.extractText(from: doc) == "")
  }

  @Test func formFeedSeparatorExactlyOncePerPageBoundary() throws {
    let doc = try #require(PDFDocument(url: readmePDFURL()))
    try #require(doc.pageCount == 3)
    let out = PDFTextExtractor.extractText(from: doc, pageBreak: true)
    let parts = out.components(separatedBy: "\u{000C}")
    #expect(parts.count == 3)
    #expect(parts[0].contains("PDFTools"))
    #expect(parts[1].contains("Resolution in DPI"))
  }

  @Test func newlineSeparatorHasNoFormFeed() throws {
    let doc = try #require(PDFDocument(url: readmePDFURL()))
    try #require(doc.pageCount == 3)
    let out = PDFTextExtractor.extractText(from: doc, pageBreak: false)
    #expect(!out.contains("\u{000C}"))
    // Two pages joined by "\n": the boundary newline must be present in addition
    // to any intra-page newlines.
    #expect(out.contains("PDFTools"))
    #expect(out.contains("Resolution in DPI"))
  }

  @Test func pageRangeExtractsOnlyRequestedPage() throws {
    let doc = try #require(PDFDocument(url: readmePDFURL()))
    try #require(doc.pageCount == 3)
    let p1 = PDFTextExtractor.extractText(from: doc, firstPage: 1, lastPage: 1)
    let p2 = PDFTextExtractor.extractText(from: doc, firstPage: 2, lastPage: 2)
    #expect(!p1.contains("\u{000C}"))
    #expect(!p2.contains("\u{000C}"))
    #expect(p1.contains("PDFTools"))
    #expect(p2.contains("Resolution in DPI"))
    #expect(!p1.contains("Resolution in DPI"))
  }

  @Test func emptyRangeYieldsEmptyString() throws {
    let doc = try #require(PDFDocument(url: readmePDFURL()))
    #expect(PDFTextExtractor.extractText(from: doc, firstPage: 10) == "")
  }
}

// MARK: - ImageFormat

@Suite("ImageFormat")
struct ImageFormatTests {

  @Test func fileExtensions() {
    #expect(PDFRenderer.ImageFormat.png.fileExtension == "png")
    #expect(PDFRenderer.ImageFormat.jpeg.fileExtension == "jpeg")
    #expect(PDFRenderer.ImageFormat.tiff.fileExtension == "tiff")
  }

  @Test func allCasesCount() {
    #expect(PDFRenderer.ImageFormat.allCases.count == 3)
  }
}

// MARK: - renderPage + saveImage

@Suite("PDFRenderer")
struct PDFRendererTests {

  @Test func renderAndSavePNG() throws {
    let doc = makePDF(text: "Render", pageCount: 1)
    let page = try #require(doc.page(at: 0))
    let image = try #require(PDFRenderer.renderPage(page, dpi: 72))
    #expect(image.width > 0)
    #expect(image.height > 0)

    let tmp = FileManager.default.temporaryDirectory
      .appendingPathComponent("pdftools-test-\(UUID().uuidString).png")
    defer { try? FileManager.default.removeItem(at: tmp) }

    try PDFRenderer.saveImage(image, to: tmp, format: .png)
    #expect(FileManager.default.fileExists(atPath: tmp.path))

    let data = try Data(contentsOf: tmp)
    let sig: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
    #expect(Array(data.prefix(8)) == sig)
  }

  @Test func scaleToLongestEdge() throws {
    let doc = makePDF(text: "Render", pageCount: 1)
    let page = try #require(doc.page(at: 0))
    let target = 300
    let image = try #require(PDFRenderer.renderPage(page, scaleTo: target))
    let longest = max(image.width, image.height)
    #expect(abs(longest - target) <= 1)
  }
}
