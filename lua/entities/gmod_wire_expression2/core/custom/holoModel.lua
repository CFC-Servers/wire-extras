local wire_holograms_modelany = CreateConVar("wire_holograms_modelany",0,{FCVAR_ARCHIVE})
registerCallback("postinit",function()
	local wire_holograms_size_max = wire_holograms.wire_holograms_size_max
	local scale_queue = wire_holograms.scale_queue
	local ModelList = wire_holograms.ModelList
	local CheckIndex = wire_holograms.CheckIndex
	local rescale = wire_holograms.rescale
	
	local old_rescale = rescale
	rescale = function( Holo, scale )

		if (Holo.modelany == true) then
				local maxval = wire_holograms_size_max:GetInt() * 12.04
		
				scale = Vector(scale[1],scale[2],scale[3])
				local size = Holo.ent:OBBMaxs()-Holo.ent:OBBMins()
				local cl = math.Clamp
				local vec = Vector(size.x*scale.x,size.y*scale.y,size.z*scale.z)
				
				if (math.abs(vec.x) > maxval) then -- Is the hologram going to be bigger than the maximum allowed size if we scale it now?
					local maxval2 = size.x*maxval -- Get the max allowed multiplier
					scale.x = cl(maxval/size.x,-maxval2,maxval2) -- Clamp it
				end
				
				-- Do the same for Y and Z
				if (math.abs(vec.y) > maxval) then
					local maxval2 = size.y*maxval
					scale.y = cl(maxval/size.y,-maxval2,maxval2)
				end
				if (math.abs(vec.z) > maxval) then
					local maxval2 = size.z*maxval
					scale.z = cl(maxval/size.z,-maxval2,maxval2)
				end
				
				if Holo.scale ~= scale then
					table.insert(scale_queue, { Holo, scale })
					Holo.scale = scale
				end
			return
		end
		
		old_rescale( Holo, scale )
	
	end

	registerFunction("holoModel","ns","",function(self,args) -- Because using e2function didn't work
		local op1, op2 = args[2], args[3]
		local index, model = op1[1](self, op1), op2[1](self, op2)
		local Holo = CheckIndex(self, index)
		if not Holo then return end
		
		if (ModelList[model]) then
			Holo.ent:SetModel( Model( "models/Holograms/"..model..".mdl") )
			Holo.modelany = nil
			return
		end
		
		if (wire_holograms_modelany:GetInt() == 0) then return end
		
		if (!util.IsValidModel( model )) then return end
		Holo.modelany = true
		Holo.ent:SetModel( Model( model ) )
	end)

	registerFunction("holoModel","nsn","",function(self,args)
		local op1, op2, op3 = args[2], args[3], args[4]
		local index, model, skin = op1[1](self, op1), op2[1](self, op2), op3[1](self, op3)
		local Holo = CheckIndex(self, index)
		if not Holo then return end
		
		skin = skin - skin % 1
		Holo.ent:SetSkin(skin)
		
		if (ModelList[model]) then
			Holo.ent:SetModel( Model( "models/Holograms/"..model..".mdl") )
			Holo.modelany = nil
			return
		end
		
		if (wire_holograms_modelany:GetInt() == 0) then return end
		
		if (!util.IsValidModel( model )) then return end
		Holo.modelany = true
		Holo.ent:SetModel( Model( model ) )
	end)
end)