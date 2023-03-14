import pixie, tlib, strformat, strutils, os, suru

const
    red = tlib.rgb(255, 33, 81)
    # green = tlib.rgb(37, 255, 100)
    # yellow = tlib.rgb(246,255,69)
    blue = tlib.rgb(105, 74, 255)
    dft = def()
    chars_long = "$@B%8&WM#*oahkbdpqwmZO0QLCJUYXzcvunxrjft/\\|()1{}[]?-_+~i!lI;:,\"^`. "
    chars_long_reversed = " .`^\",:;Il!i~+_-?][}{1)(|\\/tfjrxunvczXYUJCLQ0OZmwqpdbkhao*#MW&8%B@$"
    chars_short = "@%$#+=;:,. "
    chars_short_reversed = " .,:;+#$%@"
    discord_colors = {(79.0, 84.0, 92.0): 30,
                      (220.0, 50.0, 47.0): 31,
                      (128.0, 116.0, 27.0): 32,
                      (181.0, 137.0, 0.0): 33,
                      (45.0, 103.0, 195.0): 34,
                      (166.0, 54.0, 130.0): 35,
                      (42.0, 161.0, 152.0): 36,
                      (255.0, 255.0, 255.0): 37}

proc dummy_bg(r, g, b: uint8): string = ""
proc dummy_discord(r, g, b: uint8): string = tlib.rgb(r, g, b)

var
    img_path = ""
    output_path = ""
    threshold = 25
    do_output = true
    do_save = false
    width = 0
    chars = chars_short
    result_file = ""
    discord = false
    discord_function: proc (r, g, b: uint8): string = dummy_discord
    save_colors = false
    colored_result = ""
    background_function: proc (r, g, b: uint8): string = dummy_bg
    help_menu = &"""
{red}imgTOAscii{dft} version {blue}0.0.1{dft}
{red}imgTOAscii{dft} is a tool to convert images to {blue}ASCII{dft}.

{red}USAGE{dft}:
    itoa [OPTIONS] FILE_PATH

{red}OPTIONS{dft}:"""

proc error(str: string) =
    echo &"[{red}ERROR{dft}]   {str}"
    quit(1)

proc info(str: string) =
    echo &"[{blue}INFO{dft}]    {str}"
    quit(1)

proc exit() {.noconv.} =
    echo "\nThanks for using ITOA."

proc register_help(calls: array[0..1, string], desc: string) =
    let options = calls.join(", ")
    let thing = &"\n    {blue}{options}{dft}"
    let space = " " * (50-len(thing))
    help_menu &= thing & space & desc

proc getDiscordColor(r, g, b: uint8): string =
    var closest: float
    result = "37"
    for color in discord_colors:
        let d = ((r.float - color[0][0])*0.299)**2.0 + ((g.float - color[0][
                1])*0.587)**2.0 + ((b.float - color[0][2])*0.114)**2.0
        #let d = (r.float - color[0][0])**2.0 + (g.float - color[0][1])**2.0 + (b.float - color[0][2])**2.0
        if d > closest:
            result = $color[1]


proc background_coloring(r, g, b: uint8): string = tlib.rgb_bg(r, g, b)
proc discord_coloring(r, g, b: uint8): string =
    let c = getDiscordColor(r, g, b)
    if c != "0":
        return "[0;" & c & "m"
    else:
        return ""

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
                register_help(["-d", "--discord"], "Changes the color set to discord's ansi escape sequences")
                register_help(["-c", "--characters"], "Charset                               Default: Chars Available: short/s, long/l, reversed_short/rs, reversed_long/rl")
                register_help(["-b", "--background"], "Colors the background")
                register_help(["-o", "--output"], "Output file")
                register_help(["-s", "--save-colors"], "Writes the colored output to the file")
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

            of "-b", "--background":
                background_function = background_coloring

            of "-d", "--discord":
                discord_function = discord_coloring

            of "-s", "--save-colors":
                save_colors = true

            of "-o", "--output":
                discard_next = true
                do_save = true
                if paramCount() < i+1: error "Missing argument OUPUT_PATH"
                output_path = os.paramStr(i+1)

            else:
                img_path = arg

proc main() =
    let
        original_image = readImage(img_path)

    if width == 0: width = original_image.width div 4
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
            pixelFG = discord_function(pixelR, pixelG, pixelB)

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
    main()
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

