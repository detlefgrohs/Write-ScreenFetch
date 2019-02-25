



function Get-AsciiArt {
    param($OSString, $Small = $false)


    [string[]] $ArtArray  =
            '                            ____XXXX    ',
            '                    ____XXXXXXXXXXXX    ',
            '           ____XXXX XXXXXXXXXXXXXXXX    ',
            '   ____XXXXXXXXXXXX XXXXXXXXXXXXXXXX    ',
            '   XXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXX    ',
            '   XXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXX    ',
            '   XXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXX    ',
            '   XXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXX    ',
            '   ________________ ________________    ',
            '   XXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXX    ',
            '   XXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXX    ',
            '   XXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXX    ',
            '       XXXXXXXXXXXX XXXXXXXXXXXXXXXX    ',
            '               XXXX XXXXXXXXXXXXXXXX    ',
            '                        XXXXXXXXXXXX    ',
            '                                XXXX    ';
    
    return $ArtArray;
}

