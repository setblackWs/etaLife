import LifeRules
import LifeJ
import Control.Monad


{-
 this code below may be used to debug eta part without java
 shouls also run on ghc

-}
wi = 40
hi = 20

myPlane = createPlane hi wi

withLine = foldl (\p x -> setCell p x 10 Alive )  myPlane [1..(wi-1)]

main = do
      putStrLn $ showPlane  withLine
      putStrLn $ showPlane  $ nextGeneration withLine
      foldM (\p i -> (putStrLn $ showPlane p )>> return (nextGeneration p) ) withLine  [1..100]





