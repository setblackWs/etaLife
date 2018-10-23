module LifeJ where

import LifeB
import Java
import Foreign.StablePtr
import Data.Array
import Data.Bits

data Color = Color  {red :: Int,green :: Int, blue :: Int}
cellFromColor::Color->Cell
cellFromColor Color { red = 0, green = 0 , blue = 0 } = Dead
cellFromColor col  = Alive

type GOLState = StablePtr Plane

data JColor = JColor @java.awt.Color
  deriving Class

data BufferedImage = BufferedImage  @java.awt.image.BufferedImage
    deriving Class

foreign import java unsafe "getGreen" getGreen
  :: Java JColor Int
foreign import java unsafe "getRed" getRed
    :: Java JColor Int
foreign import java unsafe "getBlue" getBlue
    :: Java JColor Int

foreign import java unsafe "setRGB" setRGB :: BufferedImage->Int->Int->Int->IO  ()

initEmptyXP:: Int -> Int -> IO GOLState
initEmptyXP wi hi = newStablePtr $ createPlane wi hi

setCellXP::GOLState->Int->Int->JColor->IO GOLState
setCellXP state x y color = do
                                    red <- javaWith color  getRed
                                    green <- javaWith color  getGreen
                                    blue <- javaWith color getBlue
                                    let color = Color { red = red, green = green , blue  = blue}
                                    let cell  = cellFromColor color
                                    plane <- deRefStablePtr state
                                    newStablePtr $ setCell plane x y cell

newStateXP::GOLState -> IO GOLState
newStateXP state =  ( deRefStablePtr state) >>= (newStablePtr . processPlane)

freeStateXP::GOLState->IO ()
freeStateXP state = freeStablePtr state

fillImageXP::GOLState->BufferedImage->IO BufferedImage
fillImageXP state image = do
               plane <- deRefStablePtr state
               let rows = assocs plane
               let cells = (\(y, row) -> ( (\(x, cell) -> (x,y,cell) ) <$>assocs row)  ) <$> rows
               let result = foldl ( \img (x,y,cell) -> ioSet x y cell img ) (return image)  (concat cells)
               result

ioSet::Int->Int->Cell->IO BufferedImage->IO BufferedImage
ioSet x y cell image = image >>= (setPixel x y cell )

setPixel::Int->Int->Cell->BufferedImage->IO BufferedImage
setPixel x y Dead image =   (  setRGB image x y  0)  >>  return image
setPixel x y Alive  image =   (  setRGB image x y  (cellToRgb white) )  >>  return image

white = Color  { red = 255, green = 255 , blue = 255}

cellToRgb::Color->Int
cellToRgb Color{ red = r, green = g,  blue = b} = (shift r 16) .|. (shift g 8) .|. b

foreign export java "@static pl.setblack.life.LifeJ.initEmpty" initEmptyXP
  :: Int -> Int -> IO (GOLState)

foreign export java "@static pl.setblack.life.LifeJ.setCell" setCellXP
   ::GOLState->Int->Int->JColor->IO GOLState

foreign export java "@static pl.setblack.life.LifeJ.newState" newStateXP
   ::GOLState->IO GOLState

foreign export java "@static pl.setblack.life.LifeJ.freeState" freeStateXP
      ::GOLState->IO ()

foreign export java "@static pl.setblack.life.LifeJ.fillImage" fillImageXP
   ::GOLState->BufferedImage->IO BufferedImage


