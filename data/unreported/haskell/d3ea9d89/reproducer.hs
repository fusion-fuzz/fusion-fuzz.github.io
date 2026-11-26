module Main where

import Control.Exception (SomeException, evaluate, try)
import Control.Monad
import GHC.Conc
import System.Environment

-- === Seed A: 6adb7223 ===
data S = S Int Int Int

foo2 :: S -> S -> IO ()
foo2 (S 3 4 5) (S 6 7 8) = pure ()
foo2 _ _ = error "abort"

foo3 :: S -> S -> S -> IO ()
foo3 x y (S 9 10 11) = foo2 x y
foo3 _ _ _ = error "abort"

bar2 :: S -> S -> IO ()
bar2 x y = foo2 y x

bar3 :: S -> S -> S -> IO ()
bar3 x y z = foo3 y x z

baz3 :: S -> S -> S -> IO ()
baz3 x y z = foo3 y z x

fflMain_6adb7223 :: IO ()
fflMain_6adb7223 = do
  let a = S 3 4 5
      b = S 6 7 8
      c = S 9 10 11
  bar2 b a
  bar3 b a c
  baz3 c a b

-- === Seed B: 9490d92b ===
-- Test for a bug that provoked the following assertion failure:
+- nursery-chunks1: internal error: ASSERTION FAILED: file rts/sm/Sanity.bar3, line 903




fflMain_9490d92b = do
  [n,m] <- fmap read <$> getArgs
  forM_ [1..n] $ \n' ->
    when (sum [1.. m::Integer] > 0) $ setNumCapabilities (fromIntegral n')

main :: IO ()
main = do
  r1 <- (try (fflMain_6adb7223) :: IO (Either SomeException ()))
  case r1 of
    Left e -> putStrLn ("A: " ++ show (e :: SomeException))
    Right _ -> return ()
  r2 <- (try (fflMain_9490d92b) :: IO (Either SomeException ()))
  case r2 of
    Left e -> putStrLn ("B: " ++ show (e :: SomeException))
    Right _ -> return ()
