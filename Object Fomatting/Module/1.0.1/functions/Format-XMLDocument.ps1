function Format-XmlDocument {
    <#
        .SYNOPSIS
            Formats an imported XML document

        .DESCRIPTION
            This function will use the XMLReader class and format a XML document in to readable text

        .PARAMETER Path
            Path to the file you want to covert

        .PARAMETER BypassEncodingCheck
            Do not check file encoding 

        .EXAMPLE
            PS C:\> Format-XmlDocument -Path c:\temp\xmlfile.xml

            Format an xml document to text

        .EXAMPLE
            PS C:\> Format-XmlDocument -Path c:\temp\xmlfile.ps1xml

            Format an xml document to text

        .EXAMPLE
            PS C:\> Format-XmlDocument -BypassEncodingCheck -Path c:\temp\xmlfile.ps1xml 

            Format an xml document to text and bypass encoding check

        .NOTES
            None
    #>

    [CmdletBinding(DefaultParameterSetName = "Default")]
    param
    (
        [Parameter(Mandatory = $True)]
        [string] $Path,

        [switch]
        $BypassEncodingCheck
    )

    process {
        if ($BypassEncodingCheck.IsPresent -eq $false) {
            $currentEncoding = Get-FileEncoding -Path $Path
            $fileName = Split-Path -Path $Path -Leaf

            if ($currentEncoding.BodyName -ne 'UTF-8') {
                Write-PSFMessage -Level Host -Message "{0} is not of Encoding Type: 'Unicode (UTF-8)'. Current Encoding Type: {1}" -StringValues $fileName, $currentEncoding.EncodingName
                return
            }

            [xml]$contentType = Get-Content -Path $Path
            if ($contentType.ChildNodes.Encoding -ne 'utf-8') {
                Write-PSFMessage -Level Host -Message "Encoding Declaration Type in {0} is not utf-8. Current encoding type is {1}" -StringValues $fileName, $contentType.ChildNodes.Value[0]
                return
            }
        }

        $settings = New-Object System.Xml.XmlReaderSettings
        $doc = Resolve-Path -Path $Path
        $reader = [System.Xml.XmlReader]::Create($doc, $settings)
        $indent = 0

        function Indent {
            param
            (
                [Object]$s
            )
            ' ' * $indent + $s
        }

        while ($reader.Read()) {
            if ($reader.NodeType -eq [System.Xml.XmlNodeType]::Element) {
                $close = $(if ($reader.IsEmptyElement) { '/>' } else { '>' })

                if ($reader.HasAttributes) {
                    $s = indent "<$($reader.Name) "
                    [void] $reader.MoveToFirstAttribute()

                    do {
                        $s += "$($reader.Name) = `"$($reader.Value)`" "
                    }
                    while ($reader.MoveToNextAttribute())
                    "$s$close"
                }
                else {
                    indent "<$($reader.Name)$close"
                }
                if ($close -ne '/>') { $indent++ }
            }
            elseif ($reader.NodeType -eq [Xml.XmlNodeType]::EndElement) {
                $indent--
                indent "</$($reader.Name)>"
            }
            elseif ($reader.NodeType -eq [Xml.XmlNodeType]::Text) {
                indent $reader.value
            }
        }
        $reader.close()
    }
}