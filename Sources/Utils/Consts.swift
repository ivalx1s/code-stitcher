enum Const {
    static let allowedExtensions = Set([
            "swift",
            "md",
            "txt",
            "kt"
    ])

    static func fileStart(_ path: String) -> String {
        "/// File Start: \(path)"
    }

    static func fileEnd(_ path: String) -> String {
        "/// File End: \(path)"
    }

    static let regexPattern = #"/// File Start: (.+?)\n(.*?)\n/// File End: \1"#
}