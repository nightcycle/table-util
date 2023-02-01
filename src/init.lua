--!strict
--Services
--Packages
--Modules
--Types
--Constants

--Class
local Util = {}

export type Table = {[any]: any}
export type Dict<K, V> = {[K]: V}
export type List<V> = {[number]: V}

function Util.deepCopy(read: Table, log: {[Table]: Table}?): Table
	log = log or {}
	assert(log ~= nil)

	if log[read] then
		return log[read]
	else
		local out = {}
		log[read] = out
	
		for k, v in pairs(read) do
			if type(v) == "table" then
				out[k] = Util.deepCopy(v, log)
			else
				out[k] = v
			end
		end
	
		return out
	end
end

function Util.deduplicate<V>(list: List<V>): List<V>
	local registry = {}
	for i, v in ipairs(list) do
		registry[v] = true
	end
	local out = {}
	for v, _ in pairs(registry) do
		table.insert(out, v)
	end
	return out
end

function Util.keys<K>(dict: Dict<K, any>): List<K>
	local list = {}
	for k, v in pairs(dict) do
		table.insert(list, k)
	end
	return Util.deduplicate(list)
end

function Util.values<V>(dict: Dict<any, V>): List<V>
	local list = {}
	for k, v in pairs(dict) do
		table.insert(list, v)
	end
	return Util.deduplicate(list)
end

function Util.reverse<V>(list: List<V>): List<V>
	local out = {}

	for i=#list, 1, -1 do
		table.insert(out, list[i])
	end

	return out
end

function Util.combine(a: Table, b: Table): Table
	local out = {}
	for k, v in pairs(a) do
		out[k] = v
	end
	for k, v in pairs(b) do
		out[k] = v
	end
	return out
end

return Util
