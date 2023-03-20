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
    coloredResult = ""
    imgPath = ""
    outputPath = ""
    resultFile = ""
    
    discord = false
    doOutput = true
    doSave = false
    saveColors = false
    
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
                registerHelp(["-cc", "--custom-charset"], "use following string as a character set")
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
            
            of "-cc", "--custom-charset":
                discard_next = true
                if paramCount() < i+1: error "Missing argument CHARSET"      
                chars = os.paramStr(i+1)
                echo chars

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
                doOutput = false

            of "-b", "--background":
                background_function = background_coloring

            of "-d", "--discord":
                discord = true
                foreground_coloring = discord_coloring

            of "-s", "--save-colors":
                saveColors = true

            of "-o", "--output":
                discard_next = true
                doSave = true
                if paramCount() < i+1: error "Missing argument OUPUT_PATH"
                outputPath = os.paramStr(i+1)

            else:
                imgPath = arg

proc asciify() =
    let
        original_image = readImage(imgPath)

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

            line &= pixelFG & pixelBG & chars[(gray.int div threshold) mod len(chars)]
            lineNoColor &= chars[(gray.int div threshold) mod len(chars)]
            sb[0].inc()
            sb.update(50_000_000)

        resultFile &= lineNoColor & "\n"
        coloredResult &= line & "\n"

when isMainModule:
    setControlCHook(exit)
    proccessArgs()

    if imgPath == "": error "No image provided"
    if not os.fileExists(imgPath): error "File not found"

    asciify()

    if doOutput: echo coloredResult

    var outputData = resultFile
    
    if saveColors:
        outputData = coloredResult

    if outputPath == "":
        outputPath = imgPath.split('.')[^2] & ".txt"

    if discord and doSave:
        writeFile(outputPath & ".ansi", outputData)
        echo "\n"
        info &"File saved as '{outputPath}.ansi'"

    elif doSave:
        writeFile(outputPath, outputData)
        echo "\n"
        info &"File saved as '{outputPath}'"
