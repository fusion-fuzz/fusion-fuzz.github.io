{-# LANGUAGE DataKinds #-}
{-# LANGUAGE ExplicitNamespaces #-}
{-# LANGUAGE RequiredTypeArguments #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE UndecidableSuperClasses #-}
{-# OPTIONS_GHC -ddump-to-file #-}
{-# OPTIONS_GHC -ddump-types -ddump-core-stats #-}
{-# OPTIONS_GHC -fhpc -ddump-ticked -ddump-simpl-trace -ddump-tc #-}

module Main where

import Control.Concurrent (forkIO)
import Control.Concurrent.MVar (newEmptyMVar, putMVar, takeMVar)
import Control.Exception (SomeException, evaluate, try)
import Data.IORef
import Data.Kind
import Data.Proxy
import GHC.TypeLits
import System.IO.Unsafe (unsafePerformIO)
import System.Timeout (timeout)

{-# NOINLINE fflShared_045685cc_058b5935 #-}
fflShared_045685cc_058b5935 :: IORef Integer
fflShared_045685cc_058b5935 = unsafePerformIO (newIORef 0)


-- === Seed A: 045685cc ===
foo :: Int -> Int
foo 0 = 0
foo n = foo (n - 1)

fflMain_045685cc :: IO ()
fflMain_045685cc = return ()


-- === Seed B: 058b5935 ===
-- Definition:
symbolValVis :: forall s -> KnownSymbol s => String
symbolValVis (type s) = symbolVal (Proxy :: Proxy s)

-- Usage:
strHelloWorld = symbolValVis (type ("Hello, " `AppendSymbol` "World"))

-- Operator taking a term-level argument before a required type argument:
(++.) :: String -> forall (s :: Symbol) -> KnownSymbol s => String
s1 ++. (type s2) = s1 ++ symbolValVis (type s2)
infixr 5 ++.

strTmPlusTy = "Tm" ++ "+" ++. (type "Ty")

-------------------------------------------------
--   Required type arguments in class methods  --
--         and in higher-rank positions        --
-------------------------------------------------

-- Continuation-passing encoding of a list spine:
--
-- data Spine xs where
--   Cons :: Spine xs -> Spine (x : xs)
--   Nil :: Spine '[]
--
type WithSpine :: [k] -> Constraint
class WithSpine xs where
  onSpine ::
    forall r.
    forall xs' -> (xs' ~ xs) =>  -- workaround b/c it's not possible to make xs visible
    ((xs ~ '[]) => r) ->
    (forall y ys -> (xs ~ (y : ys)) => WithSpine ys => r) ->
    r

instance WithSpine '[] where
  onSpine (type xs) onNil _ = onNil

instance forall x xs. WithSpine xs => WithSpine (x : xs) where
  onSpine (type xs') _ onCons = onCons (type x) (type xs)

type All :: (k -> Constraint) -> [k] -> Constraint
type family All c xs where
  All c '[] = ()
  All c (a : as) = (c a, All c as)

type KnownSymbols :: [Symbol] -> Constraint
class All KnownSymbol ss => KnownSymbols ss
instance All KnownSymbol ss => KnownSymbols ss

symbolVals :: forall ss -> (KnownSymbols ss, WithSpine ss) => [String]
symbolVals (type ss) =
  onSpine (type ss) [] $ \(type s) (type ss') ->
    symbolValVis (type s) : symbolVals (type ss')

-- Reify a type-level list of strings at the term level.
strsLoremIpsum = symbolVals (type ["lorem", "ipsum", "dolor", "sit", "amet"])

-- Pass a required type argument to a continuation:
withSymbolVis :: String -> (forall s -> KnownSymbol s => r) -> r
withSymbolVis str cont =
  case someSymbolVal str of
    SomeSymbol (Proxy :: Proxy s) -> cont (type s)

-- Use a required type argument in a continuation:
strLengthViaSymbol :: String -> Int
strLengthViaSymbol str =
  withSymbolVis str $ \(type s) ->
    length (symbolValVis (type s))

fflMain_058b5935 :: IO ()
fflMain_058b5935 = do
  r <- try (evaluate (length (show (strsLoremIpsum)))) :: IO (Either SomeException Int)
  case r of
    Left e -> putStrLn ("probe error: " ++ show (e :: SomeException))
    Right n -> putStrLn ("probe len: " ++ show n)


main :: IO ()
main = do
  writeIORef fflShared_045685cc_058b5935 (1)
  doneA <- newEmptyMVar
  doneB <- newEmptyMVar
  _ <- forkIO (do
    _ <- (try (fflMain_045685cc) :: IO (Either SomeException ()))
    putMVar doneA ())
  _ <- forkIO (do
    v <- readIORef fflShared_045685cc_058b5935
    writeIORef fflShared_045685cc_058b5935 (v + (5))
    _ <- (try (fflMain_058b5935) :: IO (Either SomeException ()))
    putMVar doneB ())
  _ <- timeout (3 * 1000000) (takeMVar doneA)
  _ <- timeout (3 * 1000000) (takeMVar doneB)
  finalVal <- readIORef fflShared_045685cc_058b5935
  putStrLn ("FFL shared state final: " ++ show finalVal)
