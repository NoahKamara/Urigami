# Urigami

Urigami is a command-line utility for managing default applications on macOS. It allows you to get information about installed applications, find default apps for specific file types or URIs, and set default applications.

## Installation

### Homebrew

```bash
brew install noahkamara/homebrew-tap/urigami
```

### Build

```bash
./build.sh # the executable will be at ./urigami
```

## Usage

Urigami provides several subcommands:

```bash
urigami <subcommand>
```

### Subcommands

1. `opens`: Find the default app(s) for a given input
2. `appinfo`: Get information about an installed application
3. `setdefault`: Set the default app for a given input

## Examples

Show metadata for Preview.app including

```bash
urigami appinfo Preview --uti 
```

Show applications that can open .png files

```bash
urigami opens .png 
```

Open pdf files in Arc by default

```bash
urigami setdefault .pdf Arc 
```

## Contributing

Contributions welcome!
