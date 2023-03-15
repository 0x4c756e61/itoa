task build, "Builds a debug binary":
    if defined(linux):
        switch("d", "pixieUseStb")
    
    if defined(windows):
        switch("d", "mingw")

    switch("d", "debug")
    setcommand("c")

task release, "Builds a release binary":
    if defined(linux):
        switch("d", "pixieUseStb")
    
    if defined(windows):
        switch("d", "mingw")
    
    switch("d", "release")
    switch("d", "danger")
    switch("d", "strip")
    switch("mm", "arc")
    switch("opt", "size")
    setcommand("c")