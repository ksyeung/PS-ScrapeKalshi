# PS-ScrapeKalshi
A short PowerShell script to scrape data from Kalshi's v2 REST API endpoint

Written thanks to the official API reference at https://trading-api.readme.io

Example uses:

Obtain API token
~~~
$token = Get-BearerToken -email "your_kalshi@email.com" -password "your_passw0rd"
~~~

Retrieve every market
~~~
$data = Get-AllMarkets -bearerToken $token
~~~

Build an array of tickers from the output of Get-AllMarkets
~~~
$tickers = Extract-TickersFromMarketsData -marketsData $data
~~~
Retrieve every market's statistics history using an array of market tickers
~~~
Get-AllMarketsHistory -bearerToken $token -path ".\all_markets_history.csv" -tickers $tickers
~~~
Retrieve all trades for a market ticker given an array of tickers
~~~
$trades = Get-AllTrades -path ".\kalshi_all_trades.csv" -TickersData $tickers
~~~
