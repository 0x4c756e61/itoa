import std/[strformat, strutils]
import strings, coloring

proc registerHelp*(calls: array[0..1, string], desc: string) =
    let options = calls.join(", ")
    let thing = &"\n    {blue}{options}{dft}"
    let space = " ".repeat(50-len(thing))
    helpMenu &= thing & space & desc

proc error*(str: string) =
    echo &"[{red}ERROR{dft}]   {str}"
    quit(1)

proc info*(str: string) =
    echo &"[{blue}INFO{dft}]    {str}"
    quit(1)

proc exit*() {.noconv.} =
    echo "\nThanks for using ITOA."