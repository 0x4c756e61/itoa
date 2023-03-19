import utilities/tlib
import math

const
    discordColors* = {(79.0, 84.0, 92.0): 30,
                    (220.0, 50.0, 47.0): 31,
                    (128.0, 116.0, 27.0): 32,
                    (181.0, 137.0, 0.0): 33,
                    (45.0, 103.0, 195.0): 34,
                    (166.0, 54.0, 130.0): 35,
                    (42.0, 161.0, 152.0): 36,
                    (255.0, 255.0, 255.0): 37}
    red* = tlib.rgb(255, 33, 81)
    # green = tlib.rgb(37, 255, 100)
    # yellow = tlib.rgb(246,255,69)
    blue* = tlib.rgb(105, 74, 255)
    dft* = tlib.def()


# get closest discord ansi color
proc getDiscordColor*(r, g, b: uint8): string =
    var closest: float
    result = "37"
    for color in discord_colors:
        let d = ((r.float - color[0][0])*0.299).pow(2.0) + ((g.float - color[0][
                1])*0.587).pow(2.0) + ((b.float - color[0][2])*0.114).pow(2.0)

        if d > closest:
            result = $color[1]