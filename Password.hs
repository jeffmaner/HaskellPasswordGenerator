module Password ( Config (..)
                , generatePasswords) where

import Data.Char (toLower, toUpper)
import Data.List (intersperse, isPrefixOf, nub)
import System.Random (randomRs, split, StdGen)

data Config = Config { wordsInPassword     :: Int
                     , minimumWordLength   :: Int
                     , maximumWordLength   :: Int
                     , passwordsToGenerate :: Int
                     , separators          :: String }

generatePasswords g c s =
  let ws = filter fits . withoutComments . lines $ s
   in generate g (passwordsToGenerate c) ws
  where withoutComments = filter $ not . isComment
        isComment = flip isPrefixOf "#"
        fits = withinBounds . length
        -- withinBounds = not . \m -> tooShort m || tooLong m
        withinBounds = not . (<+>) tooShort (||) tooLong
        tooShort = (lowerBound >)
        tooLong  = (upperBound <)
        lowerBound = minimumWordLength c
        upperBound = maximumWordLength c
        generate g m ws
          | m > 1     = let (h,i) = split g
                            p     = generatePassword h c ws
                         in p : generate i (m-1) ws
          | otherwise = [ generatePassword g c ws ]

generatePassword g c ws =
  let (h,i) = split g
      dsF = paddingDigits h
      dsR = paddingDigits i
   in concat $ intersperse separator $ [dsF] ++ (pickWords g (wordsInPassword c) ws) ++ [dsR]
  where separator = pick g 1 (separators c)
        paddingDigits g = concat [ pick g 2 digits ]
        digits = "0123456789"

pickWords g n ws = map transform $ zip (pick g n ws) [ 1.. ]
  where transform (w,n) = if even n then map toUpper w else w

pick g n xs = take n $ nub $ [ xs !! x | x <- randomRs (0, (length xs) - 1) g ]

-- Inspired by J's monadic fork.
-- TODO: Find a more meaningful symbol.
(<+>) = monadicFork
monadicFork f g h y = let (f',h') = (f y, h y) in g f' h'

generatePasswords :: StdGen -> Config -> String -> [String]
generatePassword :: StdGen -> Config -> [String] -> String
pickWords :: StdGen -> Int -> [String] -> [String]
pick :: Eq a => StdGen -> Int -> [a] -> [a]
