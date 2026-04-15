{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveAnyClass #-}

module QuoteData where

import Data.Time (Day, parseTimeM, defaultTimeLocale)
import Data.ByteString.Char8 (unpack)
import GHC.Generics (Generic)
import Data.Csv (FromNamedRecord, FromField (..))

data QuoteData = QuoteData {
    day    :: Day, 
    volume :: Int,
    open   :: Double,
    close  :: Double,
    high   :: Double,
    low    ::  Double
} deriving (Generic, FromNamedRecord)

data QField = Open | Close | High | Low | Volume
    deriving (Eq, Ord, Show, Enum, Bounded)

instance FromField Day where
    parseField = parseTimeM True defaultTimeLocale "%y%m-%d" . unpack

field2fun :: QField -> QuoteData -> Double
field2fun Open   = open
field2fun Close  = close
field2fun High   = high
field2fun Low    = low
field2fun Volume = fromIntegral . volume
