local games = {
    [{4723618670}] = "https://raw.githubusercontent.com/1xAbel/scripts/main/Wisteria-Revamped.lua",
    [{3956818381}] = "https://raw.githubusercontent.com/1xAbel/scripts/main/ninja-legends.lua",
    [{3823781113}] = "https://raw.githubusercontent.com/1xAbel/scripts/main/SaberSimulator.lua",
    [{11468159863, 6152116144}] = "https://raw.githubusercontent.com/1xAbel/scripts/main/ProjectSlayers.lua",
    [{11040063484}] = "https://raw.githubusercontent.com/1xAbel/scripts/main/SwordFightersSimulator.lua",
    [{11884594868, 11885022882}] = "https://raw.githubusercontent.com/1xAbel/scripts/main/AnimeDefenseSimulator.lua",
}

for ids, url in next, games do
    if table.find(ids, game.PlaceId) then
        loadstring(game:HttpGet(url))(); break
    end
end
