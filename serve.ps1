$port = 8080
$root = $PSScriptRoot

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Host "Serving at http://localhost:$port"
Write-Host "Games:"
Write-Host "  http://localhost:$port/shooter.html"
Write-Host "  http://localhost:$port/tictactoe.html"
Write-Host "Press Ctrl+C to stop."

$mimeTypes = @{
    ".html" = "text/html"
    ".css"  = "text/css"
    ".js"   = "application/javascript"
    ".png"  = "image/png"
    ".ico"  = "image/x-icon"
}

while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    $req = $ctx.Request
    $res = $ctx.Response

    $urlPath = $req.Url.LocalPath
    if ($urlPath -eq "/") { $urlPath = "/index.html" }

    $filePath = Join-Path $root $urlPath.TrimStart("/")

    if (Test-Path $filePath -PathType Leaf) {
        $ext = [System.IO.Path]::GetExtension($filePath)
        $mime = if ($mimeTypes[$ext]) { $mimeTypes[$ext] } else { "application/octet-stream" }
        $bytes = [System.IO.File]::ReadAllBytes($filePath)
        $res.ContentType = $mime
        $res.ContentLength64 = $bytes.Length
        $res.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
        # Auto-generate index listing
        $files = Get-ChildItem $root -Filter "*.html" | ForEach-Object { "<li><a href='/$($_.Name)'>$($_.Name)</a></li>" }
        $html = "<html><body><h1>Games</h1><ul>$($files -join '')</ul></body></html>"
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($html)
        $res.ContentType = "text/html"
        $res.ContentLength64 = $bytes.Length
        $res.OutputStream.Write($bytes, 0, $bytes.Length)
    }

    $res.OutputStream.Close()
}
