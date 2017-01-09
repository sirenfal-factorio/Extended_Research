require('ir_util')

-- tech is the name of a tech (e.g. 'gun-turret-damage')
-- tiers is how many tiers you want
-- final_resource_count is the cost of the last research in this tree
-- mod_func is a callable that takes (absolute_index, added_index) where absolute_index is
-- the index from 1 to the highest research tier (including vanilla research at the beginning), and
-- added_index is the index from 1 to to (highest research tier - number of vanilla researches)
-- mod_func should return overwrites for the clone_existing_data function (generally the effects={} table)
local function add_research_tiers(tech_name, tiers, final_resource_count, mod_func)
	local base_tech = nil
	local highest = nil
	local escaped_tech_name = string.gsub(tech_name, "([^%w])", "%%%1")
	local pattern = string.format('^%s%%-(%%d+)$', escaped_tech_name)

	-- find the highest level of this tech to base everything else off of (icon, etc)
	for _, raw_tech in pairs(data.raw.technology) do
		-- lua only has psuedo-regex with very limited power (see http://lua-users.org/wiki/PatternsTutorial)
		if(raw_tech.name == tech_name) then
			if(highest == nil) then
				base_tech = raw_tech
				highest = 1
			end
		else
			local m = string.match(raw_tech.name, pattern)
			
			if(m ~= nil) then
				m = tonumber(m)

				if(highest == nil or m > highest) then
					base_tech = raw_tech
					highest = m
				end
			end
		end
	end

	local add_tiers = tiers - highest

	if(add_tiers <= 0) then
		error(string.format('Tech "%s" already has at least %d tiers', tech_name, tiers))
	end

	-- we get one extra to start costs off at the existing value
	local costs = quadratrix(base_tech.unit.count, final_resource_count, add_tiers+1)
	local added = 1

	for i=1, add_tiers do
		local replace = mod_func(i+highest, i)
		local prev = i+highest-1

		if(prev ~= 1) then
			prev = string.format('%s-%d', tech_name, prev)
		else
			prev = tech_name
		end

		replace = clone_existing_data(replace, {
			['__partial__'] = true,
			['name'] = string.format('%s-%d', tech_name, i+highest),
			['prerequisites'] = {prev},
			['unit'] = {
				count = costs[i+1],
				time = 15,
			},
		})
		-- unit should always be partial when cloning onto the tech tree
		replace['unit']['__partial__'] = true

		local add = {clone_existing_data(base_tech, replace)}

		data:extend(add)
	end
end

-----------------------

add_research_tiers('gun-turret-damage', 20, 25000, function(index, added_index)
	return {
		effects = {
			{
				type = "turret-attack",
				turret_id = "gun-turret",
				modifier = 0.25, --+ (0.1 * added_index),
			}
		},
	}
end)

add_research_tiers('bullet-damage', 20, 25000, function(index, added_index)
	return {
		effects = {
			{
				type = "ammo-damage",
				ammo_category = "bullet",
				modifier = 0.35,
			}
		},
	}
end)

add_research_tiers('bullet-speed', 20, 25000, function(index, added_index)
	return {
		effects = {
			{
				type = "gun-speed",
				ammo_category = "bullet",
				modifier = 0.3,
			}
		},
	}
end)

add_research_tiers('laser-turret-damage', 20, 25000, function(index, added_index)
	return {
		effects = {
			{
				type = "ammo-damage",
				ammo_category = "laser-turret",
				modifier = 0.3,
			}
		},
	}
end)

add_research_tiers('laser-turret-speed', 20, 25000, function(index, added_index)
	return {
		effects = {
			{
				type = "gun-speed",
				ammo_category = "laser-turret",
				modifier = 0.3,
			}
		},
	}
end)

add_research_tiers('combat-robot-damage', 20, 25000, function(index, added_index)
	return {
		effects = {
			{
				type = "ammo-damage",
				ammo_category = "combat-robot-laser",
				modifier = 0.3,
			},
			{
				type = "ammo-damage",
				ammo_category = "combat-robot-beam",
				modifier = 0.3,
			},
		},
	}
end)

add_research_tiers('worker-robots-speed', 20, 25000, function(index, added_index)
	return {
		effects = {
			{
				type = "worker-robot-speed",
				modifier = 0.5,
			}
		},
	}
end)

add_research_tiers('worker-robots-storage', 20, 25000, function(index, added_index)
	if(index <= 10) then
		modifierLevel = 2
	elseif(index <= 15) then
		modifierLevel = 3
	elseif(index <= 20) then
		modifierLevel = 4
	else
		error('wat')
	end

	return {
		effects = {
			{
				type = "worker-robot-storage",
				modifier = modifierLevel,
			}
		},
	}
end)

add_research_tiers('shotgun-shell-damage', 20, 25000, function(index, added_index)
	return {
		effects = {
			{
				type = "ammo-damage",
				ammo_category = "shotgun-shell",
				modifier = 0.3,
			}
		},
	}
end)

add_research_tiers('shotgun-shell-speed', 20, 25000, function(index, added_index)
	return {
		effects = {
			{
				type = "gun-speed",
				ammo_category = "shotgun-shell",
				modifier = 0.25,
			}
		},
	}
end)

add_research_tiers('flamethrower-damage', 20, 25000, function(index, added_index)
	return {
		effects = {
			{
				type = "ammo-damage",
				ammo_category = "flame-thrower",
				modifier = 0.35,
			},
			{
				type = "turret-attack",
				turret_id = "flamethrower-turret",
				modifier = 0.35,
			}
		},
	}
end)

add_research_tiers('grenade-damage', 20, 25000, function(index, added_index)
	return {
		effects = {
			{
				type = "ammo-damage",
				ammo_category = "grenade",
				modifier = 0.2,
			}
		},
	}
end)

add_research_tiers('rocket-damage', 20, 25000, function(index, added_index)
	return {
		effects = {
			{
				type = "ammo-damage",
				ammo_category = "rocket",
				modifier = 0.2,
			}
		},
	}
end)

add_research_tiers('rocket-speed', 20, 25000, function(index, added_index)
	return {
		effects = {
			{
				type = "gun-speed",
				ammo_category = "rocket",
				modifier = 0.4,
			}
		},
	}
end)

add_research_tiers('research-speed', 20, 25000, function(index, added_index)
	return {
		effects = {
			{
				type = "laboratory-speed",
				modifier = 0.5 + (0.1 * index),
			}
		},
	}
end)