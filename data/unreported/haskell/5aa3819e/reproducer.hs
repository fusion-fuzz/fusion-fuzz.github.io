{-# LANGUAGE DuplicateRecordFields, PatternSynonyms #-}
{-# OPTIONS_GHC -W #-}

module Main where

import Control.Exception (SomeException, evaluate, try)

-- === Seed A: 53662e69 ===
-- === State-fused: host fa24c4a0 <- donor 8846c75e (random) ===
pattern P :: Int -> Int -> (Int, Int)
pattern P { proj_x, proj_y } = (proj_x, proj_y)

pattern Q1 :: Int -> Int
pattern Q1 { proj_x } = proj_x

pattern Q2 :: Int -> Int
pattern Q2 { proj_y } = proj_y

blah :: (Int, Int) -> (Int, Int)
blah p = foo_b8846c75e { proj_x = 0, proj_y = 1 }
foo :: [()] -> ()
foo ~(a:_) = a
foo _      = ()

fflMain_fa24c4a0 :: IO ()
fflMain_fa24c4a0 = return ()


fflMain_53662e69 :: IO ()
fflMain_53662e69 = do
  r <- (try (fflMain_fa24c4a0) :: IO (Either SomeException ()))
  case r of
    Left e -> putStrLn ("error: " ++ show (e :: SomeException))
    Right _ -> return ()

-- === Seed B: 8846c75e ===
foo_b8846c75e :: [()] -> ()
foo_b8846c75e ~(a:_) = a
foo_b8846c75e _      = ()

fflMain_8846c75e :: IO ()
fflMain_8846c75e = return ()


main :: IO ()
main = do
  r1 <- (try (fflMain_8846c75e) :: IO (Either SomeException ()))
  case r1 of
    Left e -> putStrLn ("A: " ++ show (e :: SomeException))
    Right _ -> return ()
  r2 <- (try (fflMain_53662e69) :: IO (Either SomeException ()))
  case r2 of
    Left e -> putStrLn ("B: " ++ show (e :: SomeException))
    Right _ -> return ()
