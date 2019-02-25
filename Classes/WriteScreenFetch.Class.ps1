
class WriteScreenFetch {
    hidden $OSType;
    hidden $systeminfo = @();

    PwshScreenFetch() {
        # ToDo: Determine system type (Windows, Linux, Mac) so that system dependent functionality can be called...
        $this.OSType = 'Windows';
    }

    Emit() {
        # ToDo: Should be passing the OS to 
        $os = $this.GetOS
        $asciiart = Get-AsciiArt
       
        $this.FillSystemInfo()

        # ToDo: Center the AsciiArt vertically if the system info is longer
        # ToDo: Center the systeminfo if the AsciiArt is longer
        # Write out all the lines of the AsciiArt with SystemInfo if Present
        for($index = 0; $index -lt $asciiart.Length; $index += 1) {
            $this.WriteColoredString($asciiart[$index], $false)
            if ($index -lt $this.systeminfo.Length) {
                $this.WriteColoredString($this.systeminfo[$index], $true);
            } else {
                Write-Host
            }
        }

        # Handle the case where there are more SystemInfo lines...
        if ($this.systeminfo.Length -gt $asciiart.Length) {
            for($index = $asciiart.Length; $index -lt $this.systeminfo.Length; $index += 1) {
                # ToDo: This should be based on the with of the AsciiArt...
                Write-Host -NoNewline "                                        ";
                $this.WriteColoredString($this.systeminfo[$index], $true);
            }

        }
    }

    [void] FillSystemInfo() {
        $this.systeminfo = @();

        $this.AddUserInformation();
        $this.AddOS();
        $this.AddOSVersion();
        $this.AddUptime();
        $this.AddMotherboard();
        $this.AddShell();
        $this.AddDisplays();
        $this.AddCPUs();
        $this.AddGPUs();
        $this.AddRAM();
        $this.AddStorage();
    }

    # Don't like this but it works for now. Will look for something more robust...
    [void] WriteColoredString([string] $coloredstring, [bool] $newLine = $false) {
        $toEmit, $color, $incolor = '', 'white', $false;
        
        for($index = 0; $index -lt $coloredstring.Length; $index += 1) {
            $char = $coloredstring[$index]
        
            if (($incolor -eq $false)) { 
                if ($char -eq '{') {
                    Write-Host -NoNewline -ForegroundColor $color $toEmit
                    $color, $toEmit, $incolor = '', '', $true;
                } else {
                    $toEmit += $char
                }
            } else {
                if ($char -eq '}') {
                    $incolor = $false;
                } else {
                    $color += $char
                }
            }
        }
        
        Write-Host -NoNewLine -ForegroundColor $color $toEmit
        if ($newLine) { Write-Host }
    }

    [void] AddUserInformation() {
        $hostname = (Get-WmiObject Win32_OperatingSystem).CSName;
        $this.systeminfo += "{yellow}$($env:USERNAME){red}@{green}$($hostname)";
    }

    [void] AddOS() {
        $os = (Get-WmiObject Win32_OperatingSystem).Caption;
        $arch = (Get-WmiObject Win32_OperatingSystem).OSArchitecture;
        $this.systeminfo += "{red}OS: {green}$os {yellow}$arch";
    }

    [void] AddOSVersion() {
        $version = (Get-Item "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion").GetValue('ReleaseID')
        $build = $Global:PSVersionTable.BuildVersion.Build
        $revision = $Global:PSVersionTable.BuildVersion.Revision

        $this.systeminfo += "{red}Version: {green}Version $version {cyan}(OS Build $($build).$($revision))"
    }

    [void] AddUptime() {
        $Uptime = ((Get-WmiObject Win32_OperatingSystem).ConvertToDateTime((Get-WmiObject Win32_OperatingSystem).LocalDateTime) - 
            (Get-WmiObject Win32_OperatingSystem).ConvertToDateTime((Get-WmiObject Win32_OperatingSystem).LastBootUpTime));
        $message = $Uptime.Days.ToString() + " days " + $Uptime.Hours.ToString() + " hours " + $Uptime.Minutes.ToString() + " minutes " + $Uptime.Seconds.ToString() + " seconds ";
        $this.systeminfo += "{red}Uptime: {green}$message";
    }

    [void] AddMotherboard() {
        $Motherboard = Get-CimInstance Win32_BaseBoard | Select-Object Manufacturer, Product;
        $this.systeminfo += "{red}Motherboard: {green}$($Motherboard.Manufacturer) $($Motherboard.Product)";
    }
    
    [void] AddShell() {
        $this.systeminfo += "{red}Shell: {green}PowerShell $($Global:PSVersionTable.PSVersion.ToString())";
    }

    [void] AddDisplays() {
        $monitors = Get-WmiObject -N "root\wmi" -Class WmiMonitorListedSupportedSourceModes

        $displayNumber = 1;
        foreach($monitor in $monitors) 
        {   # ToDo: This is not getting the maximum resolution...
            # ToDo: Need to test on my BeastBot which has 4 monitors when I am not travelling...
            $message = "$($monitor.MonitorSourceModes[0].HorizontalActivePixels) x $($monitor.MonitorSourceModes[0].VerticalActivePixels)";

            $this.systeminfo += "{red}Display #$($displayNumber): {green}$message";
            $displayNumber += 1;
        }
    }

    [void] AddCPUs() {
        $message = (((Get-WmiObject Win32_Processor).Name) -replace '\s+', ' ');
        $this.systeminfo += "{red}CPU: {green}$message";
    }

    [void] AddGPUs() {
        $message = (Get-WmiObject Win32_DisplayConfiguration).DeviceName;
        $this.systeminfo += "{red}GPU: {green}$message";
    }

    [void] AddRAM() {
        $FreeRam = ([math]::Truncate((Get-WmiObject Win32_OperatingSystem).FreePhysicalMemory / 1KB)); 
        $TotalRam = ([math]::Truncate((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory / 1MB));
        $UsedRam = $TotalRam - $FreeRam;
        $UsedRamPercent = ($UsedRam / $TotalRam) * 100;
        $UsedRamPercent = "{0:N0}" -f $UsedRamPercent;
    
        $message = $UsedRam.ToString() + "MB / " + $TotalRam.ToString() + " MB " + "(" + $UsedRamPercent.ToString() + "%" + ")";
        $this.systeminfo += "{red}RAM: {green}$message";
        $this.systeminfo += "     " + $this.CreateBar(($UsedRam / $TotalRam), 40);
    }

    [string] CreateBar([double] $percentFull, [int] $size) {
        $bar = "{blue}[{green}";
        $filledbars = [System.Math]::Ceiling($percentFull * $size);
        $unfillerbars = $size - $filledbars;
        $bar += "X" * $filledbars;
        $bar += "{yellow}";
        $bar += "." * $unfillerbars;
        $bar += "{blue}]";
        return $bar;
    }

    [void] AddStorage() {
        $NumDisks = (Get-WmiObject Win32_LogicalDisk).Count;

        for ($i=0; $i -lt ($NumDisks); $i++) 
        {
            $DiskID = (Get-WmiObject Win32_LogicalDisk)[$i].DeviceId;

            $DiskSize = (Get-WmiObject Win32_LogicalDisk)[$i].Size;

            if ($DiskSize -and $DiskSize -ne 0)
            {
                $FreeDiskSize = (Get-WmiObject Win32_LogicalDisk)[$i].FreeSpace
                $FreeDiskSizeGB = $FreeDiskSize / 1073741824;
                $FreeDiskSizeGB = "{0:N0}" -f $FreeDiskSizeGB;

                $DiskSizeGB = $DiskSize / 1073741824;
                $DiskSizeGB = "{0:N0}" -f $DiskSizeGB;

                $FreeDiskPercent = ($FreeDiskSizeGB / $DiskSizeGB) * 100;
                $FreeDiskPercent = "{0:N0}" -f $FreeDiskPercent;

                $UsedDiskSizeGB = $DiskSizeGB - $FreeDiskSizeGB;
                $UsedDiskPercent = ($UsedDiskSizeGB / $DiskSizeGB) * 100;
                $UsedDiskPercent = "{0:N0}" -f $UsedDiskPercent;
            }
            else {
                $DiskSizeGB = 0;
                $FreeDiskSizeGB = 0;
                $FreeDiskPercent = 0;
                $UsedDiskSizeGB = 0;
                $UsedDiskPercent = 100;
            }

            $FormattedDisk = "{red}Disk " + $DiskID.ToString() + " {green}" + 
                $UsedDiskSizeGB.ToString() + "GB" + " / " + $DiskSizeGB.ToString() + "GB " + 
                "(" + $UsedDiskPercent.ToString() + "%" + ")";
                $this.systeminfo += $FormattedDisk;
                $this.systeminfo += "        " + $this.CreateBar(($UsedDiskSizeGB / $DiskSizeGB), 40);
        }
    }
}