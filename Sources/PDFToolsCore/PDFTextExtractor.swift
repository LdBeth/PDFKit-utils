import Foundation
import PDFKit

extension PDFDocument {
  /// Resolves a 1-based inclusive page range into a 0-based index range,
  /// clamped to the document's page bounds. Returns nil if the range is empty.
  public func resolvePageRange(firstPage: Int = 1, lastPage: Int? = nil) -> ClosedRange<Int>? {
    let first = max(firstPage - 1, 0)
    let last = min((lastPage ?? pageCount) - 1, pageCount - 1)
    return first <= last ? first...last : nil
  }
}

public struct PDFTextExtractor {

  public static func extractText(
    from document: PDFDocument,
    firstPage: Int = 1,
    lastPage: Int? = nil,
    pageBreak: Bool = true
  ) -> String {
    guard let range = document.resolvePageRange(firstPage: firstPage, lastPage: lastPage) else {
      return ""
    }
    return
      range
      .compactMap { document.page(at: $0).map { $0.string ?? "" } }
      .joined(separator: pageBreak ? "\u{000C}" : "\n")
  }
}
