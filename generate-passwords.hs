module Main where

import Data.List (find)
import Password (Config (..), generatePasswords)
import System.Directory (doesFileExist)
import System.Environment (getArgs)
import System.Random (getStdGen)
import Text.Printf (printf)

type Path = String

data Configuration = WordsInPassword
                   | MinimumWordLength
                   | MaximumWordLength
                   | PasswordsToGenerate
                   | Separators
                   | Dictionary deriving Eq
-- TODO: Eliminate having to repeat these six configurations four distinct times below.
--     : I was doing getOption c = head $ find (\o -> c == configuration o) options,
--     : but I thought that was a little sloppy and not taking full advantage of
--     : the type checking system and the union type.

data Option = Option { configuration :: Configuration
                     , flag          :: String
                     , defaultValue  :: String
                     , description   :: String }

options = [ Option { configuration = WordsInPassword    , flag = "-w", defaultValue =  "3", description = "Number of words to include in password."             }
          , Option { configuration = MinimumWordLength  , flag = "-n", defaultValue =  "4", description = "Minimum length of each word to include in password." }
          , Option { configuration = MaximumWordLength  , flag = "-x", defaultValue =  "8", description = "Maximum length of each word to include in password." }
          , Option { configuration = PasswordsToGenerate, flag = "-p", defaultValue = "10", description = "Number of passwords to generate."                    }
          , Option { configuration = Separators         , flag = "-s", defaultValue = "\"!@$%^&*-_+=:|~?/.;\"", description = "List of separators as a string."     }
          , Option { configuration = Dictionary         , flag = "-d", defaultValue = "EN_sample.txt", description = "Path to dictionary file to use."           } ]

optionDescriptions = unlines $ map (\o -> printf "%s    %s" (flag o) (description  o)) options
defaultOptions     = concat  $ map (\o -> printf " %s %s"   (flag o) (defaultValue o)) options

helpMessage = [ "Usage: generate-passwords [options]",
  "",
  "Generates random human-readable passwords in the spirit of xkpasswd.net.",
  "",
  "Options:",
  optionDescriptions,
  "Running with no options defaults to the following options:",
  "> generate-passwords" ++ defaultOptions,
  "" ]

main = do
  args <- getArgs
  let opts = parseCL args (Just $ Config { wordsInPassword     = read $ getOptionDefaultValue WordsInPassword
                                         , minimumWordLength   = read $ getOptionDefaultValue MinimumWordLength
                                         , maximumWordLength   = read $ getOptionDefaultValue MaximumWordLength
                                         , passwordsToGenerate = read $ getOptionDefaultValue PasswordsToGenerate
                                         , separators          =        getOptionDefaultValue Separators }
                          , getOptionDefaultValue Dictionary)

  case opts of
    (Nothing, _) -> do putStrLn $ unlines helpMessage
    (Just config, dictionary) -> do
      dictionaryExists <- doesFileExist dictionary
      if not dictionaryExists
      then do putStrLn $ printf "Dictionary file '%s' does not exist." dictionary
      else do c <- readFile dictionary
              g <- getStdGen
              putStrLn . unlines $ generatePasswords g config c
  where
    getOptionDefaultValue = defaultValue . getOption

parseCL []                                     opts     = opts
parseCL (dictionaryOption         :d:xs) (Just opts, _) = parseCL xs (Just opts, d)
parseCL (minimumWordLengthOption  :n:xs) (Just opts, d) = parseCL xs (Just opts { minimumWordLength   = read n }, d)
parseCL (passwordsToGenerateOption:p:xs) (Just opts, d) = parseCL xs (Just opts { passwordsToGenerate = read p }, d)
parseCL (separatorsOption         :s:xs) (Just opts, d) = parseCL xs (Just opts { separators          =      s }, d)
parseCL (wordsInPasswordOption    :w:xs) (Just opts, d) = parseCL xs (Just opts { wordsInPassword     = read w }, d)
parseCL (maximumWordLengthOption  :x:xs) (Just opts, d) = parseCL xs (Just opts { maximumWordLength   = read x }, d)
parseCL (_                        :  xs)       opts     = (Nothing, "")
  where dictionaryOption          = getOptionFlag Dictionary
        minimumWordLengthOption   = getOptionFlag MinimumWordLength
        passwordsToGenerateOption = getOptionFlag PasswordsToGenerate
        separatorsOption          = getOptionFlag Separators
        wordsInPasswordOption     = getOptionFlag WordsInPassword
        maximumWordLengthOption   = getOptionFlag MaximumWordLength
        getOptionFlag = flag . getOption

getOption Dictionary          = findOption Dictionary
getOption MinimumWordLength   = findOption MinimumWordLength
getOption PasswordsToGenerate = findOption PasswordsToGenerate
getOption Separators          = findOption Separators
getOption WordsInPassword     = findOption WordsInPassword
getOption MaximumWordLength   = findOption MaximumWordLength

findOption c =
  let m = find ((c ==) . configuration) options
   in case m of
        Just o  -> o
        Nothing -> undefined

optionDescriptions, defaultOptions :: String
main :: IO ()
parseCL :: [String] -> (Maybe Config, Path) -> (Maybe Config, Path)
getOption :: Configuration -> Option
findOption :: Configuration -> Option
