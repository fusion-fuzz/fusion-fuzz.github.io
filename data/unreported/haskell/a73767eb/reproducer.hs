module Main where

import Control.Exception (SomeException, evaluate, try)
import Data.Proxy

-- === State-fused: host 93104815 <- donor 539ef2f9 (random) ===
data Foo

type T0 = Foo
type T1 = Foo

a0 :: [()]
a0 = [() | typeCompat (Proxy :: Proxy T0) (Proxy :: Proxy (T1))]

typeCompat :: Proxy a -> Proxy b -> Bool
data I0 = I0 { iv0 :: Maybe I0 }
class P0 a
data I1 = I1

im0 :: I1 -> Maybe I0
im0 _ = Nothing

data NSImage = NSImage
newtype NSString = NSString String
data NSAttributedString = NSAttributedString
data NSMutableAttributedString = NSMutableAttributedString

typeCompat _ _ = True

fflMain_93104815 :: IO ()
fflMain_93104815 = print (length a0)
attributedStringWithString :: a -> NSImage -> Maybe NSAttributedString
attributedStringWithString _ _ = Nothing

fflMain_539ef2f9 :: IO ()
fflMain_539ef2f9 = do
  let _ = im0 I1
  let _ = attributedStringWithString () NSImage
  return ()

main :: IO ()
main = do
  r <- (try (fflMain_93104815) :: IO (Either SomeException ()))
  case r of
    Left e -> putStrLn ("error: " ++ show (e :: SomeException))
    Right _ -> return ()
