module QuoteIO where

import Charts 
import QuoteData
import StatReport
import HtmlReport
import qualified Data.ByteString.Lazy as BL
import Data.Csv (decodeByName)
import Data.Foldable (toList)
import Charts (plotchart)
import Text.Blaze.Html5 as H
import Text.Blaze.Html5.Attributes (src)
import Text.Blaze.Html.Renderer.Utf8 (renderHtml)
import Text.Blaze.Colonnade

readQuotes :: FilePath -> IO [QuoteData]
readQuotes path = do
    csvData <- BL.readFile path
    case decodeByName csvData of
        Left err        -> fail err
        Right (_, rows) -> pure (toList rows)

makeChart :: FilePath -> IO ()
makeChart path = do 
    quotes <- readQuotes path
    plotchart  "Sample quotes" quotes "chart.svg" 

printHtml = readQuotes "stockquotes/data/quotes.csv" >>= printCompactHtml . (encodeHtmlTable mempty colStats) . statInfo 

printStat = readQuotes "stockquotes/data/quotes.csv" >>= putStr . textReport . statInfo