import Foundation

enum Gitignore {
    static func load(from url: URL) -> [String] {
        guard let content = try? String(contentsOf: url.appendingPathComponent(".gitignore"))
        else { return [] }

        return content
            .split(separator: "\n")
            .map(String.init)
            .filter { !$0.isEmpty && !$0.hasPrefix("#") }
    }

    static func shouldInclude(_ url: URL, sourceURL: URL, rules: [String]) -> Bool {
        let relativePath = url
            .path
            .replacingOccurrences(of: sourceURL.path + "/", with: "")

        return !rules.contains {rule in
            relativePath.hasPrefix(rule)
            || relativePath == rule
        }
    }
}