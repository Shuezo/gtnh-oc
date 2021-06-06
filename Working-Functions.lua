

function Graphic.bar(color, posX, posY, sizeW, sizeH)
	gpu.setBackground(color)
	gpu.setForgeound(color2)
	gpu.fill(posX, posY, sizeW, sizeH, " ")
end --end bar

function Graphic.splashScreen()
	Graphic.clearScreen()
	local x, y = gpu.getResolution()
	--Graphic.drawFrame(color1,1,1,x,y)
	Graphic.drawFrame()
	term.setCursor(x/2-7, y/2+1)
    term.write("Initializing...")
	term.setCursor(2, y-2)
	os.sleep(2)
end --end splashScreen