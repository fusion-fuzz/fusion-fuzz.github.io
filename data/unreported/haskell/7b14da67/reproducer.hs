{-# OPTIONS_GHC -XTypeOperators #-}

module Main where

import Control.Exception (SomeException, evaluate, try)

-- === Seed A: 02be73c9 ===
-- === State-fused: host 709a204b <- donor a39cbfa3 (random) ===
-- Test fixity of type operators
fflMain_a39cbfa3 :: IO ()
fflMain_a39cbfa3 = do
  let x = 0 :: Word8
  print (x :: Word8)
-- #2205

module ShouldCompile where

 infixr 0 :->
 data a :-> b = P a b

 fst3:: (a :-> (b :-> c)) -> a
 fst3 (P a (P b c)) = a


 fst3':: (a :-> b :-> c) -> a
 fst3' (P a (P b c)) = a

fflMain_709a204b :: IO ()
fflMain_709a204b = return ()


fflMain_02be73c9 :: IO ()
fflMain_02be73c9 = do
  r <- (try (fflMain_709a204b) :: IO (Either SomeException ()))
  case r of
    Left e -> putStrLn ("error: " ++ show (e :: SomeException))
    Right _ -> return ()

-- === Seed B: a39cbfa3 ===
Word8 :: IO ()
fflMain_a39cbfa3 = do
  let x = 0 :: Word8
  print (x :: Word8)

main :: IO ()
main = do
  r1 <- (try (fflMain_02be73c9) :: IO (Either SomeException ()))
  case r1 of
    Left e -> putStrLn ("A: " ++ show (e :: SomeException))
    Right _ -> return ()
  r2 <- (try (fflMain_a39cbfa3) :: IO (Either SomeException ()))
  case r2 of
    Left e -> putStrLn ("B: " ++ show (e :: SomeException))
    Right _ -> return ()
