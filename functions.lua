local addonName, NS = ...
NS.functions={}


local function stringReplaceIndex(str,a,b,replace) 
	return strsub(str,0,a-1) .. replace .. strsub(str, b+1)
end
NS.functions.stringReplaceIndex=stringReplaceIndex
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
NS.functions.addTexture=addTexture

local function colorText(text,lvlDiffMin,lvlDiffMax) 
	local orange="fc8c03"
	local yellow="fce703"
	local green="00b530"
	local txt=orange
	if(lvlDiffMin and lvlDiffMin<1) then
		txt=yellow
	end
	if(lvlDiffMax and lvlDiffMax<0) then
		txt=green
	end
	return "|CFF"..txt..text.."|r"	--|cAARRGGBB https://wowwiki.fandom.com/wiki/UI_escape_sequences
end
NS.functions.colorText=colorText