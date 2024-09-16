local DateTime = require("@lune/datetime")
local fs = require("@lune/fs")
local process = require("@lune/process")
local serde = require("@lune/serde")
local task = require("@lune/task")

local c = require("./Utils/colors")
local createSequence = require("./Utils/createSequence")
local trim = require("./Utils/trim")
local watch = require("./Utils/fsWatch")

local PROJECT_JSON = serde.decode("json", fs.readFile("build.project.json"))
local REACT_PATH = "Packages/React.lua"

local WATCHED_DIRS = {
	"src",
	"packages",
}

local args = process.args

local isDev = table.find(args, "--dev") ~= nil
local isWatch = table.find(args, "--watch") ~= nil
local isReactDev = table.find(args, "--react-dev") ~= nil
local isNotReactDev = table.find(args, "--no-react-dev") ~= nil
local isSkipInstall = table.find(args, "--skip-packages") ~= nil

if isReactDev and isNotReactDev then
	error("Cannot use both `--react-dev` and `--no-react-dev` flags at the same time")
end

local removedPackages = false
local sequence = createSequence("build", {
	{
		label = "Remove packages directory",
		exec = function()
			fs.removeDir("packages")
			removedPackages = true
		end,
		when = function(_, isFirstRun)
			if isSkipInstall then
				return false
			end

			return isFirstRun and fs.isDir("packages")
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
		label = "Update packages",
		exec = "wally",
		args = { "install" },
		when = function(_, isFirstRun)
			if isSkipInstall then
				return false
			end

			return isFirstRun or (not isDev and not isWatch)
		end,
	},
	{
		label = "Generate sourcemap",
		exec = "rojo",
		args = { "sourcemap", "-o", "sourcemap.json" },
		when = function(_, isFirstRun)
			if isSkipInstall then
				return false
			end

			return isFirstRun or (not isDev and not isWatch)
		end,
	},
	{
		label = "Fix package types",
		exec = "wally-package-types",
		args = { "--sourcemap", "sourcemap.json", "packages" },
		when = function(_, isFirstRun)
			if isSkipInstall then
				return false
			end

			return isFirstRun or (not isDev and not isWatch)
		end,
	},
	{
		label = "Set React dev mode",
		when = function(_, isFirstRun)
			if not isFirstRun or not isReactDev or isSkipInstall then
				return false
			end

			return fs.isFile(REACT_PATH)
		end,
		exec = function()
			local reactContent = fs.readFile(REACT_PATH)

			if reactContent:find("_G.__DEV__%s*=%s*true") then
				return
			end

			reactContent =
				`-- selene: allow(global_usage)\n_G.__DEV__ = true\n\n{reactContent}`
			fs.writeFile(REACT_PATH, reactContent)
		end,
	},
	{
		label = "Force-disable React dev mode",
		when = function(_, isFirstRun)
			if not isFirstRun or not isNotReactDev or isSkipInstall then
				return false
			end

			return fs.isFile(REACT_PATH)
		end,
		exec = function()
			local reactContent = fs.readFile(REACT_PATH)

			if reactContent:find("_G.__DEV__%s*=%s*false") then
				return
			end

			reactContent =
				`-- selene: allow(global_usage)\n_G.__DEV__ = false\n\n{reactContent}`
			fs.writeFile(REACT_PATH, reactContent)
		end,
	},
	{
		label = "Remove build directory",
		exec = function()
			if fs.isDir("build") then
				fs.removeDir("build")
			end
		end,
	},
	{
		label = "Process source files",
		exec = "darklua",
		args = { "process", "src", "build", "-c", "darklua.json" },
	},
	{
		label = "Insert metadata attributes",
		exec = function(sessionId: string)
			local now = DateTime.now()

			local metadataPath = "build/init.meta.json"
			local attributes = {}

			if isDev then
				attributes.BuildSessionId = { String = sessionId }
			end

			local commitHashOp = process.spawn("git", { "rev-parse", "HEAD" })
			local commitHash: string? = commitHashOp.ok and trim(commitHashOp.stdout)
				or nil

			if commitHash and #commitHash > 0 then
				attributes.SourceCommitHash = { String = commitHash }
			end

			attributes.BuildDate = { String = now:formatLocalTime("%Y-%m-%d") }
			attributes.BuildTime = { String = now:formatLocalTime("%X") }

			local encodedMeta = serde.encode("json", {
				properties = {
					Attributes = attributes,
				},
			}, false)

			fs.writeFile(metadataPath, encodedMeta)
		end,
	},
	{
		label = "Clone localization directory",
		when = function()
			return fs.isDir("src/Frontend/Localization")
		end,
		exec = function()
			local hasLocalizationDir = fs.isDir("build/Frontend/Localization")

			for _, file in fs.readDir("src/Frontend/Localization") do
				if not file:match("%.csv$") then
					continue
				end

				if not hasLocalizationDir then
					fs.writeDir("build/Frontend/Localization")
					hasLocalizationDir = true
				end

				fs.copy(
					`src/Frontend/Localization/{file}`,
					`build/Frontend/Localization/{file}`
				)
			end
		end,
	},
	{
		label = "Strip story files",
		exec = function()
			local storyFiles = {}

			local function scanDirectory(path: string)
				for _, file in fs.readDir(path) do
					local fullPath = `{path}/{file}`
					local isDir = fs.isDir(fullPath)

					if isDir then
						scanDirectory(fullPath)
						continue
					end

					if file:match("%.story%.luau?$") then
						table.insert(storyFiles, fullPath)
					end
				end
			end

			scanDirectory("build")

			for _, file in storyFiles do
				fs.removeFile(file)
			end
		end,
		when = function()
			return not isDev
		end,
	},
	{
		label = "Build plugin to plugins directory",
		exec = "rojo",
		args = { "build", "build.project.json", "--plugin", `{PROJECT_JSON.name}.rbxm` },
		when = function()
			return isDev
		end,
	},
	{
		label = "Build plugin to file",
		exec = "rojo",
		args = { "build", "build.project.json", "-o", `{PROJECT_JSON.name}.rbxm` },
		when = function()
			return not isDev
		end,
	},
})

local function main()
	sequence.run()

	if not isWatch then
		return
	end

	local thread: thread?

	for _, dir in WATCHED_DIRS do
		watch(dir, function()
			if thread then
				task.cancel(thread)
			end

			thread = task.spawn(function()
				sequence.run()

				print(
					c.green(
						`\nWaiting for changes. Press {c.bold("CTRL+C")} to stop.\n`
					)
				)
			end)
		end, {
			interval = 2,
		})
	end

	print(c.green(`\nWaiting for changes. Press {c.bold("CTRL+C")} to stop.\n`))
end

main()
