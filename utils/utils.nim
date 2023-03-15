import utilities/[tlib]
import std/[strformat, strutils,math]

const
    red* = tlib.rgb(255, 33, 81)
    # green = tlib.rgb(37, 255, 100)
    # yellow = tlib.rgb(246,255,69)
    blue* = tlib.rgb(105, 74, 255)
    dft* = def()
    charsLong* = "$@B%8&WM#*oahkbdpqwmZO0QLCJUYXzcvunxrjft/\\|()1{}[]?-_+~i!lI;:,\"^`. "
    charsLongReversed* = " .`^\",:;Il!i~+_-?][}{1)(|\\/tfjrxunvczXYUJCLQ0OZmwqpdbkhao*#MW&8%B@$"
    charsShort* = "@%$#+=;:,. "
    charsShortReversed* = " .,:;+#$%@"
    discordColors* = {(79.0, 84.0, 92.0): 30,
                      (220.0, 50.0, 47.0): 31,
                      (128.0, 116.0, 27.0): 32,
                      (181.0, 137.0, 0.0): 33,
                      (45.0, 103.0, 195.0): 34,
                      (166.0, 54.0, 130.0): 35,
                      (42.0, 161.0, 152.0): 36,
                      (255.0, 255.0, 255.0): 37}

var
    helpMenu* = &"""
{red}imgTOAscii{dft} version {blue}0.0.1{dft}
{red}imgTOAscii{dft} is a tool to convert images to {blue}ASCII{dft}.

{red}USAGE{dft}:
    itoa [OPTIONS] FILE_PATH

{red}OPTIONS{dft}:"""

proc registerHelp*(calls: array[0..1, string], desc: string) =
    let options = calls.join(", ")
    let thing = &"\n    {blue}{options}{dft}"
    let space = " ".repeat(50-len(thing))
    helpMenu &= thing & space & desc

# get closest discord ansi color
proc getDiscordColor*(r, g, b: uint8): string =
    var closest: float
    result = "37"
    for color in discord_colors:
        let d = ((r.float - color[0][0])*0.299).pow(2.0) + ((g.float - color[0][
                1])*0.587).pow(2.0) + ((b.float - color[0][2])*0.114).pow(2.0)

        if d > closest:
            result = $color[1]

proc error*(str: string) =
    echo &"[{red}ERROR{dft}]   {str}"
    quit(1)

proc info*(str: string) =
    echo &"[{blue}INFO{dft}]    {str}"
    quit(1)

proc exit*() {.noconv.} =
    echo "\nThanks for using ITOA."