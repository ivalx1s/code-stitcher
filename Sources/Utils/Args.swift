enum Args {
    case mode, source, destination
    enum Mode: String { case read, write, writeDryRun }

    static func parse(_ rawArgs: [String]) -> (mode: String, source: String, destination: String) {
        var dict = [String: String]()
        rawArgs
            .dropFirst()
            .forEach {
                let parts = $0.split(separator: ":", maxSplits: 1).map(String.init)
                if parts.count == 2 {
                    dict[parts[0]] = parts[1]
                }
        }
        return (dict["mode"] ?? "", dict["source"] ?? "", dict["destination"] ?? "")
    }
}