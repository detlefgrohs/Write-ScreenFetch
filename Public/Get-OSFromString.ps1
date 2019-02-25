


function Get-OSFromString {
    param($OSString)

    $OSMapping = @{
        'Windows' = '.*Windows 10.*', '.*Windows 8.*'
        'RaspberryPi' = 'Raspbian.*'
    }

    $mappedOS = 'Unknown'
    $OSMapping.Keys | ForEach-Object {
        $os = $_
        $patterns = $OSMapping[$os];

        $patterns | ForEach-Object {
            if ($OSString -match $_) {
                $mappedOS = $os;
            }
        }
    }

    return $mappedOS
}
