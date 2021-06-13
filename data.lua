
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
	{watch=true, texture="Interface\\Icons\\ability_warrior_shieldwall",color="5c98f2", words={"tank"}},
	{watch=false, texture="Interface\\Icons\\Ability_ghoulfrenzy",color="f25f5c", words={"dd","dps"}},
	{watch=false, texture="Interface\\Icons\\Spell_nature_healingtouch",color="1cd96b", words={"heal","healer","heiler"}} -- "heal" all lower must be first because of texture name
}
local iniKeywords={
	{ words={"rfc","RFK","flammenschlund"}, lvl = {13,16}},
	{ words={"dm","Todesminen","Todesmine","Deathmines"}, lvl = {18,22}, blacklist={"Nord","West","Ost"}},
	{ words={"höllen des wehklagens","hdw"}, lvl = {17,21}},
	{ words={"burg schattenfang","bsf","bft"}, lvl = {18,21}},
	{ words={"Verlies","Verlis"}, lvl = {23,29}},
	{ words={"bfd","tsg","Tiefschwarze Grotte","Blackfathom Tiefe"}, lvl = {22,24}},
	{ words={"Gnome","Gnomeregan"}, lvl = {25,28}},
	{ words={"RFK","Kral"}, lvl = {24,27}},
	{ words={"RFH","Hügel"}, lvl = {34,37}},
	{ words={"Kloster"}, lvl = {30,40}, subIni={1,2,3,4}},
	{ words={"Ulda","Uldaman"}, lvl = {36,40}},
	{ words={"ZF","Zul","Zul´Farrak","Zul Farrak"} , lvl = {42,46}},
	{ words={"Maraudon","Mara"}, lvl = {43,48}},
	{ words={"Tempel"}, lvl = {47,50}},
	{ words={"BRD","brd"}, lvl = {48,56}},
	{ words={"Lbrs","lbrs"}, lvl = {54,60}},
	{ words={"UBRS","Ubrs"}, lvl = {58,60}},
	{ words={"Strath","Strat","stratholme","Staht"}, lvl = {58,60}},
	{ words={"scholo","Scholomance"}, lvl = {58,60}},

	----- BC 
	{ words={"bollwerk","hfb","bw"}, lvl = {58,62}},
	{ words={"blutkessel","bk"}, lvl = {61,63}},
	{ words={"sklaven","slavepen","sklavenunterkünfte","slave pens","slave"}, lvl = {62,64}},
	{ words={"tiefensumpf","ts","underbog","Sumpf","tiefen"}, lvl = {63,65}},
	{ words={"mana","managruft"}, lvl = {64,66}},
	{ words={"auchenai","krypta","crypts"}, lvl = {65,67}},
	{ words={"sethekkhallen","sethek"}, lvl = {67,68}},
	{ words={"schattenlabyrinth","schlabbi","schattenlabby","sl","schlabby","schattenlaby"}, lvl = {67,75}},
	{ words={"dampfkammer","dk"}, lvl = {67,75}},
	{ words={"zerschmetterten hallen","hallen"}, lvl = {67,75}},
	{ words={"mechanar","mecha"}, lvl = {67,75}},
	{ words={"botanika","bota"}, lvl = {67,75}},
	{ words={"arkatraz"}, lvl = {67,75}},
	{ words={"vdah","hilfsbrad","hdz1","hdz 1"}, lvl = {66,68}},
	{ words={"schwarze morast","morast","hdz2","hdz 2"}, lvl = {67,75}},
	{ words={"terrasse der magister","tdm"}, lvl = {67,75}},
}

local iniSubinstances={}
iniSubinstances[1]={ words={"Friedhof","fh"}, lvl = {30,32}}
iniSubinstances[2]={ words={"Bibliothek","bib","bibi"}, lvl = {33,35}}
iniSubinstances[3]={ words={"Waffenkammer","wk"}, lvl = {35,37}}
iniSubinstances[4]={ words={"Kathedrale","kat","kath","kathe"}, lvl = {36,40}}

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