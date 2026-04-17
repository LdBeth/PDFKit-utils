import ArgumentParser
import Foundation
import PDFKit
import PDFToolsCore

@main
struct PDFToPPM: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "pdftoppm",
    abstract: "Convert PDF pages to raster images (Apple PDFKit)"
  )

  @Argument(help: "Input PDF file path")
  var input: String

  @Argument(help: "Output file prefix (e.g. 'out' → 'out-001.png')")
  var outputPrefix: String

  @Option(name: .customShort("r"), help: "Resolution in DPI (default: 150)")
  var resolution: Double = 150.0

  @Option(name: .customShort("f"), help: "First page (1-based, default: 1)")
  var firstPage: Int = 1

  @Option(name: .customShort("l"), help: "Last page (default: last page)")
  var lastPage: Int?

  @Flag(name: .long, help: "Output PNG format (default)")
  var png: Bool = false

  @Flag(name: .long, help: "Output JPEG format")
  var jpeg: Bool = false

  @Flag(name: .long, help: "Output TIFF format")
  var tiff: Bool = false

  @Option(name: .long, help: "Scale so longest side equals N pixels (overrides -r)")
  var scaleTo: Int?

  @Option(name: .long, help: "JPEG quality 0–100 (default: 85)")
  var jpegQuality: Int = 85

  mutating func run() throws {
    let url = URL(fileURLWithPath: (input as NSString).expandingTildeInPath)
    guard let document = PDFDocument(url: url) else {
      throw ValidationError("Cannot open PDF: \(input)")
    }

    let format: PDFRenderer.ImageFormat = tiff ? .tiff : jpeg ? .jpeg : .png

    guard let range = document.resolvePageRange(firstPage: firstPage, lastPage: lastPage) else {
      throw ValidationError(
        "Page range is empty (first: \(firstPage), last: \(lastPage ?? document.pageCount))")
    }

    let digits = String(document.pageCount).count
    let fmt = "%0\(digits)d"

    for i in range {
      guard let page = document.page(at: i) else {
        fputs("Warning: could not load page \(i + 1)\n", stderr)
        continue
      }
      guard let image = PDFRenderer.renderPage(page, dpi: resolution, scaleTo: scaleTo) else {
        fputs("Warning: could not render page \(i + 1)\n", stderr)
        continue
      }

      let suffix = String(format: fmt, i + 1)
      let outPath = "\(outputPrefix)-\(suffix).\(format.fileExtension)"
      let outURL = URL(fileURLWithPath: outPath)

      try PDFRenderer.saveImage(
        image, to: outURL, format: format, quality: Double(jpegQuality) / 100.0)
      print(outPath)
    }
  }
}
