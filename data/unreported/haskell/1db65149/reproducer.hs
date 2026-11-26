{-# LANGUAGE TypeApplications #-}

module Main where

import Control.Exception (SomeException, evaluate, try)
import qualified Control.Category as Cat

-- === State-fused: host b98b9757 <- donor 27a53e77 (random) ===
foo = (Cat.id @(->) >>=)
fflMain_27a53e77 :: IO ()
fflMain_27a53e77 = do
  let xs = ([] :: [Int])
      ys = ([] :: [Int])
      zs = ([] :: [()])
  print (xs == ys)
  print (null xs && null zs)

fflMain_b98b9757 :: IO ()
fflMain_b98b9757 = do
  r <- try (evaluate (length (show (foo)))) :: IO (Either SomeException Int)
  case r of
    Left e -> putStrLn ("probe error: " ++ show (e :: SomeException))
    Right n -> putStrLn ("probe len: " ++ show n)


main :: IO ()
main = do
  r <- (try (fflMain_b98b9757) :: IO (Either SomeException ()))
  case r of
    Left e -> putStrLn ("error: " ++ show (e :: SomeException))
    Right _ -> return ()
