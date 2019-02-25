


# User @ Host

# OS

# Kernel

# Uptime

# Packages (Linux)

# Motherboard (Windows)

# Shell

# Resolution (Windows)

# Window Manager (Windows)

# Font (Windows)

# CPU

# GPU (Windows)

# RAM

# Disk Storage (Windows)


function Write-ScreenFetch {
 #   param($OSOverride)

    $class = [WriteScreenFetch]::New();
    $class.Emit();
}