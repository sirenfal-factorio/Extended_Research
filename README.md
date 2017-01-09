# What does this mod do?

This mod extends most vanilla research (worker cargo speed, worker cargo size, gun speed, etc) to have 20 tiers. Prices increase on a quadratic curve up to 25,000 on the final tier of each upgrade.

The prices were chosen to be reachable in a reasonable amount of time, but expensive enough to take a fair amount of time. Selectively choosing what you want is encouraged, rather than trying to max everything.

# (For developers) How do I add a new research tier?

Simply copy one of the existing blocks in data.lua and edit as you like. The parameters are:

- Internal name of existing vanilla upgrade
- Total number of tiers desired
- Cost of final tier
- A function which takes
    - An absolute index, which goes from 1 to the final tier (20 in this case).
    - The added index, which is from 1 to the number of tiers added (1 to highest research tier - number of vanilla research tiers).
    - This function should return a table which will override the specified values in a normal research prototype, calculated based off of index, added_index (may be static values if desired).

The add_research_tiers function will automatically take care of setting requirements, copy the image from the highest vanilla research tier, etc.

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