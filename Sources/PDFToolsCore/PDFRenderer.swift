import CoreGraphics
import Foundation
import ImageIO
import PDFKit
import UniformTypeIdentifiers

public struct PDFRenderer {

  public enum ImageFormat: String, CaseIterable {
    case png, jpeg, tiff

    public var fileExtension: String { rawValue }

    var utiIdentifier: CFString {
      switch self {
      case .png: return "public.png" as CFString
      case .jpeg: return "public.jpeg" as CFString
      case .tiff: return "public.tiff" as CFString
      }
    }
  }

  public enum RenderError: Error, LocalizedError {
    case cannotCreateContext
    case cannotCreateDestination(URL)
    case cannotFinalize(URL)

    public var errorDescription: String? {
      switch self {
      case .cannotCreateContext:
        return "Failed to create CGContext"
      case .cannotCreateDestination(let u):
        return "Cannot create image destination at \(u.path)"
      case .cannotFinalize(let u):
        return "Cannot finalize image at \(u.path)"
      }
    }
  }

  /// Renders one PDF page to a CGImage.
  /// - Parameters:
  ///   - dpi: Output resolution (ignored when scaleTo is set)
  ///   - scaleTo: If set, scale so the longest edge equals this many pixels
  public static func renderPage(
    _ page: PDFPage,
    dpi: Double = 150.0,
    scaleTo: Int? = nil
  ) -> CGImage? {
    let mediaBox = page.bounds(for: .mediaBox)
    let scale: Double
    if let target = scaleTo {
      let longest = max(mediaBox.width, mediaBox.height)
      scale = Double(target) / Double(longest)
    } else {
      scale = dpi / 72.0
    }

    let width = Int((mediaBox.width * scale).rounded())
    let height = Int((mediaBox.height * scale).rounded())

    guard
      let ctx = CGContext(
        data: nil,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
      )
    else { return nil }

    ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
    ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))
    ctx.scaleBy(x: CGFloat(scale), y: CGFloat(scale))
    page.draw(with: .mediaBox, to: ctx)

    return ctx.makeImage()
  }

  /// Saves a CGImage to disk in the requested format.
  public static func saveImage(
    _ image: CGImage,
    to url: URL,
    format: ImageFormat,
    quality: Double = 0.85
  ) throws {
    guard
      let dest = CGImageDestinationCreateWithURL(
        url as CFURL,
        format.utiIdentifier,
        1,
        nil
      )
    else { throw RenderError.cannotCreateDestination(url) }

    var options: [CFString: Any] = [:]
    if format == .jpeg {
      options[kCGImageDestinationLossyCompressionQuality] = quality
    }
    CGImageDestinationAddImage(dest, image, options as CFDictionary)

    guard CGImageDestinationFinalize(dest) else {
      throw RenderError.cannotFinalize(url)
    }
  }
}
