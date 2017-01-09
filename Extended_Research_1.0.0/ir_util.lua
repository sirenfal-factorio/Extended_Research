require('util')

function ms_to_ticks(ms)
	return math.ceil(ms / (1000 / 60))
end

local function _clone_onto(source, override, partial)
	local partial = partial or false

	if(override['__partial__'] ~= nil) then
		partial = true
		override['__partial__'] = nil
	else
		return override
	end

	-- TODO: handle numeric-only arrays specially here (merge properly if partial)

	for k,v in pairs(override) do
		if(source[k] ~= nil and type(source[k]) == 'table') then
			source[k] = _clone_onto(source[k], v, true)
		else
			-- __partial__ will leak for tables here, but who cares?
			source[k] = v
		end
	end

	return source
end

-- each key will fully replace that key unless __partial__ is in the table, in which case
-- it will be merged with any keys from this table replacing keys in the source table
-- partial true/false is recursive after each occurence
function clone_existing_data(entry, data)
	if(entry == nil) then
		error('Tried to clone non-existant data key')
	end

	local new = table.deepcopy(entry)
	local partial = data['__partial__'] ~= nil
	data['__partial__'] = true

	return _clone_onto(new, data, partial)
end

-- thanks ecx
function quadratrix(start, final, count)
	if(not (final > start)) then
		error('Final must be higher than start')
	end

	local ret = {start}
	local multiplier = (final - start) / ((count - 1) ^ 2)

	for i=2, count-1 do 
		table.insert(ret, math.floor(multiplier * ((i-1) ^ 2) + start))
	end

	table.insert(ret, final)

	return ret
end