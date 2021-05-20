
M_ChatPainter={}
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
M_ChatPainter.arraySortByLen=arraySortByLen




local iconKeywords={
	{watch=true, texture="Interface\\Icons\\ability_warrior_shieldwall",color="5c98f2", words={"tank","Tank"}},
	{watch=false, texture="Interface\\Icons\\Ability_ghoulfrenzy",color="f25f5c", words={"dd"}},
	{watch=false, texture="Interface\\Icons\\Spell_nature_healingtouch",color="1cd96b", words={"heal","heiler"}} -- "heal" all lower must be first because of texture name
}
local iniKeywords={
	{ words={"rfc","RFK"}, lvl = {13,18}},
	{ words={"dm","Todesminen","Todesmine","Deathmines"}, lvl = {17,26}, blacklist={"Nord","West","Ost"}},
	{ words={"höllen des wehklagens","hdw"}, lvl = {17,24}},
	{ words={"burg schattenfang","bsf","bft"}, lvl = {20,32}},
	{ words={"Verlies","Verlis"}, lvl = {24,32}},
	{ words={"Bfd","Tsg","Tiefschwarze Grotte","Blackfathom Tiefe"}, lvl = {24,32}},
	{ words={"Gnome","Gnomeregan"}, lvl = {29,38}},
	{ words={"RFK","Kral"}, lvl = {29,38}},
	{ words={"RFH","Hügel"}, lvl = {37,46}},
	{ words={"Kloster"}, lvl = {34,45}, subIni={1,2,3,4}},
	{ words={"Ulda","Uldaman"}, lvl = {41,51}},
	{ words={"ZF","Zul","Zul´Farrak","Zul Farrak"} , lvl = {42,46}},
	{ words={"Maraudon","Mara"}, lvl = {46,55}},
	{ words={"Tempel"}, lvl = {50,56}},
	{ words={"BRD","brd"}, lvl = {52,60}},
	{ words={"Lbrs","lbrs"}, lvl = {52,60}},
	{ words={"UBRS","Ubrs"}, lvl = {52,60}},
	{ words={"Strath","Strat","stratholme","Staht"}, lvl = {58,60}},
	{ words={"scholo","Scholomance"}, lvl = {58,60}},

	----- BC 
	{ words={"bollwerk","hfb"}, lvl = {58,62}},
	{ words={"blutkessel","bk"}, lvl = {61,63}},
	{ words={"sklaven","slavepen","sklavenunterkünfte"}, lvl = {62,64}},
	{ words={"tiefensumpf"}, lvl = {63,65}},
	{ words={"mana","managruft"}, lvl = {64,66}},
	{ words={"auchenai","ak"}, lvl = {65,67}},
	{ words={"vdah","hdz1"}, lvl = {66,68}},
	{ words={"sethekkhallen"}, lvl = {67,68}},
	{ words={"schattenlabyrinth","schlabbi"}, lvl = {67,75}},
	{ words={"dampfkammer","dk"}, lvl = {67,75}},
	{ words={"zerschmetterten hallen","hallen"}, lvl = {67,75}},
	{ words={"mechanar","mecha"}, lvl = {67,75}},
	{ words={"botanika","bota"}, lvl = {67,75}},
	{ words={"arkatraz"}, lvl = {67,75}},
	{ words={"schwarze morast","morast","hdz2"}, lvl = {67,75}},
	{ words={"terrasse der magister","tdm"}, lvl = {67,75}},
}

local iniSubinstances={}
iniSubinstances[1]={ words={"Friedhof","fh"}, lvl = {26,36}}
iniSubinstances[2]={ words={"Bibliothek","bib","bibi"}, lvl = {29,39}}
iniSubinstances[3]={ words={"Waffenkammer","wk"}, lvl = {35,45}}
iniSubinstances[4]={ words={"Kathedrale","kat","kath","kathe"}, lvl = {35,45}}

for i,row in ipairs(iniKeywords) do
	M_ChatPainter.arraySortByLen(row.words)
end

for i,row in ipairs(iniSubinstances) do
	M_ChatPainter.arraySortByLen(row.words)
end
for i,row in ipairs(iconKeywords) do
	M_ChatPainter.arraySortByLen(row.words)
end

M_ChatPainter.iconKeywords=iconKeywords
M_ChatPainter.iniKeywords=iniKeywords
M_ChatPainter.iniSubinstances=iniSubinstances