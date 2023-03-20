import std/strformat
import coloring


const
    charsLong* = "$@B%8&WM#*oahkbdpqwmZO0QLCJUYXzcvunxrjft/\\|()1{}[]?-_+~<>i!lI;:,\"^`. "
    charsLongReversed* = " .`^\",:;Il!i~+_-?][}{1)(|\\/tfjrxunvczXYUJCLQ0OZmwqpdbkhao*#MW&8%B@$"
    charsShort* = "@%$#+=;:,. "
    charsShortReversed* = " .,:;+#$%@"


var
    helpMenu* = &"""
{red}imgTOAscii{dft} version {blue}v0.04{dft}
{red}imgTOAscii{dft} is a tool to convert images to {blue}ASCII{dft}.

{red}USAGE{dft}:
    itoa [OPTIONS] FILE_PATH

{red}OPTIONS{dft}:"""