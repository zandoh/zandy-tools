--[[
	Core/ModuleLoader.lua

	Lazy-loading module system
	Handles module lifecycle: Initialize → Enable → Disable → Cleanup
]]

local ADDON_NAME = "ZandyTools"
local ZandyTools = _G[ADDON_NAME]

--[[
	Load all enabled modules
	Called during OnEnable after database is ready
]]
function ZandyTools:LoadEnabledModules()
	self:Debug("Loading enabled modules...")

	local loadedCount = 0

	for _, moduleName in ipairs(self.moduleLoadOrder) do
		if self:IsModuleEnabled(moduleName) then
			local success = self:LoadModule(moduleName)
			if success then
				loadedCount = loadedCount + 1
			end
		end
	end

	if loadedCount > 0 then
		self:Print(string.format("Loaded %d module(s)", loadedCount))
	end
end

--[[
	Load a specific module

	@param moduleName string - Module identifier
	@return boolean - Success status
]]
function ZandyTools:LoadModule(moduleName)
	local module = self:GetModule(moduleName)
	if not module then
		self:Error(string.format("Cannot load unknown module: %s", moduleName))
		return false
	end

	if module.loaded then
		self:Debug(string.format("Module %s is already loaded", moduleName))
		return true
	end

	-- Check dependencies
	if not self:CheckModuleDependencies(moduleName) then
		return false
	end

	self:Debug(string.format("Loading module: %s", moduleName))

	-- Initialize module
	local success, err = self:SafeModuleCall(module, "Initialize")
	if not success then
		self:Error(string.format("Failed to initialize module %s: %s", moduleName, err or "unknown error"))
		return false
	end

	-- Enable module
	success, err = self:SafeModuleCall(module, "Enable")
	if not success then
		self:Error(string.format("Failed to enable module %s: %s", moduleName, err or "unknown error"))
		-- Try to cleanup
		self:SafeModuleCall(module, "Cleanup")
		return false
	end

	-- Mark as loaded
	module.loaded = true
	module.enabled = true

	self:Debug(string.format("Module %s loaded successfully", moduleName))

	-- Send module loaded message
	self:SendMessage("ADDONSUITE_MODULE_LOADED", moduleName)

	return true
end

--[[
	Unload a specific module

	@param moduleName string - Module identifier
	@return boolean - Success status
]]
function ZandyTools:UnloadModule(moduleName)
	local module = self:GetModule(moduleName)
	if not module then
		self:Error(string.format("Cannot unload unknown module: %s", moduleName))
		return false
	end

	if not module.loaded then
		self:Debug(string.format("Module %s is not loaded", moduleName))
		return true
	end

	self:Debug(string.format("Unloading module: %s", moduleName))

	-- Disable module
	local success, err = self:SafeModuleCall(module, "Disable")
	if not success then
		self:Error(string.format("Error disabling module %s: %s", moduleName, err or "unknown error"))
	end

	-- Cleanup module
	success, err = self:SafeModuleCall(module, "Cleanup")
	if not success then
		self:Error(string.format("Error cleaning up module %s: %s", moduleName, err or "unknown error"))
	end

	-- Mark as unloaded
	module.loaded = false
	module.enabled = false

	self:Debug(string.format("Module %s unloaded", moduleName))

	-- Send module unloaded message
	self:SendMessage("ADDONSUITE_MODULE_UNLOADED", moduleName)

	return true
end

--[[
	Reload a specific module

	@param moduleName string - Module identifier
	@return boolean - Success status
]]
function ZandyTools:ReloadModule(moduleName)
	self:Debug(string.format("Reloading module: %s", moduleName))

	self:UnloadModule(moduleName)
	return self:LoadModule(moduleName)
end

--[[
	Reload all modules based on current enabled state
]]
function ZandyTools:ReloadModules()
	self:Debug("Reloading all modules...")

	-- First, disable all loaded modules
	for _, moduleName in ipairs(self.moduleLoadOrder) do
		local module = self.modules[moduleName]
		if module.loaded then
			self:UnloadModule(moduleName)
		end
	end

	-- Then, load all enabled modules
	self:LoadEnabledModules()
end

--[[
	Disable all active modules
	Called during OnDisable
]]
function ZandyTools:DisableAllModules()
	self:Debug("Disabling all modules...")

	for _, moduleName in ipairs(self.moduleLoadOrder) do
		local module = self.modules[moduleName]
		if module.loaded then
			self:UnloadModule(moduleName)
		end
	end
end

--[[
	Check if module dependencies are satisfied

	@param moduleName string - Module identifier
	@return boolean - True if all dependencies are met
]]
function ZandyTools:CheckModuleDependencies(moduleName)
	local module = self:GetModule(moduleName)
	if not module or not module.dependencies then
		return true
	end

	for _, depName in ipairs(module.dependencies) do
		-- Check if dependency module exists
		if not self:HasModule(depName) then
			self:Error(string.format("Module %s requires missing module: %s", moduleName, depName))
			return false
		end

		-- Check if dependency is enabled
		if not self:IsModuleEnabled(depName) then
			self:Error(string.format("Module %s requires module %s to be enabled", moduleName, depName))
			return false
		end

		-- Check if dependency is loaded
		local depModule = self:GetModule(depName)
		if not depModule.loaded then
			-- Try to load dependency first
			if not self:LoadModule(depName) then
				self:Error(string.format("Failed to load dependency %s for module %s", depName, moduleName))
				return false
			end
		end
	end

	return true
end

--[[
	Safely call a module lifecycle function

	@param module table - Module object
	@param functionName string - Function name to call
	@return boolean, string - Success status and error message if any
]]
function ZandyTools:SafeModuleCall(module, functionName)
	if not module[functionName] or type(module[functionName]) ~= "function" then
		-- Function doesn't exist, that's okay for optional functions
		return true
	end

	local success, err = pcall(module[functionName], module)
	return success, err
end

--[[
	Setup default configuration for modules
	Called during OnInitialize
]]
function ZandyTools:SetupDefaultConfig()
	-- This is called before modules are registered
	-- Default config will be set up when modules register
end

--[[
	Get module load order
	Useful for debugging

	@return table - Array of module names in load order
]]
function ZandyTools:GetModuleLoadOrder()
	return self.moduleLoadOrder
end

--[[
	Get loaded modules count

	@return number - Count of currently loaded modules
]]
function ZandyTools:GetLoadedModulesCount()
	local count = 0
	for _, moduleName in ipairs(self.moduleLoadOrder) do
		if self.modules[moduleName].loaded then
			count = count + 1
		end
	end
	return count
end

--[[
	Get enabled modules count

	@return number - Count of enabled modules (may not be loaded yet)
]]
function ZandyTools:GetEnabledModulesCount()
	local count = 0
	for _, moduleName in ipairs(self.moduleLoadOrder) do
		if self:IsModuleEnabled(moduleName) then
			count = count + 1
		end
	end
	return count
end
