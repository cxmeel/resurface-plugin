local DateTime = require("@lune/datetime")
local fs = require("@lune/fs")
local process = require("@lune/process")
local task = require("@lune/task")

local DEFAULT_POLL_INTERVAL = 5
local SESSION_START = DateTime.now()

local function powershellGetLastModified(dir: string?)
	if not dir or not fs.isDir(dir) then
		return 0
	end

	local dirModifiedAt = (fs.metadata(dir).modifiedAt or SESSION_START) :: any
	local lastModified = dirModifiedAt.unixTimestamp

	local result = process.spawn("powershell", {
		"-Command",
		`Get-ChildItem -Recurse -Path {dir} | Sort-Object LastWriteTime -Descending | Select-Object -First 1 | Get-Date -UFormat %s -Millisecond 0`,
	})

	if result.ok then
		local psLastModified = tonumber(result.stdout)

		if psLastModified and psLastModified > lastModified then
			lastModified = psLastModified
		end
	end

	return lastModified
end

local function watch(
	path: string?,
	callback: () -> (),
	config: {
		interval: number?,
	}?
)
	local interval = config and config.interval or DEFAULT_POLL_INTERVAL

	local lastModified = powershellGetLastModified(path)
	local thread: thread

	thread = task.spawn(function()
		while true do
			task.wait(interval)

			if not path or not fs.isDir(path) then
				if thread then
					task.cancel(thread)
				end

				return
			end

			local modifiedAt = powershellGetLastModified(path)

			if modifiedAt ~= lastModified then
				lastModified = modifiedAt
				callback()
			end
		end
	end)

	return function()
		if thread then
			task.cancel(thread)
		end
	end
end

return watch
