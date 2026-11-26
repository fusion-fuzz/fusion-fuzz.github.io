module Main where

import Control.Exception (SomeException, evaluate, try)
import Data.Int
import Data.Word

-- === State-fused: host e51bdbf6 <- donor 2063e3e6 (random) ===
vfloat :: Float
vfloat = fromIntegral (maxBound :: Int32)
fflMain_2063e3e6 :: IO ()
fflMain_2063e3e6 = do
  let foo i = let a = [1 :: Int, 4, 3]; b = a in if i == 1 then a == b else False
  let _ = foo 0
  let _ = foo 0
  let _ = foo 0

fflMain_e51bdbf6 :: IO ()
fflMain_e51bdbf6 = print vfloat
  print (foo 1)

main :: IO ()
main = do
  r <- (try (fflMain_e51bdbf6) :: IO (Either SomeException ()))
  case r of
    Left e -> putStrLn ("error: " ++ show (e :: SomeException))
    Right _ -> return ()
