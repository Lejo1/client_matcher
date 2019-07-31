--[[
This Mods sort clients by their version_string minor, major, patch, serialization_version, protocol_version.
To access this info your server needs either a build merged this in:
https://github.com/minetest/minetest/pull/8616
or for mt-0.4.17 you need this branch:
https://github.com/Lejo1/minetest/tree/version_string4
Just access the data using /client_matcher list
]]

--[[Infos about clients:
MT Official: 5.0.0-githash-Android or 0.4.16/17/17.1 or special -dirty

Forks(sorted by most players):
NAME123 Spieler: 27 ||| 26 ||| 0 ||| 4 ||| 13 ||| 0.4.13

]]

local storage = minetest.get_mod_storage()

minetest.register_on_joinplayer(function(player)
  minetest.after(5, function()
    if player:is_player_connected() then
      local info = minetest.get_player_information(player:get_player_name())
      if info then
        if info.protocol_version and info.serialization_version and info.major
        and info.minor and info.patch and info.version_string then
          local data = info.protocol_version.."@"..info.serialization_version.."@"..
          info.major.."@"..info.minor.."@"..info.patch.."@"..info.version_string
          storage:set_int(data, storage:get_int(data) + 1)
        else minetest.log("error", "Client Matcher: You need a server build with access to advanced player information see README.md for help!")
        end
      end
    end
  end)
end)

local function get_string_by_info(info)
  local str = ""
  local total = 0
  local array = storage:to_table().fields
  for _, numb in pairs(array) do
    total = total + numb
  end
  if not info then
    str = str.."[join count/percentage] protocol_version, ser_vers, major, minor, patch, version_string"
    for index, count in pairs(array) do
      local data = string.split(index, "@")
      str = str.."\n["..count.."/"..100*(count/total).."%] "..table.concat(data, " ||| ")
    end
  elseif info.protocol_version and info.serialization_version and info.major
  and info.minor and info.patch and info.version_string then
    local data = info.protocol_version.."@"..info.serialization_version.."@"..
    info.major.."@"..info.minor.."@"..info.patch.."@"..info.version_string
    local count = storage:get_int(data)
    local data_table = string.split(data, "@")
    str = str.."[join count/percentage] protocol_version, ser_vers, major, minor, patch, version_string"
    str = str.."\n["..count.."/"..100*(count/total).."%] "..table.concat(data_table, " ||| ")
  else str = "Got wrong info."
  end
  return str
end

minetest.register_chatcommand("client_matcher", {
  description = "Shows which kind of client join your server!",
  params = "list/reset/get <name>",
  privs = {ban=true},
  func = function(name, params)
    local split = string.split(params, " ")
    if params == "list" then
      minetest.chat_send_player(name, get_string_by_info())
    elseif params == "reset" then
      storage:from_table(nil)
      return true, "Cleared client matcher list"
    elseif #split == 2 and split[1] == "get" and minetest.get_player_by_name(split[2]) then
      local info = minetest.get_player_information(split[2])
      minetest.chat_send_player(name, get_string_by_info(info))
    else return false, "Invalid Params: list/reset/get <name>"
    end
  end,
})
