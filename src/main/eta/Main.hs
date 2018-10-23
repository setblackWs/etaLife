import LifeB
import LifeJ

wi = 10
hi = 10

myPlane = createPlane wi hi

withLine = foldl (\p x -> setCell p x 5 Alive )  myPlane [1..(wi-1)]



main = do
   putStrLn $ showPlane withLine
   putStrLn $ showVPlane withLine
