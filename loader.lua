local games = {
    [{4723618670}] = "https://raw.githubusercontent.com/1xAbel/scripts/main/Wisteria-Revamped.lua",
    [{3956818381}] = "https://raw.githubusercontent.com/1xAbel/scripts/main/ninja-legends.lua",
    [{11468159863, 6152116144}] = "https://raw.githubusercontent.com/1xAbel/scripts/main/ProjectSlayers.lua",
}

for ids, url in next, games do
    if table.find(ids, game.PlaceId) then
        loadstring(game:HttpGet(url))(); break
    end
end
