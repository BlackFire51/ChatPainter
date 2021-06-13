local addonName, NS = ...

NS.settings={}
NS.settings.addLevels=true
NS.settings.NotificationSound=false


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



function getGuildMemeberList()

	local l={}

	local numTotalMembers, numOnlineMaxLevelMembers, numOnlineMembers = GetNumGuildMembers();
	for i=1,numTotalMembers do
		local name, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName, achievementPoints, achievementRank, isMobile, isSoREligible, standingID = GetGuildRosterInfo(i);
		table.insert(l,name)
		--print(name)
	end
	return l
end

local guildMemberList = getGuildMemeberList();




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

				local skip=false

				if(strlen(word)<4) then
					-- since sets in paternmatching is broke AF if you use magic characters we do it by hand 
					local beg,en = string.find(msglow,"[ /]"..string.lower(word))
					local isOK=false
					if strlen(word)<en+1 then 
						isOK= isOK or true -- we are at the end of the string
					end
					if msglow:sub(en+1,en+1) == " " then 
						isOK= isOK or true -- next char is space
					end
					if isOK == false then
						skip=true
					end
				end

				if DEBUG then print("found "..word ) end
				
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
	--print(channelName)
	if(channelName ~= "SucheNachGruppe" and channelName ~= "LookingForGroup" and channelName ~= "lfg" and channelName ~= "") then
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
		local HC_Override=false
		if string.find(msglow," hc") ~= nil then 
			HC_Override=true
		end
		for j,iniObj in ipairs(iniList) do
			local ini = iniObj.kw
			if DEBUG then print("found ini "..ini.words[1]) end
			-- check levels
			local addText=""
			local lvlDiff=99
			local lvlDiffMax=99

			if(ini.lvl and ini.lvl[1]) then
				local lvl = UnitLevel("PLAYER")
				if(ini.lvl[1]-3< lvl and ini.lvl[2]-3>lvl and NS.settings.NotificationSound and not IsInGroup() ) then
					-- if it is my lvl range play sound
					PlaySound(3081,"master")
				end
				if NS.settings.addLevels and not HC_Override then
					addText="("..tostring(ini.lvl[1]).."-"..tostring(ini.lvl[2])..")"
				end
				lvlDiff=ini.lvl[1]-lvl
				lvlDiffMax=ini.lvl[2]-lvl
			end
			--print(row.lvl[1])
			local newWord=NS.functions.colorText(iniObj.w,lvlDiff,lvlDiffMax,HC_Override)..addText;
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
						if NS.settings.addLevels then
							addText="("..tostring(subIni.lvl[1]).."-"..tostring(subIni.lvl[2])..")"
						end

						local newWord=NS.functions.colorText(subIniObj.w,lvlDiff,lvlDiffMax)..addText;
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


	if (NS.functions.tContains(guildMemberList,author)) then 
		--author= author..":G"  -- "|r" .. "|C05".."40ff40"..":G".."|r" 
		msg = "|C05".."40ff40".."G:".."|r" ..  msg
		mod=true
	end
	if mod then
		return false, msg, author, ...
	end
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", myChatFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", myChatFilter)


SLASH_CHATPAINTER1 = "/cp"
SlashCmdList["CHATPAINTER"] = function( msg, ...)
   --print(...)
--    for key,value in ipairs(...) do
-- 	print(value)
--    end

	local a1,a2,a3,a4 = strsplit(" ", msg)

	if a1=="test" then
		DEBUG=true
		local bool,retMsg,auth = myChatFilter(nil, "CHAT_MSG_CHANNEL", msg, "Nobody", "channelStr", "charName", "ukn1","a","b", 4, "SucheNachGruppe" ,"ukn2","unk3" ,"senderGUID", "ukn4", "unk5")
		DEBUG=false	
		print(retMsg)
	elseif a1 =="showLevels" then
		if a2 == "1" or a2 =="true" then
			NS.settings.addLevels=true
		else
			NS.settings.addLevels=false
		end
	elseif a1 =="notify" then

		if a2 == "1" or a2 =="true" then
			NS.settings.NotificationSound=true
		else
			NS.settings.NotificationSound=false
		end
	else
		print("settings: ")
		print("/cp showLevels [0|1]  -- Adds level to the instances in chat")
		print("/cp notify [0|1]  -- plays a notification sound if a insatcne in your lvl range is mentioned")
	end

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


