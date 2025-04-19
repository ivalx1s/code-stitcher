import Foundation

CodeStitcher.main()

enum CodeStitcher {
    static func main() {
        let args = Args.parse(CommandLine.arguments)
        guard let mode = Args.Mode(rawValue: args.mode) else {
            return exiting("Invalid or missing mode")
        }

        switch mode {
            case .read:
                read(from: args.source, to: args.destination)
            case .write:
                write(from: args.source, to: args.destination, dryRun: false)
            case .writeDryRun:
                write(from: args.source, to: args.destination, dryRun: true)
        }
    }
}

// reading
extension CodeStitcher {
    private static func read(from source: String, to destination: String) {
        let fm = FileManager.default
        let currentURL = URL(fileURLWithPath: fm.currentDirectoryPath)
        let sourceURL = URL(fileURLWithPath: source, relativeTo: currentURL).standardized
        let destURL = URL(fileURLWithPath: destination, relativeTo: currentURL).standardized

        guard fm.fileExists(atPath: sourceURL.path) else {
            return exiting("Source directory does not exist: \(sourceURL.path)")
        }

        let gitignore = Gitignore.load(from: sourceURL)

        let filesContent = (fm.enumerator(at: sourceURL, includingPropertiesForKeys: nil)?
            .compactMap { $0 as? URL }
            .filter { Const.allowedExtensions.contains($0.pathExtension) }
            .filter { Gitignore.shouldInclude($0, sourceURL: sourceURL, rules: gitignore) }
            .compactMap { url -> String? in
                guard let content = try? String(contentsOf: url) else { return nil }
                let relativePath = url.path.replacingOccurrences(of: sourceURL.path + "/", with: "")
                return [Const.fileStart(relativePath), content, Const.fileEnd(relativePath)].joined(separator: "\n")
            } ?? [])
            .joined(separator: "\n\n")

        do {
            try filesContent.write(to: destURL, atomically: true, encoding: .utf8)
            print("✅ Successfully written to \(destURL.path)")
        } catch {
            exiting("Failed to write file: \(error)")
        }
    }
}

// writing
extension CodeStitcher {
    private static func write(from source: String, to destination: String, dryRun: Bool) {
        let fm = FileManager.default
        let currentURL = URL(fileURLWithPath: fm.currentDirectoryPath)
        let sourceURL = URL(fileURLWithPath: destination, relativeTo: currentURL).standardized
        let inputURL = URL(fileURLWithPath: source, relativeTo: currentURL).standardized

        guard fm.fileExists(atPath: sourceURL.path),
              let inputContent = try? String(contentsOf: inputURL) else {
            return exiting("Missing source directory or input file")
        }

        let gitignore = Gitignore.load(from: sourceURL)

        let existingFiles = Set((fm.enumerator(at: sourceURL, includingPropertiesForKeys: nil)?
            .compactMap { $0 as? URL }
            .filter { Const.allowedExtensions.contains($0.pathExtension) }
            .filter { Gitignore.shouldInclude($0, sourceURL: sourceURL, rules: gitignore) }
            .map { $0.path.replacingOccurrences(of: sourceURL.path + "/", with: "") } ?? []))

        if !dryRun {
            existingFiles.forEach { path in
                try? fm.removeItem(at: sourceURL.appendingPathComponent(path))
            }
        }

        let regexPattern = Const.regexPattern
        guard let regex = try? NSRegularExpression(pattern: regexPattern, options: [.dotMatchesLineSeparators]) else {
            return exiting("Invalid regex pattern")
        }

        let matches = regex.matches(in: inputContent, range: NSRange(inputContent.startIndex..., in: inputContent))
        let restoredFiles = matches.compactMap { match -> String? in
            let nsContent = inputContent as NSString
            let relativePath = nsContent.substring(with: match.range(at: 1))
            let fileContent = nsContent.substring(with: match.range(at: 2))

            if dryRun {
                print(existingFiles.contains(relativePath) ? "♻️ Would replace: \(relativePath)" : "✅ Would add: \(relativePath)")
                return relativePath
            }

            let targetURL = sourceURL.appendingPathComponent(relativePath)
            try? fm.createDirectory(at: targetURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            do {
                try fileContent.write(to: targetURL, atomically: true, encoding: .utf8)
                print(existingFiles.contains(relativePath) ? "♻️ Replaced: \(relativePath)" : "✅ Added: \(relativePath)")
            } catch {
                exiting("Failed to write: \(relativePath), error: \(error)")
            }
            return relativePath
        }

        existingFiles.subtracting(restoredFiles).forEach {
            print("❌ Deleted: \($0)")
        }

        print(dryRun ? "✅ Dry run complete" : "✅ Write complete")
    }
}

// exiting
extension CodeStitcher {
    private static func exiting(_ message: String) {
        print("❌ \(message)")
        Foundation.exit(1)
    }
}