local WallyManifest = require(script.Parent.WallyPackageManifest) :: WallyManifest

type WallyManifest = {
	package: {
		name: string,
		realm: string,
		registry: string,
		version: string,
	},
	dependencies: {
		[string]: string,
	},
	product: {
		description: string,
		display_name: string,
	},
}

return WallyManifest
