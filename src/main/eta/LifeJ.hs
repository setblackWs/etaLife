module LifeJ where

import LifeRules
import Java
import Foreign.StablePtr
import Data.Array
import Data.Bits

-- definitions for exchangin information about pixel of an image (from java)
data Color = Color  {red :: Int,green :: Int, blue :: Int}

cellFromColor::Color->Cell
cellFromColor Color { red = 0, green = 0 , blue = 0 } = Dead
cellFromColor col  = Alive

data JColor = JColor @java.awt.Color
  deriving Class

data WritableImage = WritableImage  @javafx.scene.image.WritableImage
    deriving Class

data PixelWriter = PixelWriter  @javafx.scene.image.PixelWriter
        deriving Class

foreign import java unsafe "getGreen" getGreen
  :: Java JColor Int
foreign import java unsafe "getRed" getRed
    :: Java JColor Int
foreign import java unsafe "getBlue" getBlue
    :: Java JColor Int

foreign import java unsafe "@interface setArgb" setArgb :: PixelWriter->Int->Int->Int->IO  ()

-- state handling
-- we use StablePtr which allows to keep state of Haskell object in java
type GOLState = StablePtr Plane

-- create empty plane
initEmptyXP:: Int -> Int -> IO GOLState
initEmptyXP wi hi = newStablePtr $ createPlane wi hi

-- set one cell in plane to a given color
setCellXP::GOLState->Int->Int->JColor->IO GOLState
setCellXP state x y color = do
                                    red <- javaWith color  getRed
                                    green <- javaWith color  getGreen
                                    blue <- javaWith color getBlue
                                    let color = Color { red = red, green = green , blue  = blue}
                                    let cell  = cellFromColor color
                                    plane <- deRefStablePtr state
                                    newStablePtr $ setCell plane x y cell

-- make new generation

newStateXP::GOLState -> IO GOLState
newStateXP state =  ( deRefStablePtr state) >>= (newStablePtr . nextGeneration)

-- free previous state (otherwise it fills memory)
freeStateXP::GOLState->IO ()
freeStateXP state = freeStablePtr state

-- populate data from state to java image
fillImageXP::GOLState->PixelWriter->IO PixelWriter
fillImageXP state image = do
               plane <- deRefStablePtr state
               let rows = assocs plane
               let cells = (\(y, row) -> ( (\(x, cell) -> (x,y,cell) ) <$>assocs row)  ) <$> rows
               let result = foldl ( \img (x,y,cell) -> ioSet x y cell img ) (return image)  (concat cells)
               result

ioSet::Int->Int->Cell->IO PixelWriter->IO PixelWriter
ioSet x y cell image = image >>= (setPixel x y cell )

setPixel::Int->Int->Cell->PixelWriter->IO PixelWriter
setPixel x y cellState  image =   (  setArgb image x y  (cellToRgb cellState) )  >>  return image

white = Color  { red = 255, green = 255 , blue = 255}
black = Color  { red = 0, green = 0 , blue = 0}

cellToRgb Dead = colorToArgb black
cellToRgb Alive = colorToArgb white

colorToArgb::Color->Int
colorToArgb Color{ red = r, green = g,  blue = b} =(shift 255 24) .|. (shift r 16) .|. (shift g 8) .|. b


-- exports of functions to java
foreign export java "@static pl.setblack.life.LifeJ.initEmpty" initEmptyXP
  :: Int -> Int -> IO (GOLState)

foreign export java "@static pl.setblack.life.LifeJ.setCell" setCellXP
   ::GOLState->Int->Int->JColor->IO GOLState

foreign export java "@static pl.setblack.life.LifeJ.newState" newStateXP
   ::GOLState->IO GOLState

foreign export java "@static pl.setblack.life.LifeJ.freeState" freeStateXP
      ::GOLState->IO ()

foreign export java "@static pl.setblack.life.LifeJ.fillImage" fillImageXP
   ::GOLState->PixelWriter->IO PixelWriter


