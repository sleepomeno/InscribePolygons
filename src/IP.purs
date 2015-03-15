module IP where

import Debug.Trace
import Math
import Data.Foreign
import Data.Array (map, (..))
import qualified Data.Array.Unsafe as ArrayUnsafe
import Rx.JQuery
import Rx.Observable
import Control.Monad.JQuery
import Control.Monad
import Global (readInt)
import Control.Monad.Eff
import Data.Traversable (sequence)
import Graphics.Canvas (getCanvasElementById, getContext2D, getCanvasDimensions, clearRect)
import Graphics.Canvas.Free

toRadian d = 2 * Math.pi / 360 * d
toCoordinates cosSin' = { x : center.x + radius * cosSin'.c, y : center.y + radius * cosSin'.s }
center = { x : 210, y : 210 }
radius = 200
defaultVertices = 3
defaultShowTriangles = false

drawPolygon coordinates showTriangles  = do 
	beginPath
	setFillStyle "#008000"
	(\{ x: x', y: y'} -> moveTo x' y') (ArrayUnsafe.head coordinates)
	sequence $ map (\{ x: x', y: y'} -> lineTo x' y') (ArrayUnsafe.tail coordinates)
 	closePath
	fill
	when showTriangles $ do 
 		setLineWidth 1
		setStrokeStyle "#111111"
		beginPath
		sequence $ map (\{ x: x', y: y'} -> do 
			moveTo center.x center.y
			lineTo x' y'
			stroke) coordinates
		closePath

foreign import stringify
  "function stringify(x) {\
  \  return x+\"\";\
  \}" :: Foreign -> String

main = do
	canvas <- getCanvasElementById "canvas"
	context <- getContext2D canvas
	verticesInput <- select "#vertices"
	polygonArea <- select "#polygonArea"
	pi <- select "#pi"
	triangles <- select "#triangles"

	let updateUI num showTriangles = do 
			{ pArea : polygonAreaPercent, pi : piApprox } <- showPolygon canvas context num showTriangles
			setText (show polygonAreaPercent <> "%") polygonArea
			setText (show piApprox) pi
	let updateUI' = do 
				showTriangles <- ((== "true") <<< stringify) <$> getProp "checked" triangles
				num <- (stringify >>> readInt 10) <$> getValue verticesInput
				updateUI num showTriangles
	trianglesChange <- "click" `onAsObservable` triangles
	trianglesChange `subscribe` \_ -> void $ updateUI'

	verticesChange <- "focus" `onAsObservable` verticesInput
	verticesChange `subscribe` \_ -> void updateUI'

	updateUI defaultVertices defaultShowTriangles

showPolygon canvas context polygonDegree showTraingles = do
	hw <- getCanvasDimensions canvas
	clearRect context { h : hw.height, w : hw.width, y : 0, x : 0 }
	runGraphics context $ do 
		let diff = 360 / polygonDegree
		let cosSin r = { c : Math.cos r, s : Math.sin r }
		let coordinates = map (toCoordinates <<< cosSin <<< toRadian <<< (*diff)) (1 .. polygonDegree)
		let lengthSide = case coordinates of 
								(d1 : d2 : _) -> Math.sqrt $ (Math.pow (d1.x - d2.x) 2) + (Math.pow (d1.y - d2.y) 2)
		let polygonArea = 1/4 * polygonDegree * (Math.pow lengthSide 2) * ((Math.cos(Math.pi / polygonDegree)) / (Math.sin(Math.pi / polygonDegree)))
		let circleArea = (Math.pow radius 2) * Math.pi
		let polygonAreaPercent = Math.round (polygonArea / circleArea * 100000) / 1000
		let piApprox = polygonArea / (Math.pow radius 2)

		drawCircle
		drawPolygon coordinates showTraingles
		return { pArea : polygonAreaPercent, pi : piApprox }
	
drawCircle = do 
	arc { x: center.x, y: center.y, r: radius, start: 0, end: Math.pi * 2 }
	setFillStyle "#000000"
	fill
