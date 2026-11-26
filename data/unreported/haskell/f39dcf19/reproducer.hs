{-# LANGUAGE Arrows #-}
{-# LANGUAGE ExistentialQuantification #-}
{-# LANGUAGE GADTs #-}

module Main where

import Control.Arrow
import Control.Exception (SomeException, evaluate, try)

-- === State-fused: host 642f6858 <- donor cb4e9954 (random) ===
data Foo = Foo Int Int a Bar deriving Show
data Bar = Bar String deriving Show
fflMain_642f6858 = do
  let _ = Foo 1 2 3
  let _ = Foo 1 2 3 (Bar "A" "B")
  let _ = Foo 1 2 (Bar "A" "B")
  Results:

  ghc: panic! (the 'impossible' happened)
  (GHC version 9.0.0.20200925:
  GHC.StgToCmm.Env: variable not found
  $dRealFloat_a1tn
  local binds for:
  pos
  Point
  Obj
  $dArrow_s1xr
  ds_s1xs
  ds1_s1xt
  ds2_s1ya
  ds3_s1yb
  ds4_s1yc
  ds6_s1ye
  sat_s1yf
  sat_s1yg
  sat_s1yh
  sat_s1yi
  sat_s1yj
  sat_s1yk
  sat_s1yl
  sat_s1ym
  sat_s1yn
  Call stack:
  CallStack (from HasCallStack):
  callStackDoc, called at compiler/GHC/Utils/Outputable.hs:1230:37 in ghc:GHC.Utils.Outputable
  pprPanic, called at compiler/GHC/StgToCmm/Env.hs:152:9 in ghc:GHC.StgToCmm.Env

  Please report this as a GHC bug:  https://www.haskell.org/ghc/reportabug
  --}
  {--
  ```bash
  ghc -dcore-lint Example.hs
  ```
  --}
  module Example (
  -- NOTE: no error if `step` not exported
  step,
  ) where


  -- NOTE: existentially qualified declaration of Point,
  --       mirrors definition of 'Point2' in package 'simple-affine-space'
  -- import Data.Point2

  -- NOTE: no error without 'RealFloat a` context; both examples fail
  --data Point a = RealFloat a => Point !a
  data Point a where Point :: RealFloat a => a -> Point a

  type Position = Point Float

  ptrPos :: Arrow a => a Obj Position
  ptrPos = arr pos

  data Obj = Obj { pos :: !Position }

  step :: Arrow a => a Obj Obj
  step = proc gi -> do
  -- NOTE: no error without this arrow line; no error if not deconstructed.
  (Point _) <- ptrPos -< gi
  {--
  -- NOTE: this code does work (in place of `(Point _) <- ptrPos -< gi` above)
  pt <- ptrPos -< gi
  let (Point _) = pt
  --}
  returnA -< Obj {
  -- NOTE: no error without this 'pos' field
  pos = (Point 0)
  }

main :: IO ()
main = do
  r <- (try (fflMain_642f6858) :: IO (Either SomeException ()))
  case r of
    Left e -> putStrLn ("error: " ++ show (e :: SomeException))
    Right _ -> return ()
