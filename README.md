# DMX PDF Search

A plugin for the [DMX platform](https://github.com/dmx-systems/dmx-platform).
It makes PDF files searchable by their text content.
PDF files containing just (scanned) images are processed by OCR to extract searchable text content.

## Installation

The DMX PDF Search plugin must be installed together with the [dmx-tesseract](https://github.com/dmx-systems/dmx-tesseract) plugin.

Released versions are available at:  
https://download.dmx.systems/plugins/dmx-pdf-search/  

Snapshot versions (work in progress) are available at:  
https://download.dmx.systems/ci/dmx-pdf-search/  

As with any DMX plugin you install it by copying the respective `.jar` file to DMX's `bundle-deploy/` directory. Restarting the DMX platform is not required.

## How it works

Every time DMX creates a `File` topic which represents a PDF file the PDF Search plugin extracts its text content and adds it to the File topic's fulltext index. If no text could be extracted OCR is tried.

`File` topics are created when you browse the DMX file repository or upload a file to it.

## Usage

To search for PDF files by content you can use the regular search dialog of the DMX Webclient. Matching File topics are shown then in the search result.

## Version History

**1.0** -- Dec 18, 2023

* Extract text from PDF files and add to fulltext index
* For image-only PDF files OCR is tried
* PDF files are searchable by regular DMX Webclient search dialog
* Compatible with DMX 5.3.4 or later
