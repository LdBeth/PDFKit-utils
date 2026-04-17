import ArgumentParser
import Foundation
import PDFKit
import PDFToolsCore

@main
struct PDFToText: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "pdftotext",
        abstract: "Extract text from a PDF file (Apple PDFKit)"
    )

    @Argument(help: "Input PDF file path")
    var input: String

    @Argument(help: "Output text file path (omit to write to stdout)")
    var output: String?

    @Option(name: .customShort("f"), help: "First page to extract (1-based, default: 1)")
    var firstPage: Int = 1

    @Option(name: .customShort("l"), help: "Last page to extract (default: last page)")
    var lastPage: Int?

    @Flag(name: .long, help: "Do not insert form feed between pages")
    var nopgbrk: Bool = false

    mutating func run() throws {
        let url = URL(fileURLWithPath: (input as NSString).expandingTildeInPath)
        guard let document = PDFDocument(url: url) else {
            throw ValidationError("Cannot open PDF: \(input)")
        }

        let text = PDFTextExtractor.extractText(
            from: document,
            firstPage: firstPage,
            lastPage: lastPage,
            pageBreak: !nopgbrk
        )

        if let outputPath = output {
            let outURL = URL(fileURLWithPath: (outputPath as NSString).expandingTildeInPath)
            try text.write(to: outURL, atomically: true, encoding: .utf8)
        } else {
            print(text, terminator: "")
        }
    }
}
