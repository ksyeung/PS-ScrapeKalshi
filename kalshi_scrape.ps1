Set-StrictMode -Version 3

$global:endpoint = "https://trading-api.kalshi.com/trade-api/v2"

# Retrieve API token
function Get-BearerToken {
    param (
        [Parameter(Mandatory=$true)]
        [string] $email,

        [Parameter(Mandatory=$true)]
        [string] $password
    )
    $URL = "$($global:endpoint)/login"
    $headers = @{
    "accept" = "application/json"
    "content-type" = "application/json"
    }
    $body = @{
    "email" = $email
    "password" = $password
    } | ConvertTo-Json

    # Send POST request and get response
    $response = Invoke-RestMethod -Uri $URL `
        -Method POST `
        -Headers $headers `
        -ContentType "application/json" `
        -Body $body

    return "Bearer $($response.token)"
}

# Common function to retrieve (markets, trades, history) data based on the given URL and headers
function Get-AllData {
    param (
        [Parameter(Mandatory=$true)]
        [string] $category,

        [Parameter(Mandatory=$true)]
        [string] $URL,     

        [Parameter(Mandatory=$true)]
        [hashtable] $headers,

        # Sleep to respect rate limit for basic access members
        # https://trading-api.readme.io/reference/tiers-and-rate-limits-1
        [Parameter(Mandatory=$false)]
        [int] $sleepTimeInMilliseconds = 105
    )
    $cursor = $null
    $data = @()

    do {
        # Add cursor to the URL if it exists
        $URLWithCursor = if ($cursor) { "$URL&cursor=$cursor" } else { $URL }

        # Send GET request and get response
        $response = Invoke-RestMethod -Uri $URLWithCursor -Method GET -Headers $headers

        # Update cursor
        $cursor = $response.cursor

        # Append data to array
        switch ($category) {
            "markets" {
            $data += $response.markets
            }
            "trades" {
            $data += $response.trades
            }
            "history" {
            $data += $response.history
            }
            "events" {
            $data += $response.events
            }
        }
        Start-Sleep -Milliseconds $sleepTimeInMilliseconds
    } while ($cursor -ne "" -and $cursor -ne $null)
    return $data
}

function Get-AllMarkets {
    param (
        [Parameter(Mandatory=$true)]
        [string] $bearerToken,

        [Parameter(Mandatory=$true)]
        [string] $path
    )
    $URL = "$global:endpoint/markets?limit=1000&status=settled"
    $headers = @{
        "accept" = "application/json"
        "Authorization" = $bearerToken
    }

    $data = Get-AllData -category "markets" -URL $URL -Headers $headers
    $data | Export-Csv -Path $path -Append -NoTypeInformation -Force
}

function Get-AllTrades {
    param (
        [Parameter(Mandatory=$true)]
        [array] $TickersData,

        [Parameter(Mandatory=$true)]
        [string] $path
    )
    $headers = @{
        "accept" = "application/json"
    }
    $tradesData = @()

    foreach ($ticker in $TickersData) {
        $URL = "$global:endpoint/markets/trades?limit=1000&ticker=$ticker"
        $tradesData += Get-AllData -category "trades" -URL $URL -Headers $headers
        $tradesData | Export-Csv -Path $path -Append -NoTypeInformation -Force
    }
}

function Get-AllMarketsHistory {
    param (
        [Parameter(Mandatory=$true)]
        [string] $bearerToken,

        [Parameter(Mandatory=$true)]
        [array] $tickers,

        [Parameter(Mandatory=$true)]
        [string] $path
    )
    $headers = @{
        "accept" = "application/json"
        "Authorization" = $bearerToken
    }

    foreach ($ticker in $tickers) {
        $URL = "$global:endpoint/markets/$ticker/history?limit=1000"
        $data = Get-AllData -category "history" -URL $URL -Headers $headers

        # Adding the ticker value
        foreach ($row in $data) {
            $row | Add-Member -NotePropertyName "ticker" -NotePropertyValue $ticker
        }
        $data | Export-Csv -Path $path -Append -NoTypeInformation -Force
    }
}

# Isolating and returning columns ticker from GetMarkets array
function Extract-TickersFromMarketsData {
     param (
        [Parameter(Mandatory=$true)]
        [array] $marketsData
        )
    $tickers = @()
    
    foreach ($row in $marketsData) {
        $tickers += $row.ticker
    }
    return $tickers
}
