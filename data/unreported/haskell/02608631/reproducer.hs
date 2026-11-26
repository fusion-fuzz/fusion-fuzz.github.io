module Main where

import Control.Exception (SomeException, evaluate, try)
import Data.Complex

-- === State-fused: host ea4108d6 <- donor a42491ca (random) ===
fflMain_ea4108d6 :: IO ()
data S = S Double deriving Show
data T = T (Complex Float) deriving Show
fflMain_ea4108d6 = do
  let p = Nothing :: Maybe Int
  case p of
    Just _ -> return ()
    Nothing -> return ()

fflMain_a42491ca :: IO ()
fflMain_a42491ca = do
  let s = S 1.0
      t = T (1 :+ 2)
  print s
  print t

main :: IO ()
main = do
  r <- (try (fflMain_ea4108d6) :: IO (Either SomeException ()))
  case r of
    Left e -> putStrLn ("error: " ++ show (e :: SomeException))
    Right _ -> return ()
