# PDFTools

Command-line tools for extracting text and rendering images from PDFs, built on Apple's PDFKit framework.

## Tools

### pdftotext

Extract plain text from a PDF file.

```
USAGE: pdftotext <input> [<output>] [-f <f>] [-l <l>] [--nopgbrk]

ARGUMENTS:
  <input>    Input PDF file path
  <output>   Output text file path (omit to derive from input; '-' for stdout)

OPTIONS:
  -f <f>     First page to extract (1-based, default: 1)
  -l <l>     Last page to extract (default: last page)
  --nopgbrk  Do not insert form feed between pages
```

If `<output>` is omitted, `document.pdf` is written to `document.txt`. Pass `-` to write to stdout.

**Examples:**

```sh
# Convert document.pdf -> document.txt
pdftotext document.pdf

# Write to stdout
pdftotext document.pdf -

# Save to a specific file
pdftotext document.pdf output.txt

# Extract only pages 3–5
pdftotext document.pdf -f 3 -l 5

# No page-break characters between pages
pdftotext document.pdf --nopgbrk
```

---

### pdftoppm

Convert PDF pages to raster images (PNG, JPEG, or TIFF).

```
USAGE: pdftoppm <input> <output-prefix> [-r <r>] [-f <f>] [-l <l>]
                [--png] [--jpeg] [--tiff]
                [--scale-to <n>] [--jpeg-quality <n>]

ARGUMENTS:
  <input>          Input PDF file path ('-' to read from stdin)
  <output-prefix>  Output filename prefix (e.g. "out" → "out-001.png")

OPTIONS:
  -r <r>                Resolution in DPI (default: 150)
  -f <f>                First page (1-based, default: 1)
  -l <l>                Last page (default: last page)
  --png                 Output PNG format (default)
  --jpeg                Output JPEG format
  --tiff                Output TIFF format
  --scale-to <n>        Scale so the longest side equals N pixels (overrides -r)
  --jpeg-quality <n>    JPEG quality 0–100 (default: 85)
```

**Examples:**

```sh
# Convert all pages to PNG at 150 DPI
pdftoppm document.pdf pages

# Convert page 1 only at 300 DPI
pdftoppm document.pdf pages -f 1 -l 1 -r 300

# Convert to JPEG, scale longest side to 1200px
pdftoppm document.pdf pages --jpeg --scale-to 1200

# Convert pages 2–4 to TIFF
pdftoppm document.pdf pages -f 2 -l 4 --tiff

# Read PDF from stdin
cat document.pdf | pdftoppm - pages
```

Output files are named `<prefix>-001.png`, `<prefix>-002.png`, etc., with zero-padding based on total page count.

---

## Build

Requires macOS 14+ and the Xcode Command Line Tools or Xcode.

```sh
swift build -c release
```

Binaries will be at `.build/release/pdftotext` and `.build/release/pdftoppm`.

## Install

```sh
cp .build/release/pdftotext .build/release/pdftoppm ~/bin/
```
