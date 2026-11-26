module Main where

import Control.Exception (SomeException, evaluate, try)

-- === State-fused: host 61a05ed0 <- donor 7f921763 (random) ===
fflMain_61a05ed0 :: IO ()
fflMain_7f921763 :: IO ()
fflMain_61a05ed0 = do
  let a = maxBound :: Int
      b = 1 :: Int
      _ = a + b
      d = 0.1 :: Double
      e = 0.2 :: Double
      _ = d + e
  return ()
fflMain_7f921763 = do
  let pp = sin (0.0 :: Double)
  print pp

main :: IO ()
main = do
  r <- (try (fflMain_61a05ed0) :: IO (Either SomeException ()))
  case r of
    Left e -> putStrLn ("error: " ++ show (e :: SomeException))
    Right _ -> return ()
