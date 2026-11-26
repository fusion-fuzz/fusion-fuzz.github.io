module Main where

import Control.Exception (SomeException, evaluate, try)
import Data.IORef
import Data.List (sortOn)
import Foreign.Marshal.Alloc (mallocBytes, free)
import Foreign.Ptr (nullPtr)
import System.Exit (exitFailure, exitSuccess)
import System.IO (hPutStderr, stderr)
import System.IO.Unsafe (unsafePerformIO)

{-# NOINLINE fflBridge_7274eb9d_e7010baa #-}
fflBridge_7274eb9d_e7010baa :: IORef Integer
fflBridge_7274eb9d_e7010baa = unsafePerformIO (newIORef 0)


-- === Seed A: 7274eb9d ===
-- === State-fused: host 6fbaf8d8 <- donor e7010baa (random) ===
fflMain_6fbaf8d8 :: IO ()
fflMain_6fbaf8d8 = do
  let vars = [("a", [])]
      parsed = [("a", [(1, "1")])]
      merged = [("a", sortOn fst (concatMap snd vars ++ concatMap snd parsed))]
      then hPutStrLn stderr "Allocation failed (out of memory)" >> exitFailure
      else free ptr >> exitSuccess
  print (lookup "a" merged)

fflMain_7274eb9d :: IO ()
fflMain_7274eb9d = do
  r <- (try (fflMain_6fbaf8d8) :: IO (Either SomeException ()))
  case r of
    Left e -> putStrLn ("error: " ++ show (e :: SomeException))
    Right _ -> return ()

-- === Seed B: e7010baa ===
fflMain_e7010baa :: IO ()
fflMain_e7010baa = do
  let size = (fromInteger (unsafePerformIO (readIORef fflBridge_7274eb9d_e7010baa))) :: Int
  ptr <- mallocBytes size
  if ptr == nullPtr
    then hPutStrLn stderr "Allocation failed (out of memory)" >> exitFailure
    else free ptr >> exitSuccess

main :: IO ()
main = do
  writeIORef fflBridge_7274eb9d_e7010baa (1)
  r1 <- (try (fflMain_7274eb9d) :: IO (Either SomeException ()))
  case r1 of
    Left e -> putStrLn ("A: " ++ show (e :: SomeException))
    Right _ -> return ()
  r2 <- (try (fflMain_e7010baa) :: IO (Either SomeException ()))
  case r2 of
    Left e -> putStrLn ("B: " ++ show (e :: SomeException))
    Right _ -> return ()
  finalVal <- readIORef fflBridge_7274eb9d_e7010baa
  putStrLn ("FFL bridge final: " ++ show finalVal)
