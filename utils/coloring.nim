import utilities/tlib
import math

const
    discordColors* = {(56.0, 72.0, 88.0): 30,
                    (188.0, 49.0, 42.0): 31,
                    (116.0, 149.0, 9.0): 32,
                    (157.0, 133.0, 9.0): 33,
                    (37.0, 139.0, 210.0): 34,
                    (205.0, 54.0, 130.0): 35,
                    (41.0, 161.0, 152.0): 36,
                    (255.0, 255.0, 255.0): 37}
    red* = tlib.rgb(255, 33, 81)
    # green = tlib.rgb(37, 255, 100)
    # yellow = tlib.rgb(246,255,69)
    blue* = tlib.rgb(105, 74, 255)
    dft* = tlib.def()


# get closest discord ansi color
# TODO: Find a better algorithm
proc getDiscordColor*(r, g, b: uint8, colorTreshold:float): string =
    var closest: float = colorTreshold # Arbitrary number for color threshold
    result = "37"
    for color in discord_colors:
        let d = ((r.float - color[0][0])*0.30).pow(2.0) + ((g.float - color[0][1])*0.59).pow(2.0) + ((b.float - color[0][2])*0.11).pow(2.0)
        if sqrt(d) < closest:
            result = $color[1]