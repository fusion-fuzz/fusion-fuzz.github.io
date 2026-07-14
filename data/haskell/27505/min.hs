{-# LANGUAGE DataKinds #-}
{-# LANGUAGE RequiredTypeArguments #-}
{-# LANGUAGE TypeFamilies #-}
{-# OPTIONS_GHC -fhpc -ddump-ticked -ddump-simpl-trace -ddump-tc #-}
import Control.Concurrent (forkIO)
import Control.Concurrent.MVar (newEmptyMVar, putMVar, takeMVar)
import Control.Exception (SomeException, evaluate, try)
import Data.IORef
import Data.Proxy
import GHC.TypeLits
import System.IO.Unsafe (unsafePerformIO)
fflShared_045685cc_058b5935 = unsafePerformIO (newIORef 0)
fflMain_045685cc = return ()
symbolValVis :: forall s -> KnownSymbol s => String
symbolValVis (type s) = symbolVal (Proxy :: Proxy s)
(++.) :: String -> forall (s :: Symbol) -> KnownSymbol s => String
s1 ++. (type s2) = s1 ++ symbolValVis (type s2)
main = do
  doneB <- newEmptyMVar
  _ <- forkIO (do
    _ <- (try (fflMain_045685cc) :: IO (Either SomeException ()))
    putMVar doneB ())
  finalVal <- readIORef fflShared_045685cc_058b5935
  putStrLn ("FFL shared state final: " ++ show finalVal)
