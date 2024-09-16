export type Variant = {
	surfaceType: Enum.SurfaceType,
	colorMap: string,
	normalMap: string,
	studsPerTile: number,
}

return {
	glue = {
		surfaceType = Enum.SurfaceType.Glue,
		colorMap = "rbxassetid://10509635556",
		normalMap = "rbxassetid://10509645465",
		studsPerTile = 1,
	},
	inlet = {
		surfaceType = Enum.SurfaceType.Inlet,
		colorMap = "rbxassetid://10509827175",
		normalMap = "rbxassetid://10509827228",
		studsPerTile = 1,
	},
	stud = {
		surfaceType = Enum.SurfaceType.Studs,
		colorMap = "rbxassetid://10509831729",
		normalMap = "rbxassetid://10509831753",
		studsPerTile = 1,
	},
	universal = {
		surfaceType = Enum.SurfaceType.Universal,
		colorMap = "rbxassetid://10509840768",
		normalMap = "rbxassetid://10509840812",
		studsPerTile = 2,
	},
	weld = {
		surfaceType = Enum.SurfaceType.Weld,
		colorMap = "rbxassetid://10509843977",
		normalMap = "rbxassetid://10509844001",
		studsPerTile = 2,
	},
} :: { [string]: Variant }
