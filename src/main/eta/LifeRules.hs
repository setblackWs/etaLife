module LifeRules where

-- basic definitions
-- keep them

import Data.Array
import Data.Maybe

data Cell = Dead | Alive
type Row = Array Int Cell
type Plane = Array Int Row

---  improve this solution according to Conway's Game of Life rules
nextGeneration::Plane->Plane
nextGeneration plane =   array (bounds plane) newRows
      where
            rows = assocs plane
            newRows = (\(y,row) -> (y, processRow plane row y)   ) <$> rows


countNeighbours::Plane->Int->Int->Int
countNeighbours plane x y = foldl (+) 0 allValues
      where
         rows = [y-1, y, y+1]
         cells = [x-1, x, x+1]
         valuesForY y1 =  (\x -> getCellValue plane x y1 ) <$> cells
         allValues =  rows >>= valuesForY

processRow::Plane->Row->Int->Row
processRow plane row y = array (bounds row) neighbours
      where
            cells = assocs row
            neighbours = ( \(x, cell) -> (x, decide cell (countNeighbours plane x y)) ) <$> cells


decide::Cell->Int->Cell
decide Dead 3 = Alive
decide Alive 3 = Alive
decide Alive 4 = Alive
decide _ _ = Dead

-- some utility function You can use (you do not have to)
getCellValue::Plane->Int->Int->Int
getCellValue plane x y
   | (y >= minBound && y <=maxBound ) = getCellInRow ( plane ! y ) x
   | otherwise = 0
      where
         minBound = fst myBounds
         maxBound = snd myBounds
         myBounds = bounds plane

getCellInRow::Row->Int->Int
getCellInRow row x
   | (x >= minBound && x <=maxBound ) = cellValue $ row ! x
   | otherwise = 0
   where
         minBound = fst myBounds
         maxBound = snd myBounds
         myBounds = bounds row

cellValue Dead = 0
cellValue Alive = 1


-- this is construction part - java uses those functions
-- to create initial state of game
-- bindings to java are defined in LifeJ

createRow::Int->Row
createRow size = array (0, size) [ (i, Dead) | i <- [0..size]]

createPlane::Int->Int->Plane
createPlane hi wi = array (0, hi) [ (i, createRow wi) | i <- [0..hi]]

setCell::Plane->Int->Int->Cell->Plane
setCell plane x y cell= plane  // [(y, newRow)]
         where
            row = plane ! y
            newRow = row // [(x, cell) ]



-- show / debug functions

showRow::Row->String
showRow row =  fmap showCell elemsList
   where elemsList = elems row

showPlane::Plane->String
showPlane plane = foldl (++) ""  stringEndl
      where
         elemsList = elems plane
         strings = fmap showRow elemsList
         stringEndl = fmap (\x -> x ++ "\n")  strings

showCell::Cell -> Char
showCell Dead = '.'
showCell Alive = 'O'

showVRow::Plane->Int->String
showVRow plane y =  rowString ++ "\n"
   where
         row = plane ! y
         myBounds =  bounds row
         xs  = [(fst myBounds).. (snd myBounds)]
         aRow = (\x -> show (countNeighbours plane x y) ) <$> xs
         rowString = foldl (++) "" aRow

showVPlane::Plane->String
showVPlane plane = foldl (++)  "" (showVRow plane <$> rows)
   where
      myBounds =  bounds plane
      rows  = [(fst myBounds).. (snd myBounds)]
