local games = {
    [{3652625463}] = "https://raw.githubusercontent.com/1xAbel/scripts/main/LiftingSimulator.lua",
    [{10476933477}] = "https://raw.githubusercontent.com/1xAbel/scripts/main/strongninjasim.lua",
    [{9498006165}) = "https://raw.githubusercontent.com/1xAbel/scripts/main/tapping%20simulator.lua",
}

for ids, url in next, games do
    if table.find(ids, game.PlaceId) then
        loadstring(game:HttpGet(url))(); break
    end
end
