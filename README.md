
# CodeStitcher

**CodeStitcher** is a utility for serializing and restoring source code project structure. It lets you pack an entire project into a single `.txt` file and unpack it back into a directory structure.

## Why?

Use it when you want to:
- share a whole project in a single file (for review or archival);
- integrate with CI/CD workflows (pack, transfer, unpack);
- store a project in a flat, readable format (e.g. in systems where nested directories are a hassle).

## How It Works

All files with supported extensions are wrapped in special meta-tags and joined into a single `.txt` file:

```
/// File Start: path/to/file.swift
<file content>
/// File End: path/to/file.swift
```

Files ignored by `.gitignore` are excluded.

## Supported Extensions

- `.swift`
- `.md`
- `.txt`
- `.kt`

## Examples

### Pack the project:

```bash
swift run CodeStitcher -- \
  mode:read \
  source:./ \
  destination:./result.txt
```

This will save the entire project into `result.txt`.

### Unpack the project:

```bash
swift run CodeStitcher -- \
  mode:write \
  source:./result.txt \
  destination:./
```

This will create (or overwrite) the folder structure from `result.txt`.

## Dry Run

You can simulate unpacking without modifying any files:

```bash
swift run CodeStitcher -- \
  mode:writeDryRun \
  source:./result.txt \
  destination:./
```

## Author

🔥 Built with care for the homies.
