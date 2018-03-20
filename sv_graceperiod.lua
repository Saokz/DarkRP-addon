util.AddNetworkString( 'Timer Start Message' ) 
util.AddNetworkString( 'Timer Destroy Message' )

Weapons = {}

function protect(ply)

	if ply:GetNWInt("justdied") == 1 then
		return false
	end

end

function sendNetMessage(ply, netstring, message)

	net.Start( netstring )
	net.WriteString( message )
	net.Send( ply )

end

function giveWeapons(ply)

	for k,v in pairs(Weapons) do

		if ply:SteamID() == v[1] then

			ply:Give(v[2])

		end

	end

end

function clearPlayerWeapons(ply)

	for i=0, table.Count(Weapons) do

		for k,v in pairs(Weapons) do

			if ply:SteamID() == v[1] then

				table.remove(Weapons, k)

			end

		end

	end

end

function initGracePeriod(ply)

	if (ply:GetNWInt("justdied") == 1) then

		sendNetMessage(ply, 'Timer Start Message', "You are under spawn protection. Any guns you pick up will be stored in your inventory and given back when the protection is disabled. Press F2 to disable.")

		timer.Create("NLRTimer_"..ply:SteamID(), 1, ply:GetNWInt("time"), function()

			if (ply:GetNWInt("PressedF2") == 1) then
				--Here's where I would give the player his weapons back.
				--Again haven't figured that out yet.

				/**
					I FIGURED IT OUT FUCK YEAH! FUCK THAT PREVIOUS COMMENT I FUCKING DID IT
				**/
				giveWeapons(ply)
				sendNetMessage(ply, 'Timer Destroy Message', "Your spawn protection has ended.")
				ply:SetNWInt("justdied", 0)
				ply:SetNWInt("PressedF2", 0)
				ply:SetCustomCollisionCheck(false)
				clearPlayerWeapons(ply)
				timer.Destroy("NLRTimer_"..ply:SteamID())

			end

			if (ply:GetNWInt("time") == 1) then

				sendNetMessage(ply, 'Timer Destroy Message', "Your spawn protection has ended.")
				giveWeapons(ply)
				ply:SetNWInt("justdied", 0)
				ply:SetCustomCollisionCheck(false)
				clearPlayerWeapons(ply)
				hook.Call("PlayerShouldTakeDamage", true)

			end

			ply:SetNWInt("time", ply:GetNWInt("time") - 1)

		end)

	end

end


hook.Add("PlayerSpawn", "Grace Period", initGracePeriod)

hook.Add("PlayerShouldTakeDamage", "Protect", protect)

hook.Add("ShouldCollide", "Ghost Player", function(ent1, ent2)

	if ent1:IsPlayer() and ent2:IsPlayer() then

		if ent1:GetNWInt("justdied") == 1 or ent2:GetNWInt("justdied") == 1 then

			return false

		else

			return true

		end

	end

end)

hook.Add("PlayerDeath", "NLR", function(ply)
	ply:SetNWInt("justdied", 1)
	ply:SetNWInt("time", 130)
	ply:SetCustomCollisionCheck(true)
end)

hook.Add("ShowTeam", "Player Pressed F2", function(ply)

	if (ply:GetNWInt("justdied") == 1) then
		if (ply:GetNWInt("PressedF2") == 1) then
			ply:SetNWInt("PressedF2", 0)
		elseif(ply:GetNWInt("PressedF2") == 0) then
			ply:SetNWInt("PressedF2", 1)
		end
	end

end)

hook.Add("WeaponEquip", "StripWeapon", function(weapon)

	timer.Simple(0, function() 
 		local ply = weapon:GetOwner()

 		if (ply:GetNWInt("justdied") == 1) then

 			local wep = weapon:GetClass()
 			table.insert(Weapons, {ply:SteamID(), wep})
			ply:StripWeapons()

 		end
		
	end)

end)