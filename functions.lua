
local function stringReplaceIndex(str,a,b,replace) 
	return strsub(str,0,a-1) .. replace .. strsub(str, b+1)
end

M_ChatPainter.stringReplaceIndex=stringReplaceIndex