{-# OPTIONS_GHC -O2 -ddump-simpl -dno-typeable-binds -dsuppress-all -dsuppress-uniques #-}
import Control.Exception (SomeException, evaluate, try)
import Control.Exception (throwIO, Exception)
import Data.Typeable (Typeable)
data Boom = Boom deriving (Show, Typeable)
instance Exception Boom
fflMain_f67dc769 = return ()
main = do
  r2 <- (try (fflMain_f67dc769) :: IO (Either SomeException ()))
  case r2 of
