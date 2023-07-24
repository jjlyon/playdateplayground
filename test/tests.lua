sb = require("../source/softbody")

-- lu = require("luaunit")

-- sb.softbody()
function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end

print(dump(sb))

-- os.exit( lu.LuaUnit.run() )
