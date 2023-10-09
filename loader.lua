local games = {
    [{5951002734, 9145972203}] = "https://raw.githubusercontent.com/1xAbel/scripts/main/project_baki_2",
    [{11200494415}] = "https://raw.githubusercontent.com/1xAbel/scripts/main/jujustu_chron.lua",
    [{11468159863, 6152116144}] = "https://raw.githubusercontent.com/1xAbel/scripts/main/ProjectSlayers.lua",
}

for ids, url in next, games do
    if table.find(ids, game.PlaceId) then
        loadstring(game:HttpGet(url))(); break
    end
end
