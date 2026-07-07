//
//  ImportProcessingError.swift
//  Mula
//
//  Created by Codex on 6/7/26.
//

import Foundation

public enum ImportProcessingError: LocalizedError {
    case missingHeaders
    case unsupportedFormat(headers: [String])
    case noImportableContent(detectedSource: ImportSource, skippedRows: [SkippedImportRow])

    public var errorDescription: String? {
        switch self {
        case .missingHeaders:
            return "This file does not appear to contain CSV headers."

        case .unsupportedFormat(let headers):
            return "This CSV format is not supported yet. Found headers: \(headers)."

        case .noImportableContent(let detectedSource, let skippedRows):
            let sourceName = detectedSource.displayName

            if skippedRows.isEmpty {
                return "No importable data was found for \(sourceName)."
            }

            return "No importable data was found for \(sourceName). \(skippedRows.count) rows were skipped."
        }
    }
}
