# spdx

> A slightly opinionated CLI tool for managing SPDX licenses and copyright
> headers in your projects (powered by [babashka][bb])

[bb]: https://babashka.org/

## Features

- Initialize LICENSE files from official SPDX license templates
- Add copyright headers to source files automatically
- Check for missing headers without modifying files
- Auto-detect license information from existing LICENSE.spdx files
- Respect .gitignore patterns when processing files
- Support multiple languages with appropriate comment syntax
- Preserve shebangs in executable scripts
- Replace existing headers while preserving other content

## Installation

### Using nix

``` bash
# Run directly
$ nix run github:ramblurr/spdx-util
spdx - A tool for managing licenses in your project

Usage: spdx <command> [options]

Commands:
  init <SPDX-ID>  Initialize a LICENSE file with the specified SPDX identifier
  check           Check for missing license headers in source files
  fix             Fix missing license headers in source files

Run 'spdx <command> --help' for more information on a command.
```

Add to your flake:

``` nix
{
  inputs.spdx-util.url = "https://flakehub.com/f/ramblurr/spdx-util/0.1.4";
  outputs = { self, spdx-util }: {
    # use the package: spdx-util-packages.x86_64-linux.default
  };
```

### Manual

Ensure you have [Babashka][bb] installed, then download and make the script executable:

```bash
wget https://github.com/Ramblurr/spdx-util/raw/refs/heads/main/spdx
chmod +x spdx
```

Optionally, add it to your PATH or create an alias:

```bash
alias spdx='/path/tspdx'
```

## Usage

### Common workflow

```bash
# Setting up a new project
spdx init MIT
spdx fix

# CI/CD integration - fail if files are missing headers
spdx check

# Multi-language project
spdx fix --extension clj --extension py --extension js

# Gradual adoption - check first, then fix
spdx check src/core/
spdx fix src/core/
```

### Initialize a new license

Create LICENSE and LICENSE.spdx files for your project:

```bash
# Create Apache 2.0 license files
spdx init Apache-2.0

# Specify copyright holder
spdx init MIT --copyright "Jane Doe <jane@example.com>"

# Specify year
spdx init MIT --year 2023
```

### Check for missing headers

Check which files are missing copyright headers without modifying them:

```bash
# Check all source files in current directory
spdx check

# Check specific directories
spdx check src/ test/

# Check specific file types
spdx check --extension clj --extension py

# Exclude patterns
spdx check --exclude "target/*" --exclude "*.generated.clj"
```

### Fix missing headers

Add SPDX-compliant copyright headers to files that are missing them:

```bash
# Add headers to all source files in current directory
spdx fix

# Process specific directories
spdx fix src/ test/

# Process specific file types
spdx fix --extension clj --extension py

# Exclude patterns
spdx fix --exclude "target/*" --exclude "*.generated.clj"

# Override copyright and year
spdx fix --copyright "ACME Corp" --year 2024
```

## Pre-commit Integration

You can use `spdx` as a [pre-commit](https://pre-commit.com/) hook to automatically check for missing license headers:

1. Ensure you have [Babashka][bb] installed on your system (pre-commit won't install it automatically)

2. Add this to your `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/ramblurr/spdx-util
    rev: main
    hooks:
      - id: spdx
        args: [check]
        # Optional: specify file extensions to check
        # args: [check, --extension, py, --extension, js]
```

3. Install the pre-commit hook:

```bash
pre-commit install
```

Now the hook will run automatically before each commit, failing if any files are missing license headers.

To run the hook manually:

```bash
pre-commit run spdx --all-files
```

## Configuration

The tool automatically detects configuration from your project:

1. **SPDX ID** - Read from LICENSE.spdx file (`PackageLicenseDeclared` field)
2. **Copyright** - Read from LICENSE.spdx file (`PackageOriginator` field), falls back to git config
3. **Project root** - Found by looking upward from $PWD for `.git` or `flake.nix` directories

Example LICENSE.spdx file:

```
SPDXVersion: SPDX-2.1
DataLicense: CC0-1.0
PackageName: my-project
PackageOriginator: Jane Doe <jane@example.com>
PackageHomePage: https://github.com/jane/my-project
PackageLicenseDeclared: Apache-2.0
```

## License Data Sources

The tool fetches SPDX license data in the following priority order:

1. **Environment variable** - If `SPDX_LICENSES_PATH` is set, reads from
   `$SPDX_LICENSES_PATH/licenses.json`
2. **Local cache** - Checks XDG cache directory (e.g., `~/.cache/spdx/licenses.json`)
3. **Network** - Fetches from the official SPDX repository at https://github.cospdx/license-list-data

When fetching from the network, the data is automatically cached for future use.

## Header Format

Here comes the opinions...

The tool adds a two-line copyright header at the top of files:

```clojure
;; Copyright © 2024 ACME Corp
;; SPDX-License-Identifier: Apache-2.0
```

For files with shebangs, the header is inserted after the shebang line:

```bash
#!/usr/bin/env python3
# Copyright © 2024 ACME Corp
# SPDX-License-Identifier: Apache-2.0
```

## Gitignore Support

The tool respects `.gitignore` patterns by default. Additionally, you can
specify custom exclude patterns with the `--exclude` option:

- `*.tmp` - Matches all .tmp files
- `build/*` - Matches all files in build directory
- `test.clj` - Matches specific file

## License: European Union Public License 1.2

Copyright © 2025 Casey Link <casey@outskirtslabs.com> Distributed under the
[EUPL-1.2](https:spdx.org/licenses/EUPL-1.2.html).
