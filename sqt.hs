module Main (main) where

import Control.Monad (forM)
import System.Directory (doesDirectoryExist, getDirectoryContents)
import System.FilePath ((</>))
import Text.Regex.Posix ((=~))
import System.Environment (getArgs)
import Data.List

main :: IO ()
main = do
  args <- getArgs
  let path = args !!0
  let fileType = args !!1
  folders <- getRecursiveContents path fileType
  result <- mapM ( readFileAndGetLength ) ( folders )
  putStrLn "-- Sarbotte Quality Tool --"
  mapM_ printResult ( sortBy sortBySQ result )
  return ()

sortBySQ (path1, (js1, total1, sq1)) (path2, (js2, total2, sq2))
  | sq1 < sq2 = LT
  | sq1 > sq2 = GT
  | sq1 == sq2 = compare path1 path2

fst3 (x, _, _) = x
snd3 (_, x, _) = x
thd3 (_, _, x) = x

computeResult js total = do
  if js == 0 then do
    100
    else js `div` total

-- getRecursiveContents :: IO String -> IO [FilePath]
getRecursiveContents topdir fileType = do
  names <- getDirectoryContents topdir
  let properNames = filter (`notElem` [".", ".."]) names
  paths <- forM properNames $ \name -> do
    let path = topdir </> name
    isDirectory <- doesDirectoryExist path
    if isDirectory
      then getRecursiveContents path fileType
      else return $ filter (\x -> x =~ (".*\\." ++ fileType ++ "$") :: Bool) [path]
  return $ concat paths

-- getLengthFromFileContent :: String -> Int
getLengthFromFileContent content = do
  let regex = "<script(.*)>(([^<]|\n)*)</script>"
  let regex2 = "<script(.*)>(.*)(?=</script>)"
  let groupsLenth = map ( length . (!!2) ) (content =~ regex :: [[String]])
  let totalJsLength = foldr (+) 0 groupsLenth
  let totalLength = length content
  ( totalJsLength , totalLength , (computeResult totalJsLength totalLength ))

-- readFileAndGetLength :: FilePath -> (FilePath, (Int, Int))
readFileAndGetLength path = do
  file <- readFile path
  return ( path, getLengthFromFileContent file)

printResult result = do
  let path = fst result
  let js = fst3 $ snd result
  let total = snd3 $ snd result
  let sq = thd3 $ snd result
  putStrLn ( path ++ " " ++ show (sq) ++ " " ++ "(" ++ show (js) ++ "/" ++ show (total) ++ ")" )
  return ()