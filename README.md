# PS-ScrapeKalshi
A short PowerShell script to scrape data from Kalshi's v2 REST API endpoint

Written thanks to the official API reference at https://trading-api.readme.io

Example uses:

Obtain API token with email address used for registration to Kalshi
~~~
$token = Get-BearerToken -email "your_kalshi@email.com" -password "your_passw0rd"
~~~

Get an array of market data using a token
~~~
$data = Get-AllMarkets -bearerToken $token
~~~

Get an array of tickers from the output of Get-AllMarkets
~~~
$tickers = Extract-TickersFromMarketsData -marketsData $data
~~~
Retrieve every market's statistics history using a token and array of market tickers, and write out to a CSV file
~~~
Get-AllMarketsHistory -bearerToken $token -path ".\all_markets_history.csv" -tickers $tickers
~~~
Retrieve all trades for a market ticker given an array of tickers (no token necessary), and write out to a CSV file
~~~
$trades = Get-AllTrades -path ".\kalshi_all_trades.csv" -tickers $tickers
~~~
