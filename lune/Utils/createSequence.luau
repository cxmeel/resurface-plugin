local DateTime = require("@lune/datetime")
local process = require("@lune/process")

local c = require("./colors")

local generateUuid = require("./generateUuid")
local shortUuid = require("./shortUuid")
local trim = require("./trim")

export type Command = {
	label: string?,
	exec: string | (sessionId: string, args: { string }) -> (),
	args: { string }?,
	when: ((sessionId: string, isFirstRun: boolean) -> boolean)?,
}

local function createSequence(sequenceType: string, sequence: { Command })
	local isFirstRun = true

	local function run()
		local sessionId = generateUuid()

		local now = DateTime.now()
		local formattedTime = now:formatLocalTime("%X")

		local totalTasks = 0
		local tasksRun = 0

		print(
			c.yellow(
				`Running {sequenceType} sequence: {c.bold(shortUuid(sessionId))} ({formattedTime})`
			)
		)

		for _, command in sequence do
			if not command.when or command.when(sessionId, isFirstRun) then
				totalTasks += 1

				local label = command.label or tostring(command.exec)
				local isFunction = typeof(command.exec) == "function"

				local argsStr = trim(table.concat(command.args or {}, " "))
				local noun = isFunction and "function" or "command"

				if command.label then
					print(
						c.blue(`> Running {noun}:`),
						c.blue(c.bold(`{label}:`)),
						c.grey(`"{command.exec}{#argsStr > 0 and ` {argsStr}` or ""}"`)
					)
				else
					print(
						c.blue(`> Running {noun}:`),
						c.grey(`"{label}{#argsStr > 0 and ` {argsStr}` or ""}"`)
					)
				end

				local result

				if isFunction then
					local ok, err = pcall(command.exec :: any, sessionId, command.args)
					result = { ok = ok, stderr = err }
				else
					result = process.spawn(command.exec :: string, command.args)
				end

				if not result.ok then
					error(
						c.red(
							`Failed to run command: "{c.bold(command.exec)}"\n> {result.stderr}}`
						)
					)
				end

				tasksRun += 1
			end
		end

		isFirstRun = false

		return {
			isFirstRun = isFirstRun,
			sessionId = sessionId,
			totalTasks = totalTasks,
			tasksRun = tasksRun,
		}
	end

	return {
		run = run,
	}
end

return createSequence
