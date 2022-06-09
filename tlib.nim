##[
 `TLIB`, my custom terminal library
]##

import strformat, os, sysinfo, strutils, osproc

proc rgb*(r:Natural, g:Natural, b:Natural): string=
    ## Return RGB escape sequance
    result = &"\e[38;2;{r};{g};{b}m"

proc read*(args: string): string =
    ## Same as INPUT in python
    stdout.write(args)
    result = stdin.readline()

proc def*():string =
    ## Return default color code
    result = "\e[0m"

proc italic*():string =
    ## Return Italic code
    result = "\e[3m"

proc bold*():string =
    result = "\e[21m"

proc clear*()=
    ## Clear the screen using system commands
    var cmd: string
    if "Windows" in getOsName():
        cmd = "cls"
    else:
        cmd = "clear"
    
    discard os.execShellCmd(cmd)

proc `*`*(str: string, n:Natural): string=
    ## Repeate n times the string str
    for _ in 1..n:
        result &= str

proc `*`*(ch: char, n:Natural): string=
    ## Repeate n times the char ch
    for _ in 1..n:
        result &= ch

proc `**`*(n:int, z:int): int=
    result = n*z

proc `**`*(n:float, z:float): float=
    result = n*z

proc rmline*():string=
    result = "\e[2K"

proc hidecursor*() =
  when defined(windows):
    discard
  else:
    stdin.write("\e[?25l")

type EKeyboardInterrupt* = object of CatchableError
proc handler() {.noconv.} =
  raise newException(EKeyboardInterrupt, "Keyboard Interrupt")
setControlCHook(handler)

proc showcursor*() =
  when defined(windows):
    discard
  else:
    stdin.write("\e[?25h")

when isMainModule:
    echo "This can't be used by itself"
    quit(1)

when not isMainModule:
    if "Windows" in getOsName():
        let regi = execCmdEx("reg query HKCU\Console /v VirtualTerminalLevel")[0]
        if "0x1" in regi:
            discard os.execShellCmd("reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 00000001")
