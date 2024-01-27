## Image TO Ascii
[![license](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.fr.html)
[![language](https://img.shields.io/badge/Language-Nim-yellow)](https://nim-lang.org)
![downloads](https://img.shields.io/github/downloads/0x454d505459/itoa/total?color=0effa7&label=Downloads)

---
Convert your favourite images to **ascii**

### Supported image format
- PNG
- JPEG
- BMP
- QOI
- GIF
- SVG
- PPM

### Features
- [x] Show in terminal
- [x] Progress bar (thanks to [suru](https://github.com/de-odex/suru))
- [x] Multiple character sets
- [x] Background coloring
- [x] Discord ansi [color support](#discord-color-support)
- [x] Change width
- [x] Export to text file (with or without color)
- [x] Custom character sets
- [ ] GPU Acceleration

### Supported OSes
- *NIX
- Windows

### Discord color support
Given the `--discord` flag, ITOA will try to convert every pixel to the closest color supported by Discord's ansi highlighter.<br>
Resulting image will be printed out on the therminal (unless the `quiet` flag is given).<br>
To see the results in discord, just upload the file ending in `.ansi`. (Discord won't render colors if the image is too big)

<br>

Discord color support is rudimental, and has some issues:
 - Discord only provides 8 colors (so expect weird results)
 - Can only be sent as files (Due to the 2k characters limit)
 - May freeze your discord client (rendering so much characters, including the escape sequences, is hard, and so may freeze your client)


### Compiling
#### Requirements
- Any recent Nim version
#### Steps
1. Open a terminal/cmd/powershell window inside the project folder
2. Build a release binary with `nim release imgToAscii.nim`
3. Done


### Used libraries
- [suru](https://github.com/de-odex/suru) for progress tracking
- [pixie](https://github.com/treeform/pixie) for image processing
- [utilities-nim](https://github.com/0x454d505459/utilities-nim) for character coloring and other stuff
