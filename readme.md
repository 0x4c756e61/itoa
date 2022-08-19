# ITOA

## Image TO Ascii

### Note: windows problem seems to fixed (runs under wine)

### Description

A rather simple tool to convert your favourite images to **ascii**

### Discord color support

Providing the `--discord` flag itoa will convert any pixel color to the closest discord one
Results will be printed in the terminal (unless you use the `--quiet` flag)
To see the results in discord, just upload the file ending in `.ansi`
<br>
It has some issues tho:
 - Discord only provides 8 colors (so expect some weird results)
 - Can only be sent as files (Due to the 2k characters limit)
 - May freeze your discord client


### Compiling
#### Requirements
- Any recent Nim version
#### Linux
Open a terminal window inside of the project's directory and run
`nim -d:pixieUseStb -d:release -d:danger -d:strip --opt:size c imgToAscii.nim`
\
You can now run `./imgToAscii`

#### Windows
Open cmd, powershell or MS terminal in the project's folder and run `nim -d:mingw -d:release -d:danger -d:strip --opt:size c imgToAscii.nim`
\
You can now run `imgToAscii`
