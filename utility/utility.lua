-- https://stackoverflow.com/questions/35572435/how-do-you-do-the-fisher-yates-shuffle-in-lua/68486276#68486276
function shuffle(t)
    for i = #total, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
end