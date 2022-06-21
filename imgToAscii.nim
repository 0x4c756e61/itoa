import pixie, tlib, strformat, strutils, os

const
    red = tlib.rgb(255,33,81)
    green = tlib.rgb(37,255,100)
    # yellow = tlib.rgb(246,255,69)
    blue = tlib.rgb(105,74,255)
    dft = def()
    chars_long = "$@B%8&WM#*oahkbdpqwmZO0QLCJUYXzcvunxrjft/\\|()1{}[]?-_+~i!lI;:,\"^`. "
    chars_long_reversed = " .`^\",:;Il!i~+_-?][}{1)(|\\/tfjrxunvczXYUJCLQ0OZmwqpdbkhao*#MW&8%B@$"
    chars_short = "@%$#+=;:,. "
    chars_short_reversed = " .,:;+#$%@"

const banner = &"""
{red}    __________{blue} ____  ___ 
{red}   /  _/_  __/{blue}/ __ \/   |
{red}   / /  / /  {blue}/ / / / /| |
{red} _/ /  / /  {blue}/ /_/ / ___ |
{red}/___/ /_/   {blue}\____/_/  |_|
    {red}Image {blue}to Ascii{dft}
    """

var
    img_path = ""
    output_path = ""
    threshold = 25
    do_output = true
    width = 0
    chars = chars_short
    result_file = ""
    colored_result = ""
    help_menu = &"""
{red}imgTOAscii{dft} version {blue}0.0.1{dft}
{red}imgTOAscii{dft} is a tool to convert images to {blue}ASCII{dft}.

{red}USAGE{dft}:
    itoa [OPTIONS] FILE_PATH

{red}OPTIONS{dft}:"""

proc error(str: string) =
    echo &"[{red}ERROR{dft}]   {str}"
    quit(1)

proc exit() {.noconv.} =
    echo "\nThanks for using ITOA."

proc register_help(calls: array[0..1,string], desc:string) =
    let options = calls.join(", ")
    let thing = &"\n    {blue}{options}{dft}"
    let space = " " * (50-len(thing))
    help_menu &= thing & space & desc

when (not defined(windows)):
    proc drawBar(prog:int, total:int, text:string = "", char_completed:string = "#", char_not_completed:string="-") =
        let 
            percent = (prog/total * 100 / 2).int
            percent_r = (prog/total*100).int

        if percent_r == 100:
            stdout.writeLine(text & "[" & &"{green}{char_completed}{def()}" * 50 & "] " & &"{green}Done{def()}")
            moveCursorUp 1
            
        else:
            stdout.writeLine(text & "[" & &"{rgb(100, 2*percent_r, 0)}{char_completed}{def()}" * percent & char_not_completed * (50-percent) & "] " & $(percent_r) & "%")
            moveCursorUp 1

proc proccessArgs() =
    var discard_next = false
    for i in 1..os.paramCount():
        if discard_next: discard_next = false; continue
        let arg = os.paramStr(i)
        case arg
            of "-h", "--help":
                register_help(["-h", "--help"], "Show this page and quits")
                register_help(["-t", "--threshold"], "The accuracy of the conversion        Default: 24")
                register_help(["-w", "--width"], "Set the new width of image            Default: image_size/2")
                register_help(["-c", "--characters"], "Charset                               Default: Chars Available: short/s, long/l, reversed_short/rs, reversed_long/rl")
                register_help(["-o", "--output"], "Output file")
                register_help(["-q", "--quiet"], "Do not print to the console")
                echo help_menu
                quit(0)
            
            of "-t", "--threshold":
                discard_next = true
                if paramCount() < i+1: error "Missing argument THRESHOLD"
                threshold = parseInt(os.paramStr(i+1))
            
            of "-w", "--width":
                discard_next = true
                if paramCount() < i+1: error "Missing argument WIDTH"
                width = parseInt(os.paramStr(i+1))
            
            of "-c", "--characters":
                discard_next = true
                if paramCount() < i+1: error "Missing argument CHARACTERS"
                case paramStr(i+1):
                    of "short", "s":
                        chars = chars_short
                    of "long", "l":
                        chars = chars_long
                    of "reversed_short", "rs":
                        chars = chars_short_reversed
                    of "reversed_long", "rl":
                        chars = chars_long_reversed
                    else:
                        error &"Unknow charaters list: {paramStr(i+1)}"
            
            of "-q", "--quiet":
                do_output = false

            of "-o", "--output":
                discard_next = true
                if paramCount() < i+1: error "Missing argument OUPUT_PATH"
                output_path = os.paramStr(i+1)
            
                        
            else:
                img_path = arg

proc main() =
    let 
        original_image = readImage(img_path)
    
    if width == 0: width = original_image.width div 4
    let downscaled_img = original_image.resize(width, ((original_image.height / original_image.width) * width.float * 0.5).int)
    var progress = 0

    let
        imgH = downscaled_img.height
        imgW = downscaled_img.width

    hidecursor()

    for y in 0..imgH:
        var 
            line: string
            lineNoColor: string

        for x in 0..imgW:
            let
                pixelR = downscaled_img[x,y].r
                pixelG = downscaled_img[x,y].g
                pixelB = downscaled_img[x,y].b
                # pixelA = downscaled_img[x,y].a

            let gray = (pixelR.float * 0.299 + pixelG.float * 0.587 + pixelB.float * 0.114).int

            line &= tlib.rgb(pixelR, pixelG, pixelB) & tlib.rgb_bg(pixelR, pixelG, pixelB) & chars[gray.int div threshold]
            lineNoColor &= chars[gray.int div threshold]
            when (not defined(windows)):
                drawBar(progress, downscaled_img.data.len(), "Completion", "#", "-")
                progress.inc()
            # echo "Progress: " & $((progress / downscaled_img.data.len())*100)
        
        result_file &= lineNoColor & "\n"
        colored_result &= line & "\n"

    showcursor()
when isMainModule:
    setControlCHook(exit)
    echo banner
    proccessArgs()
    if img_path == "": error "No image provided"
    if not os.fileExists(img_path): error "File not found"
    main()
    if do_output: echo colored_result

    if output_path != "":
        writeFile(output_path, result_file)