local games = {
    [{3652625463}] = "https://raw.githubusercontent.com/1xAbel/scripts/main/LiftingSimulator.lua",
    [{10476933477}] = "https://raw.githubusercontent.com/1xAbel/scripts/main/strongninjasim.lua",
    [{9498006165}] = "https://raw.githubusercontent.com/1xAbel/scripts/main/tapping-simulator.lua",
    [{8540346411}] = "https://raw.githubusercontent.com/1xAbel/scripts/main/rebirth-champions.lua",
    [{4723618670}] = "https://raw.githubusercontent.com/1xAbel/scripts/main/Wisteria-Revamped.lua",
    [{7525610732}] = "https://raw.githubusercontent.com/1xAbel/scripts/main/Kaizen.lua",
    [{1499872953}] = "https://raw.githubusercontent.com/1xAbel/scripts/main/boku-no-roblox.lua",
    [{11468159863, 6152116144}] = "https://raw.githubusercontent.com/1xAbel/scripts/main/ProjectSlayers.lua",
}

for ids, url in next, games do
    if table.find(ids, game.PlaceId) then
        loadstring(game:HttpGet(url))(); break
    end
end
