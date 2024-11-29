--!strict
--!native
--Services
--Packages
--Modules
--Types
--Constants

--Class
local Util = {}

export type Table = { [any]: any }
export type Dict<K, V> = { [K]: V }
export type List<V> = { [number]: V }

function Util.deepCopy(read: Table, log: { [Table]: Table }?): Table
	log = log or {}
	assert(log ~= nil)

	if log[read] then
		return log[read]
	else
		local out = table.clone(read)
		log[read] = out

		for k, v in pairs(out) do
			if typeof(v) == "table" then
				out[k] = Util.deepCopy(v, log)
			end
		end

		return out
	end
end

function Util.map<K, IV, OV>(source: Dict<K, IV>, method: (K, IV) -> OV): Dict<K, OV>
	local out: Dict<K, OV> = {}

	for k, v in pairs(source) do
		out[k] = method(k, v)
	end

	return out
end

function Util.randomize<V>(list: List<V>, seed: number?): ()
	local rng = Random.new(seed or tick())
	local scores = {}
	for i, v in ipairs(list) do
		scores[v] = rng:NextNumber()
	end

	table.sort(list, function(a: V, b: V)
		return scores[a] < scores[b]
	end)
end

function Util.deduplicate<V>(list: List<V>): ()
	if #list <= 1 then
		return
	end
	local registry: { [V]: true? } = {}
	local i = 1
	repeat
		local v = list[i]
		if not registry[v] then
			registry[v] = true
			i += 1
		else
			table.remove(list, i)
		end
	until i > #list
end

function Util.keys<K>(dict: Dict<K, any>): List<K>
	local list = {}
	for k, v in pairs(dict) do
		table.insert(list, k)
	end
	return list
end

function Util.values<V>(dict: Dict<any, V>): List<V>
	local list = {}
	for k, v in pairs(dict) do
		table.insert(list, v)
	end
	return list
end

function Util.reverse<V>(list: List<V>): ()
	local holder = {}
	for i = #list, 1, -1 do
		table.insert(holder, list[i])
	end

	table.clear(list)
	for i, v in ipairs(holder) do
		list[i] = v
	end
end

function Util.merge<K, V>(a: Dict<K, V>, b: Dict<K, V>): Dict<K, V>
	local out = table.clone(a)
	for k, v in pairs(b) do
		out[k] = v
	end
	return out
end

function Util.append<V>(target: List<V>, add: List<V>): ()
	for i, v in ipairs(add) do
		table.insert(target, v)
	end
end

return Util
