# Urigami

Urigami is a command-line utility for managing default applications on macOS. It allows you to get information about installed applications, find default apps for specific file types or URIs, and set default applications.

## Installation

[Provide installation instructions here, e.g., how to download or install via package manager]

## Usage

Urigami provides several subcommands:

```
urigami <subcommand>
```

### Subcommands

1. `opens`: Find the default app(s) for a given input
2. `appinfo`: Get information about an installed application
3. `setdefault`: Set the default app for a given input


## Examples

```bash
urigami opens .png # show applications that can open .png files
urigami appinfo Preview # show info for Preview.app
urigami setdefault image/png Preview # open png files in Preview ****default
```

## Contributing
Contributions welcome! 
