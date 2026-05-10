{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

module Main where

import Control.Monad (when, unless)
import qualified Data.ByteString.Lazy as BL (readFile, writeFile)
import Data.Csv (decodeByName)
import Data.Foldable (toList)
import Data.Text (unpack)

import QuoteData
import Charts
import StatReport
import HtmlReport
import Param


main :: IO ()
main = cmdLineParser >>= work

work :: Params -> IO ()
work params = do
    csvData <- BL.readFile (fname params)
    case decodeByName csvData of
        Left err -> putStrLn err
        Right (_, quotes) -> generateReports params quotes 

generateReports :: (Functor t, Foldable t) => Params -> t QuoteData -> IO ()
generateReports Params {..} quotes = do
    putStrLn $ show (Params {..})
    unless silent $ putStrLn textRpt
    when chart $ plotchart title quotes chartFname
    saveHtml htmlFile htmlRpt
    where
        statInfo' = statInfo quotes
        textRpt   = textReport statInfo'
        htmlRpt   = htmlReport title quotes statInfo' [chartFname | chart]

        withCompany prefix = maybe mempty (prefix <>) company
        chartFname         = unpack $ "chart" <> withCompany "_" <> ".svg"  
        title              = unpack $ "Historical Quotes" <> withCompany " for "

        saveHtml Nothing _    = pure ()
        saveHtml (Just f) html = BL.writeFile f html 