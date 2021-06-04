
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


local function arrayContains(array,needle) 
	for index, value in ipairs(array) do
        if value == needle then
            return true
        end
	end
	return false
end


local function tablelength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end
local function printTable(T)
	for index, data in ipairs(T) do
		print(index)
	
		for key, value in pairs(data) do
			print('\t', key, value)
		end
	end
end




local iconKeywords = M_ChatPainter.iconKeywords
local iniKeywords = M_ChatPainter.iniKeywords
local iniSubinstances = M_ChatPainter.iniSubinstances

-- for i,row in ipairs(iniKeywords) do
-- 	if(row.blacklist and row.blacklist[1]) then
-- 		for j,word in ipairs(row.blacklist) do
-- 			if not arrayContains(row.blacklist,string.upper(word)) then
-- 				table.insert(row.blacklist,string.upper(word))
-- 			end
-- 			if not arrayContains(row.blacklist,string.lower(word)) then
-- 				table.insert(row.blacklist,string.lower(word))
-- 			end
-- 		end
-- 	end
-- end
local DEBUG=false
local DEBUG_ROLE=false
local function findInstances(msg)

	local msglow = strlower(msg)

	
	local instanceList={}
	local foundSpot={}
	for i,ini in ipairs(iniKeywords) do
		for j,word in ipairs(ini.words) do
			--if DEBUG then print("check "..word) end
			--if msg:find(word) or msglow:find(string.lower(word)) then
			if string.match(msglow,"[ /]"..string.lower(word),0) ~= nil then
				if DEBUG then print("found "..word.." :" ..tostring(msg:find(word))) end
				local skip=false
				local startPos,endPos = strfind(msglow,string.lower(word))
				if(DEBUG) then print("f: "..tostring(startPos).." t: "..tostring(endPos)) end
				-- check if the spot is blacklisted
				for k,spot in ipairs(foundSpot) do
					if(DEBUG) then print(">f: "..tostring(spot[1]).." t: "..tostring(spot[2])) end

					if( (startPos>=spot[1] and startPos<spot[2] ) or
						(endPos>=spot[1] and endPos>spot[2] )    ) then
						skip=true
					end
				end

				-- check if we can not use this instanc ebecaus ea blacklisted word is used
				if(ini.blacklist and ini.blacklist[1]) then
					for k,bad in ipairs(ini.blacklist) do
						skip=skip or msglow:find(string.lower(bad))
					end
				end
				-- if all ok add to ini list
				if( not skip) then
					table.insert(instanceList,{kw=ini,f=startPos,t=endPos,w=strsub(msg,startPos,endPos)})
					table.insert(foundSpot,{startPos,endPos}) -- blacklist spot
				end
			end


		end
	end
	return instanceList
end

local function findSubInis(msg, idArr)
	local msglow = strlower(msg)
	local instanceList={}
	local foundSpot={}
	for k,subIniId in ipairs(idArr) do
		if(iniSubinstances[subIniId]) then
		--##
			if DEBUG then print("check for sub ini id  :" ..tostring(subIniId)) end
			for jSub,wordSub in ipairs(iniSubinstances[subIniId].words) do
				if DEBUG then print("check for:" ..tostring(wordSub)) end
				if msg:find(wordSub) or msglow:find(string.lower(wordSub)) then
					local startPos,endPos = strfind(msglow,string.lower(wordSub))
					if DEBUG then print("found "..wordSub) end
					local skip=false
					for k,spot in ipairs(foundSpot) do

						if( (startPos>=spot[1] and startPos<spot[2] ) or
							(endPos>=spot[1] and endPos>spot[2] )    ) then
								-- to nothing
								if DEBUG then print("sub ini invalide pos skipping") end
								skip=true
						end
					end
					if(not skip) then
													
						table.insert(instanceList,{kw=iniSubinstances[subIniId],f=startPos,t=endPos,w=strsub(msg,startPos,endPos)})
						table.insert(foundSpot,{startPos,startPos+string.len(wordSub)})
					end
				end
			end
		end
	end
	return instanceList
end

local lastLineId=0
local function myChatFilter(self, event, msg, author, ...)
	local channelStr, charName, ukn1,a,b, channelNum, channelName ,ukn2,lineID ,senderGUID, ukn4, unk5 = ...
	if(lastLineId == lineID) then 
		--return false, msg , author, ... 
	end
	lastLineId=lineID
	--print(...)
	--print(a)
	--print(b)
	if(channelName ~= "SucheNachGruppe" and channelName ~= "LookingForGroup" and channelName ~= "lfg" ) then
		return
	end
	--print(self)
	--dump(self)
	--print(event)
	--print(msg)
	--print(author)
	--print(senderGUID)
	--print(...)
	local msglow = strlower(msg)

	if msglow:find("boost") then
		return false, "|C05".."808080"..msg.."|r", author, ... 
	end
	

	local mod=false
	local myRoll=false


	local iniList = findInstances(msg)

	local msg_offset=0
	if(tablelength(iniList) > 0 )then
		for j,iniObj in ipairs(iniList) do
			local ini = iniObj.kw
			if DEBUG then print("found ini "..ini.words[1]) end
			-- check levels
			local addText=""
			local lvlDiff=99
			if(ini.lvl and ini.lvl[1]) then
				local lvl = UnitLevel("PLAYER")
				if(ini.lvl[1]-3< lvl and ini.lvl[2]-3>lvl and not IsInGroup() ) then
					-- if it is my lvl range play sound
					PlaySound(3081,"master")
				end
				addText="("..tostring(ini.lvl[1]).."-"..tostring(ini.lvl[2])..")"
				lvlDiff=ini.lvl[1]-lvl
			end
			--print(row.lvl[1])
			local newWord=colorText(iniObj.w,lvlDiff)..addText;
			msg= gsub(msg, iniObj.w, newWord) -- replace txt in msg 
			msg_offset=msg_offset+(strlen(newWord)-strlen(iniObj.w))
			mod=true
			--#################

			if DEBUG then print("check sub inis") end
			if(ini.subIni and ini.subIni[1]) then
				local subInis=findSubInis(msg,ini.subIni)

				for j,subIniObj in ipairs(subInis) do
					local subIni = subIniObj.kw
					if DEBUG then print("found ini "..subIni.words[1]) end
					local addText=""
					if(subIni.lvl and subIni.lvl[1]) then
						addText="("..tostring(subIni.lvl[1]).."-"..tostring(subIni.lvl[2])..")"

						local newWord=colorText(subIniObj.w,lvlDiff)..addText;
						msg= gsub(msg, subIniObj.w, newWord)

					end
					if DEBUG then print("add txt "..addText) end

				
				end

			end
		end
	end --- end instances 



	-- if a instance is found we change the msg so we perhaps need to update it
	msglow = string.lower(msg)
	-- #####
	-- Find rols and color them

	local RolePosLock={}
	for i,row in ipairs(iconKeywords) do
		local minPos=0
		for j,word in ipairs(row.words) do
			if msglow:find(word) then
				local startPosA,endPosA = strfind(msglow,string.lower(word))
				local startPosB,endPosB = strfind(msglow,"healingtouch")
				if startPosA>minPos then 
					minPos=startPosA
					if startPosB ==nil or startPosB > 0 and (abs(startPosA-startPosB) > 4 ) then
						if DEBUG_ROLE then print("found role "..word) end
						if DEBUG_ROLE then print("role "..startPosA .. "to:"..endPosA) end
						local newTxt = M_ChatPainter.addTexture(word,row.texture,row.color);

						--table.insert(RolePosLock,{startPosA , startPosA +string.len(newTxt) } )
						--msg= M_ChatPainter.stringReplaceIndex(msg,startPosA,endPosA, newTxt) 
						local mWord = strsub(msg,startPosA,endPosA)
						--print("found role -"..mWord .."- for-".. word)
						--print("@"..startPosA .."-".. string.len(word) .. "line: "..lineID)
						msg = gsub(msg, mWord, newTxt)
						msglow = string.lower(msg)
						mod=true
						myRoll = myRoll or row.watch
					end
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
-- /cp LFM Kloster Kath Tank, Heal, DD

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