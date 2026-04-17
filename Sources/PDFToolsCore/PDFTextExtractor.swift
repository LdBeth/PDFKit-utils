import PDFKit
import Foundation

public struct PDFTextExtractor {

    public static func extractText(
        from document: PDFDocument,
        firstPage: Int = 1,
        lastPage: Int? = nil,
        pageBreak: Bool = true
    ) -> String {
        let first = max(firstPage - 1, 0)
        let last  = min((lastPage ?? document.pageCount) - 1, document.pageCount - 1)
        guard first <= last else { return "" }

        var pages: [String] = []
        for i in first...last {
            guard let page = document.page(at: i) else { continue }
            pages.append(page.string ?? "")
        }
        return pages.joined(separator: pageBreak ? "\u{000C}" : "\n")
    }
}
