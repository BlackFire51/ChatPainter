
local function colorText(text,lvlDiff) 
	local orange="fc8c03"
	local yellow="fce703"
	local green="00b530"
	local txt=orange
	if(lvlDiff and lvlDiff<2) then
		txt=yellow
	end
	if(lvlDiff and lvlDiff<-5) then
		txt=green
	end
	return "|CFF"..txt..text.."|r"	--|cAARRGGBB https://wowwiki.fandom.com/wiki/UI_escape_sequences
end
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

local function arrayContains(array,needle) 
	for index, value in ipairs(array) do
        if value == needle then
            return true
        end
	end
	return false
end

local function arrayCompareLen(a,b) 
	return string.len(a)-string.len(b)
end

local function arraySortByLen(array) 
	for indexA, valueA in ipairs(array) do
		for indexB, valueB in ipairs(array) do
			if(indexB>indexA)then
				local r= arrayCompareLen(valueA,valueB) 
				if(r<0) then
					local s = array[indexA]
					array[indexA]=array[indexB]
					array[indexB]=s
				end
			end
		end
	end
	return array
end



local iconKeywords={
	{watch=true, texture="Interface\\Icons\\ability_warrior_shieldwall",color="5c98f2", words={"Tank","TANK","tank"}},
	{watch=false, texture="Interface\\Icons\\Ability_ghoulfrenzy",color="f25f5c", words={"DD","dd"}},
	{watch=false, texture="Interface\\Icons\\Spell_nature_healingtouch",color="1cd96b", words={"heal","Heal","HEAL","Heiler","heiler","HEILER"}} -- "heal" all lower must be first because of texture name
}
local iniKeywords={
	{ words={"dm","DM","Todesminen","Todesmine","Deathmines"}, lvl = {17,26}, blacklist={"Nord","West","Ost"}},
	{ words={"Höllen des Wehklagens","hdw"}, lvl = {17,24}},
	{ words={"Burg Schattenfang","Bsf"}, lvl = {20,32}},
	{ words={"Verlies","verlies"}, lvl = {24,32}},
	{ words={"Bfd","Tsg","Tiefschwarze Grotte","Blackfathom Tiefe"}, lvl = {24,32}},
	{ words={"Gnome","Gnomeregan"}, lvl = {29,38}},
	{ words={"RFK","Kral"}, lvl = {29,38}},
	{ words={"RFH","Hügel"}, lvl = {37,46}},
	{ words={"Kloster"}, lvl = {34,45}},
	{ words={"Ulda","Uldaman"}, lvl = {41,51}},
	{ words={"ZF","Zul"} , lvl = {42,46}},
	{ words={"Maraudon"}, lvl = {46,55}},
	{ words={"Tempel"}, lvl = {50,56}},
	{ words={"BRD","brd"}, lvl = {52,60}},
	{ words={"Lbrs","lbrs"}, lvl = {52,60}},
	{ words={"UBRS","Ubrs"}, lvl = {52,60}},
	{ words={"Strath","Strat","stratholme","Staht"}, lvl = {58,60}},
	{ words={"scholo","Scholo","Scholomance"}, lvl = {58,60}},
}

for i,row in ipairs(iniKeywords) do
	for j,word in ipairs(row.words) do
		if not arrayContains(row.words,string.upper(word)) then
			table.insert(row.words,string.upper(word))
		end
		if not arrayContains(row.words,string.lower(word)) then
			table.insert(row.words,string.lower(word))
		end
	end
	arraySortByLen(row.words)
end

for i,row in ipairs(iniKeywords) do
	if(row.blacklist and row.blacklist[1]) then
		for j,word in ipairs(row.blacklist) do
			if not arrayContains(row.blacklist,string.upper(word)) then
				table.insert(row.blacklist,string.upper(word))
			end
			if not arrayContains(row.blacklist,string.lower(word)) then
				table.insert(row.blacklist,string.lower(word))
			end
		end
	end
end

local DEBUG=false
local function myChatFilter(self, event, msg, author, ...)
	local channelStr, charName, ukn1,a,b, channelNum, channelName ,ukn2,unk3 ,senderGUID, ukn4, unk5 = ...
	--print(...)
	--print(a)
	--print(b)
	if(channelName ~= "SucheNachGruppe" and channelName ~= "LookingForGroup" and channelName ~= "lfg" ) then
		return
	end
	--print(self)
	--dump(self)
	--print(event)
	if DEBUG then print(msg) end
	--print(msg)
	--print(author)
	--print(senderGUID)
	--print(...)
	local msglow = strlower(msg)
	local foundSpot={}
	local mod=false
	local myRoll=false
	for i,row in ipairs(iconKeywords) do
		for j,word in ipairs(row.words) do
			if msg:find(word) then
				msg= gsub(msg, word, addTexture(word,row.texture,row.color))
				mod=true
				myRoll = myRoll or row.watch
			end
		end
	end

	local myIni=false
	for i,row in ipairs(iniKeywords) do
		for j,word in ipairs(row.words) do
			
			if msg:find(word) then
				if DEBUG then print("found "..word.." :" ..tostring(msg:find(word))) end
				local skip=false
				local startPos,endPos = strfind(msg,word)
				if(DEBUG) then print("f: "..tostring(startPos).." t: "..tostring(endPos)) end
				for k,spot in ipairs(foundSpot) do
					if(DEBUG) then print(">f: "..tostring(spot[1]).." t: "..tostring(spot[2])) end
					if( (startPos>=spot[1] and startPos>spot[1] ) or
						(startPos>=spot[2] and startPos>spot[2] )    ) then
						skip=true
					end
				end
				if(row.blacklist and row.blacklist[1]) then
					for k,bad in ipairs(row.blacklist) do
						skip=skip or msg:find(bad)
					end
				end
				if DEBUG then print("skip :" ..tostring(skip)) end
				if(not skip) then 
					local addText=""
					local lvlDiff=99
					if(row.lvl and row.lvl[1]) then
						local lvl = UnitLevel("PLAYER")
						if(row.lvl[1]< lvl-2 and row.lvl[2]>lvl and not IsInGroup() ) then
							PlaySound(3081,"master")
						end
						addText="("..tostring(row.lvl[1]).."-"..tostring(row.lvl[2])..")"
						lvlDiff=row.lvl[1]-lvl
					end
					--print(row.lvl[1])
					local newWord=colorText(word,lvlDiff)..addText;
					msg= gsub(msg, word, newWord)
					table.insert(foundSpot,{startPos,startPos+string.len(newWord)})
					mod=true
				end
			end
		end
	end

	if mod then
		return false, msg, author, ...
	end
  end

ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", myChatFilter)


SLASH_CHATPAINTER1 = "/cp"
SlashCmdList["CHATPAINTER"] = function( msg, ...)
   print(msg)
   --print(...)
   DEBUG=true
   local bool,retMsg,auth = myChatFilter(nil, "CHAT_MSG_CHANNEL", msg, "Nobody", "channelStr", "charName", "ukn1","a","b", 4, "SucheNachGruppe" ,"ukn2","unk3" ,"senderGUID", "ukn4", "unk5")
   DEBUG=false	
   print(retMsg)
end 
-- /cp Suche Gruppe für Todesmine
-- /cp Mage sucht An an strath ud

-- SlashCmdList["CHATPAINTER"] = function( msg, ...)
-- 	if(msg=="p") then
-- 		for j,word in ipairs(iniKeywords[1].words) do
-- 			print(word.." - "..tostring(string.len(word)))
-- 		end
-- 	end
-- 	if(msg=="s") then

-- 		local rarr= arraySortByLen(iniKeywords[1].words)
-- 		for j,word in ipairs(rarr) do
-- 			print(word.." - "..tostring(string.len(word)))
-- 		end
-- 	end
-- end 