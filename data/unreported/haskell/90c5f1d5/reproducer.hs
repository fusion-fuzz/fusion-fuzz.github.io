module Main where

import Control.Exception
import Control.Exception (SomeException, evaluate, try)
import Control.Monad
import GHC.Conc
import System.Directory
import System.Environment
import System.IO

-- === Donor typeclasses: 806378a0 ===
-- Test for a bug that provoked the following assertion failure:
-++ nursery-chunks1: internal error: ASSERTION FAILED: file rts/sm/Sanity.c, line 903
module Main (fflMain_806378a0) where




fflMain_806378a0 = do
  [n,m] <- fmap read <$> getArgs
  forM_ [1..n] $ \n' ->
    when (sum [1.. m::Integer] > 0) $ setNumCapabilities (fromIntegral n')

-- === Declaration-fused host: c41e147f ===
fflMain_c41e147f :: IO ()
fflMain_c41e147f = do
  args <- getArgs
  let f = if null args then "bug49072.zip" else head args
  withFile f ReadMode $ \h -> do
    eof <- hIsEOF h
    unless eof $ do
      s <- hGetContents h
      length s `seq` return ()

main :: IO ()
main = do
  r <- (try (fflMain_c41e147f) :: IO (Either SomeException ()))
  case r of
    Left e -> putStrLn ("error: " ++ show (e :: SomeException))
    Right _ -> return ()
