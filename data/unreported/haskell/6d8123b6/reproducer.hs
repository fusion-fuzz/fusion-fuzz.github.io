{-# OPTIONS_GHC -XMagicHash #-}

module Main where

import Control.Exception (SomeException, evaluate, try)
import Foreign
import Foreign.C
import GHC.Base
import GHC.Ptr (Ptr(..))

-- === Seed A: 7c6c1a4e ===
-- === State-fused: host 7aa1f620 <- donor e0fe30b1 (random) ===
utf8DecodeChar# :: Addr# -> Bool -> Bool
{-# NOINLINE utf8DecodeChar# #-}
utf8DecodeChar# a# fred =
  case () of
    _ | isTrue# (word2Int# (word8ToWord# (indexWord8OffAddr# a# 0#)) <=# 0x7F#) -> True

-- Omitting the next line gives an ASSERT error:
-- ghc-6.9: panic! (the 'impossible' happened)
--   (GHC version 6.9 for x86_64-unknown-linux):
-++      ASSERT failed! file nativeGen/MachCodeGen.hs line 1049
-- %MO_S_Le_I8(I8[R2], 127 :: I8)
      | fred -> True

      | otherwise -> False
data Record a = Record { payload :: [a] }
data ArchivedRecord a = ArchivedRecord { archivedPayload :: [a] }
data RecordResolver a = RecordResolver { resolverPayload :: [a] }

resolve :: RecordResolver a -> ArchivedRecord a -> ArchivedRecord a
resolve _ out = out

fflMain_e0fe30b1 :: IO ()
fflMain_e0fe30b1 = do
  let r = Record [1 :: Int, 2, 3]
      a = ArchivedRecord (payload r)
      s = RecordResolver (payload r)
      _ = resolve s a
  return ()

fflMain_7aa1f620 = print (utf8DecodeChar# "\128"# False) -- should be False

fflMain_7c6c1a4e :: IO ()
fflMain_7c6c1a4e = do
  r <- (try (fflMain_7aa1f620) :: IO (Either SomeException ()))
  case r of
    Left e -> putStrLn ("error: " ++ show (e :: SomeException))
    Right _ -> return ()

-- === Seed B: e0fe30b1 ===
resolve_be0fe30b1 :: RecordResolver a -> ArchivedRecord a -> ArchivedRecord a
resolve_be0fe30b1 _ out = out

fflMain_e0fe30b1_2 :: IO ()
fflMain_e0fe30b1_2 = do
  let r = Record [1 :: Int, 2, 3]
      a = ArchivedRecord (payload r)
      s = RecordResolver (payload r)
      _ = resolve s a
  return ()

main :: IO ()
main = do
  r1 <- (try (fflMain_7c6c1a4e) :: IO (Either SomeException ()))
  case r1 of
    Left e -> putStrLn ("A: " ++ show (e :: SomeException))
    Right _ -> return ()
  r2 <- (try (fflMain_e0fe30b1_2) :: IO (Either SomeException ()))
  case r2 of
    Left e -> putStrLn ("B: " ++ show (e :: SomeException))
    Right _ -> return ()
