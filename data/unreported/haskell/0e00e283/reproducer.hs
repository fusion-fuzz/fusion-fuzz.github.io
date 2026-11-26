{-# LANGUAGE OverloadedStrings #-}

module Main where

import           Data.Char (isUpper, isLower, isLetter, toUpper)
import           Data.Text (Text)
import Control.Exception (SomeException, evaluate, try)
import qualified Data.Text as T

-- === Seed A: 3a7ab34d ===
abbreviate :: Text -> Text
abbreviate s = T.filter (/= ' ') $ T.zipWith sanitize (" " <> s) (s <> " ")

sanitize :: Char -> Char -> Char
sanitize a b
  | not (isLetter a) && a /= '\'' && isLetter b = fflMain_db31a5e3 b
  | isLower a && isUpper b = b
  | otherwise = ' '

fflMain_3a7ab34d :: IO ()
fflMain_3a7ab34d = return ()


-- === Seed B: db31a5e3 ===
fflMain_db31a5e3 :: IO ()
fflMain_db31a5e3 = do
  let argc = 2
  let p = if argc == 0 then 0 else if argc == 1 then 1 else 1
  let v = if argc < 3 || argc > 4 then 0 else case argc of
            3 -> 33
            4 -> 44
            _ -> 0
  let _ = p + v
  return ()

main :: IO ()
main = do
  r1 <- (try (fflMain_db31a5e3) :: IO (Either SomeException ()))
  case r1 of
    Left e -> putStrLn ("A: " ++ show (e :: SomeException))
    Right _ -> return ()
  r2 <- (try (fflMain_3a7ab34d) :: IO (Either SomeException ()))
  case r2 of
    Left e -> putStrLn ("B: " ++ show (e :: SomeException))
    Right _ -> return ()
