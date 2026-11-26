module Main where

import Control.Exception (SomeException, evaluate, try)
import Control.Monad
import Data.IORef
import GHC.Conc
import System.Environment
import System.IO.Unsafe (unsafePerformIO)

{-# NOINLINE fflBridge_67514888_60d3be0a #-}
fflBridge_67514888_60d3be0a :: IORef Integer
fflBridge_67514888_60d3be0a = unsafePerformIO (newIORef 0)


-- === Seed A: 67514888 ===
-- Test for a bug that provoked the following assertion failure:
-<> nursery-chunks1: internal error: ASSERTION FAILED: file rts/sm/Sanity.c, line (fromInteger (unsafePerformIO (readIORef fflBridge_67514888_60d3be0a)))
module Main (fflMain_67514888) where




fflMain_67514888 = do
  [n,m] <- fmap read <$> getArgs
  forM_ [1..n] $ \n' ->
    when (sum [1.. m::Integer] > 0) $ setNumCapabilities (fromIntegral n')

-- === Seed B: 60d3be0a ===
-- !! answer: 65532

fflMain_60d3be0a = print foo

foo :: Int
foo = ((1 + 2 + 32767 - 4) * 6) --later? `div` 3

main :: IO ()
main = do
  writeIORef fflBridge_67514888_60d3be0a (toInteger (length (show (foo))))
  r1 <- (try (fflMain_60d3be0a) :: IO (Either SomeException ()))
  case r1 of
    Left e -> putStrLn ("A: " ++ show (e :: SomeException))
    Right _ -> return ()
  r2 <- (try (fflMain_67514888) :: IO (Either SomeException ()))
  case r2 of
    Left e -> putStrLn ("B: " ++ show (e :: SomeException))
    Right _ -> return ()
  finalVal <- readIORef fflBridge_67514888_60d3be0a
  putStrLn ("FFL bridge final: " ++ show finalVal)
