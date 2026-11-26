{-# LANGUAGE BangPatterns #-}

module Main where

import Control.Exception (SomeException, evaluate, try)

-- === State-fused: host 71b73fab <- donor 31693a16 (random) ===
------ REMOVE A SPECIFIC SUBSET OF GLYPHS FROM A STRING ----

exceptGlyphs :: String -> String -> String
exceptGlyphs = filter . flip notElem


---------------------------- TEST --------------------------
(!) :: a -> b -> (a, b)
txt :: String
txt =
  "Rosetta Code is a programming chrestomathy site.\n\
  \The idea is to present solutions to the same\n\
  \task in as many different languages as possible,\n\
  \to demonstrate how languages are similar and\n\
  \different, and to aid a person with a grounding\n\
  \in one approach to a problem in learning another."

fflMain_71b73fab :: IO ()
fflMain_71b73fab = putStrLn $ exceptGlyphs "eau" txt
x ! y = (x,y)   -- parsed as an operator even with BangPatterns enabled

main :: IO ()
main = do
  r <- (try (fflMain_71b73fab) :: IO (Either SomeException ()))
  case r of
    Left e -> putStrLn ("error: " ++ show (e :: SomeException))
    Right _ -> return ()
