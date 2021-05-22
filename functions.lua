
local function stringReplaceIndex(str,a,b,replace) 
	return strsub(str,0,a-1) .. replace .. strsub(str, b+1)
end

M_ChatPainter.stringReplaceIndex=stringReplaceIndex

local function addTexture(text,texture,color) 
	local t= "Interface\\Icons\\ability_warrior_shieldwall";
	if(texture ) then
		t= texture;
	end
	if(color) then 
		text="|CFF"..color..text.."|r"
	end
	return "|T"..t..":0|t"..text;
end
M_ChatPainter.addTexture=addTexture