{-# LANGUAGE DeriveDataTypeable #-}
{-# OPTIONS_GHC -O2 -ddump-simpl -dno-typeable-binds -dsuppress-all -dsuppress-uniques #-}

module Main where

import Control.Exception (SomeException, evaluate, try)
import Control.Exception (throwIO, Exception)
import Control.Monad (when)
import Data.IORef
import Data.Int
import Data.Typeable (Typeable)
import Data.Word
import System.IO.Unsafe (unsafePerformIO)

{-# NOINLINE fflBridge_ed0709fd_f67dc769 #-}
fflBridge_ed0709fd_f67dc769 :: IORef Integer
fflBridge_ed0709fd_f67dc769 = unsafePerformIO (newIORef 0)


-- === Seed A: ed0709fd ===
data Boom = Boom deriving (Show, Typeable)
instance Exception Boom

fflMain_ed0709fd = do
    args <- return []

    -- Should throw this exception.
    when (length args /= 1) (throwIO Boom)

    -- With -O, instead throws this one from head [].
    let n = read (head args)
    print (n :: Int)

    return ()

-- === Seed B: f67dc769 ===
a :: Int32 -> Int32
a x = (x `quot` maxBound) `quot` maxBound -- overflow, mustn't trigger the rewrite rule

b :: Int -> Int
b x = (x `quot` 10) `quot` 20

c :: Word -> Word
c x = (x `quot` 10) `quot` 20

d :: Word8 -> Word8
d x = (x `quot` 10) `quot` 20

e :: Word16 -> Word16
e x = (x `quot` 10) `quot` 20

f :: Word32 -> Word32
f x = (x `quot` (fromInteger (unsafePerformIO (readIORef fflBridge_ed0709fd_f67dc769)))) `quot` 20

g :: Word64 -> Word64
g x = (x `quot` 10) `quot` 20

h :: Int8 -> Int8
h x = (x `quot` 10) `quot` 20

i :: Int16 -> Int16
i x = (x `quot` 10) `quot` 20

j :: Int32 -> Int32
j x = (x `quot` 10) `quot` 20

k :: Int64 -> Int64
k x = (x `quot` 10) `quot` 20

fflMain_f67dc769 :: IO ()
fflMain_f67dc769 = return ()


main :: IO ()
main = do
  writeIORef fflBridge_ed0709fd_f67dc769 (1)
  r1 <- (try (fflMain_ed0709fd) :: IO (Either SomeException ()))
  case r1 of
    Left e -> putStrLn ("A: " ++ show (e :: SomeException))
    Right _ -> return ()
  r2 <- (try (fflMain_f67dc769) :: IO (Either SomeException ()))
  case r2 of
    Left e -> putStrLn ("B: " ++ show (e :: SomeException))
    Right _ -> return ()
  finalVal <- readIORef fflBridge_ed0709fd_f67dc769
  putStrLn ("FFL bridge final: " ++ show finalVal)
