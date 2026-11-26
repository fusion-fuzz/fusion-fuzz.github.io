{-# LANGUAGE TemplateHaskell #-}
module H1 where
import Language.Haskell.TH
data BinaryTree a = Leaf | Branch a
x :: String
x = $(do { BinaryTree <- reify (mkName "Leaf"); return (LitE (StringL "")) })
