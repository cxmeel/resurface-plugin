local fs = require("@lune/fs")

local c = require("./Utils/colors")
local createSequence = require("./Utils/createSequence")

type Command = {
	label: string?,
	exec: string | (sessionId: string, args: { string }) -> (),
	args: { string }?,
	when: ((sessionId: string) -> boolean)?,
}

local removedPackages = false
local sequence = createSequence("install", {
	{
		label = "Remove packages directory",
		exec = function()
			if fs.isDir("packages") then
				fs.removeDir("packages")
				removedPackages = true
			end
		end,
	},
	{
		label = "Generate sourcemap",
		exec = "rojo",
		args = { "sourcemap", "-o", "sourcemap.json" },
		when = function()
			return removedPackages
		end,
	},
	{
		label = "Install packages",
		exec = "wally",
		args = { "install" },
	},
	{
		label = "Generate sourcemap",
		exec = "rojo",
		args = { "sourcemap", "-o", "sourcemap.json" },
	},
	{
		label = "Fix package types",
		exec = "wally-package-types",
		args = { "--sourcemap", "sourcemap.json", "packages" },
	},
})

local result = sequence.run()
print(c.green(`Completed {c.bold(result.tasksRun)} tasks successfully`))
