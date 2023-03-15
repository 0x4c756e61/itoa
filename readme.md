# ITOA

## Image TO Ascii

### Note: windows problem seems to be fixed (it runs under wine)

### Description

A rather simple tool to convert your favourite images to **ascii**

### Discord color support

Providing the `--discord` flag itoa will convert any pixel color to the closest discord one
Results will be printed in the terminal (unless you use the `--quiet` flag)
To see the results in discord, just upload the file ending in `.ansi`
<br>
It has some issues though:
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
