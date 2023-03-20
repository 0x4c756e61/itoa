import pixie, strformat, strutils, os, suru
import utilities/[tlib, macros]

importDir("./utils")

# Dummy function used as default functions for the foreground and background coloring
proc dummy_bg(r, g, b: uint8): string = ""
proc dummy_fg(r, g, b: uint8): string = tlib.rgb(r, g, b)

# CLI options with their default values
var
    colorThreshold = 20.0
    threshold = 25
    width = 0
    
    chars = chars_short
    colored_result = ""
    img_path = ""
    output_path = ""
    result_file = ""
    
    discord = false
    do_output = true
    do_save = false
    save_colors = false
    
    # procedure aliases
    background_function: proc (r, g, b: uint8): string = dummy_bg
    foreground_coloring: proc (r, g, b: uint8): string = dummy_fg

# Colors background
proc background_coloring(r, g, b: uint8): string = tlib.rgbBg(r, g, b)
# Colors the foreground using discord colors
proc discord_coloring(r, g, b: uint8): string =
    let c = getDiscordColor(r, g, b, colorThreshold)
    if c != "0":
        result =  "[0;" & c & "m"
    else:
        result =  ""


proc proccessArgs() =
    var discard_next = false
    for i in 1..os.paramCount():
        if discard_next: discard_next = false; continue
        let arg = os.paramStr(i)
        case arg
            of "-h", "--help":
                registerHelp(["-h", "--help"], "Show this page and quits")
                registerHelp(["-t", "--color-threshold"], "Accuracy of the discord color conversion         Default: 25")
                registerHelp(["-a", "--threshold"], "The accuracy of the conversion                   Default: 25")
                registerHelp(["-w", "--width"], "Set the new width of image                       Default: image_size/2")
                registerHelp(["-d", "--discord"], "Changes the color set to discord's ansi escape sequences")
                registerHelp(["-c", "--characters"], "Charset                                          Default: Chars Available: short/s, long/l, reversed_short/rs, reversed_long/rl")
                registerHelp(["-b", "--background"], "Colors the background")
                registerHelp(["-o", "--output"], "Output file")
                registerHelp(["-s", "--save-colors"], "Writes the colored output to the file")
                registerHelp(["-q", "--quiet"], "Do not print to the console")
                echo help_menu
                quit(0)

            of "-t", "--threshold":
                discard_next = true
                if paramCount() < i+1: error "Missing argument THRESHOLD"
                threshold = parseInt(os.paramStr(i+1))
            
            of "-a", "--color-threshold":
                discard_next = true
                if paramCount() < i+1: error "Missing argument THRESHOLD"
                colorThreshold = parseFloat(os.paramStr(i+1))

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

            of "-b", "--background":
                background_function = background_coloring

            of "-d", "--discord":
                discord = true
                foreground_coloring = discord_coloring

            of "-s", "--save-colors":
                save_colors = true

            of "-o", "--output":
                discard_next = true
                do_save = true
                if paramCount() < i+1: error "Missing argument OUPUT_PATH"
                output_path = os.paramStr(i+1)

            else:
                img_path = arg

proc asciify() =
    let
        original_image = readImage(img_path)

    if width == 0:
        width = original_image.width div 4
        
    let downscaled_img = original_image.resize(width, ((original_image.height /
            original_image.width) * width.float * 0.5).int)

    var sb: SuruBar = initSuruBar()

    let
        imgH = downscaled_img.height
        imgW = downscaled_img.width

    let totalProgress = imgH*imgW
    sb[0].total = totalProgress
    sb.setup()

    for y in 0..imgH:
        var
            line: string
            lineNoColor: string

        for x in 0..imgW:
            let
                pixelR = downscaled_img[x, y].r
                pixelG = downscaled_img[x, y].g
                pixelB = downscaled_img[x, y].b
                # pixelA = downscaled_img[x,y].a

            let
                gray = (pixelR.float * 0.299 + pixelG.float * 0.587 +
                        pixelB.float * 0.114).int

            var
                pixelBG: string
                pixelFG: string

            pixelBG = background_function(pixelR, pixelG, pixelB)
            pixelFG = foreground_coloring(pixelR, pixelG, pixelB)

            line &= pixelFG & pixelBG & chars[gray.int div threshold]
            lineNoColor &= chars[gray.int div threshold]
            sb[0].inc()
            sb.update(50_000_000)

        result_file &= lineNoColor & "\n"
        colored_result &= line & "\n"

when isMainModule:
    setControlCHook(exit)
    proccessArgs()

    if img_path == "": error "No image provided"
    if not os.fileExists(img_path): error "File not found"

    asciify()

    if do_output: echo colored_result

    var outputData = result_file
    
    if save_colors:
        outputData = colored_result

    if output_path == "":
        output_path = img_path.split('.')[^2] & ".txt"

    if discord and do_save:
        writeFile(output_path & ".ansi", outputData)
        echo "\n"
        info &"File saved as '{output_path}.ansi'"

    elif do_save:
        writeFile(output_path, outputData)
        echo "\n"
        info &"File saved as '{output_path}'"
