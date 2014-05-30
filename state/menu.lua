local menu = {}

local cur = 1
local uielements = {}
--TODO: Check hash in thread--

--[[if game.hash and game.hash ~= "" then
	if not nps then
		table.insert(loadingstr, "checking hash for "..game)
		refreshLoadingScreen()
	end
	local ghash = sha1.sha1(love.filesystem.read("games/"..game.."/game.zip"))
	if conf.hash ~= ghash then
		error("Hash doesn't match for game "..game.." ("..conf.hash.." vs "..ghash..")")
	end
	if not nps then
		table.insert(loadingstr, "hash check succeeded for "..game)
		refreshLoadingScreen()
	end
end]]

function menu:enter()
	cur = 1
	uielements = {}
	uielements.store = newButton(0,500,150,100,"Store")
	function uielements.store:click(x,y,b)
		Gamestate.push(require "state.store")
	end
	uielements.store.bl = 25
	uielements.store.tr = 0
	uielements.store.br = 0
	
	uielements.play = newButton(150,500,500,100,"Play")
	function uielements.play:click(x,y,b)
		local game = Games[cur]
		current_game = loadgame(game.id,"games/"..game.id.."/game.zip",nil,true)
		Gamestate.push(require "state.game")
	end
	uielements.play.tl = 0
	
	uielements.delete = newButton(650,500,150,100,"Delete")
	function uielements.delete:click(x,y,b)
		local game = Games[cur]
		if game then
			--delete game
			for _,files in pairs(love.filesystem.getDirectoryItems("games/"..game.id)) do
				love.filesystem.remove("games/"..game.id.."/"..files)
			end
			love.filesystem.remove("games/"..game.id)
			
			cur = 1
			Games = {}
			loadingstr = {}
			
			loadGames(true)
		end
	end
	uielements.delete.tl = 0
	uielements.delete.bl = 0
	uielements.delete.tr = 25
	uielements.delete.br = 25
end

function menu:update(dt)
	if Games[cur] then
		Games[cur].banner:update(dt)
	end
	for i, v in pairs(uielements) do
		v:update(dt)
	end
end

function menu:draw()
	love.graphics.setColor(255,255,255)
	local game = Games[cur]
	if game then
		game.banner:draw()
		
		love.graphics.setColor(0,0,0,255)
		if Games[cur-1] then
			love.graphics.draw(fade,0,0,0,1,600)
		end
		if Games[cur+1] then
			love.graphics.draw(fade,800,0,0,-1,600)
		end
	
		love.graphics.setColor(255,255,255)
		love.graphics.setFont(Subtitle)
		love.graphics.print(game.name,0,0)
		love.graphics.setFont(Caption)
		love.graphics.print(game.desc,0,Subtitle:getHeight())
	
		love.graphics.printf("Game is ready to play",600,0,200,"right")
	else
		love.graphics.setFont(Subtitle)
		love.graphics.printf("You have no games installed! Go install some at the store!", 0,0, 800, "center")
	end
	
	for i, v in pairs(uielements) do
		v:draw()
	end
end

function menu:keypressed(key)
	if key == "return" then
		local game = Games[cur]
		current_game = loadgame(game.id,"games/"..game.id.."/game.zip",nil,true)
		Gamestate.push(require "state.game")
	elseif key == "s" then
		Gamestate.push(require "state.store")
	elseif key == "d" then
		local game = Games[cur]
		if game then
			--delete game
			for _,files in pairs(love.filesystem.getDirectoryItems("games/"..game.id)) do
				love.filesystem.remove("games/"..game.id.."/"..files)
			end
			love.filesystem.remove("games/"..game.id)
			
			cur = 1
			Games = {}
			loadingstr = {}
			
			loadGames(true)
		end
	elseif key == "left" and cur > 1 then
		cur = cur-1
	elseif key == "right" and cur < #Games then
		cur = cur+1
	end
end

function menu:mousereleased(x,y,b)
	for i, v in pairs(uielements) do
		v:mousereleased(x,y,b)
	end
end

function menu:leave()
	
end

return menu
