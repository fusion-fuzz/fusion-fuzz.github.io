{-# OPTIONS_GHC -Wunused-do-bind -fdefer-out-of-scope-variables #-}

module Main where

import Control.Exception (SomeException, evaluate, try)
import Data.IORef
import System.IO.Unsafe (unsafePerformIO)

{-# NOINLINE fflBridge_35508eba_e3ddcb27 #-}
fflBridge_35508eba_e3ddcb27 :: IORef Integer
fflBridge_35508eba_e3ddcb27 = unsafePerformIO (newIORef 0)


-- === Seed A: 35508eba ===
-- !!! Double irrefutable pattern (bug in Hugs98, 29/8/2001)
fflMain_35508eba = print (case (1,2) of ~(~(2,x)) -> x)

-- === Seed B: e3ddcb27 ===
fflMain_e3ddcb27 :: IO ()
fflMain_e3ddcb27 = do
    threadDelay (fromInteger (unsafePerformIO (readIORef fflBridge_35508eba_e3ddcb27)))
    return ()

main :: IO ()
main = do
  writeIORef fflBridge_35508eba_e3ddcb27 (1)
  r1 <- (try (fflMain_35508eba) :: IO (Either SomeException ()))
  case r1 of
    Left e -> putStrLn ("A: " ++ show (e :: SomeException))
    Right _ -> return ()
  r2 <- (try (fflMain_e3ddcb27) :: IO (Either SomeException ()))
  case r2 of
    Left e -> putStrLn ("B: " ++ show (e :: SomeException))
    Right _ -> return ()
  finalVal <- readIORef fflBridge_35508eba_e3ddcb27
  putStrLn ("FFL bridge final: " ++ show finalVal)
