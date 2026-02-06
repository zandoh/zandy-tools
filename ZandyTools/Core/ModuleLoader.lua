--[[
	Core/ModuleLoader.lua

	True lazy-loading module system using LoadOnDemand addons.
	Modules are separate addons loaded via C_AddOns.LoadAddOn()
]]

local ADDON_NAME = "ZandyTools"
local ZandyTools = _G[ADDON_NAME]

--[[
	Load all enabled modules
	Called during OnEnable after database is ready
]]
function ZandyTools:LoadEnabledModules()
	for moduleName, _ in pairs(self.moduleRegistry) do
		if self:IsModuleEnabled(moduleName) then
			self:LoadModule(moduleName)
		end
	end
end

--[[
	Load a specific module addon

	@param moduleName string - Module identifier
	@return boolean - Success status
]]
function ZandyTools:LoadModule(moduleName)
	local registry = self.moduleRegistry[moduleName]
	if not registry then
		self:Error(string.format("Unknown module: %s", moduleName))
		return false
	end

	-- Check if already loaded
	if self.loadedModules[moduleName] then
		return true
	end

	local addonName = registry.addonName

	-- Check if addon exists
	local exists = C_AddOns.DoesAddOnExist(addonName)
	if not exists then
		self:Error(string.format("Module addon not found: %s", addonName))
		return false
	end

	-- Load the addon
	local loaded, reason = C_AddOns.LoadAddOn(addonName)
	if not loaded then
		self:Error(string.format("Failed to load %s: %s", addonName, reason or "unknown"))
		return false
	end

	self.loadedModules[moduleName] = true

	-- Initialize the module if it registered itself
	local module = self.modules[moduleName]
	if module then
		self:InitializeModule(moduleName)
	end

	return true
end

--[[
	Initialize a loaded module

	@param moduleName string - Module identifier
]]
function ZandyTools:InitializeModule(moduleName)
	local module = self.modules[moduleName]
	if not module then return end

	if module.initialized then return end

	-- Call Initialize
	if module.Initialize then
		local success, err = pcall(module.Initialize, module)
		if not success then
			self:Error(string.format("Failed to initialize %s: %s", moduleName, err))
			return
		end
	end

	-- Call Enable
	if module.Enable then
		local success, err = pcall(module.Enable, module)
		if not success then
			self:Error(string.format("Failed to enable %s: %s", moduleName, err))
			return
		end
	end

	module.initialized = true
	module.enabled = true
end

--[[
	Unload/disable a module

	@param moduleName string - Module identifier
]]
function ZandyTools:UnloadModule(moduleName)
	local module = self.modules[moduleName]
	if not module or not module.initialized then return end

	if module.Disable then
		pcall(module.Disable, module)
	end

	module.initialized = false
	module.enabled = false
end


--[[
	Register a module (called by module addons when they load)

	@param moduleName string - Module identifier
	@param moduleTable table - Module implementation
]]
function ZandyTools:RegisterModule(moduleName, moduleTable)
	if self.modules[moduleName] then
		return self.modules[moduleName]
	end

	local registry = self.moduleRegistry[moduleName]
	if registry then
		moduleTable.displayName = moduleTable.displayName or registry.displayName
		moduleTable.description = moduleTable.description or registry.description
	end

	moduleTable.name = moduleName
	moduleTable.initialized = false
	moduleTable.enabled = false

	self.modules[moduleName] = moduleTable

	-- If this module is enabled, initialize it now
	if self:IsModuleEnabled(moduleName) then
		self:InitializeModule(moduleName)
	end

	return moduleTable
end


--[[
	Register an event for a module

	@param module table - Module object
	@param event string - Event name
	@param callback string - Callback function name
]]
function ZandyTools.RegisterEvent(module, event, callback)
	if not module._eventFrame then
		module._eventFrame = CreateFrame("Frame")
		module._eventFrame._handlers = {}
		module._eventFrame:SetScript("OnEvent", function(self, event, ...)
			local handler = self._handlers[event]
			if handler then
				handler(module, event, ...)
			end
		end)
	end

	module._eventFrame._handlers[event] = module[callback]
	module._eventFrame:RegisterEvent(event)
end

--[[
	Unregister all events for a module

	@param module table - Module object
]]
function ZandyTools.UnregisterAllEvents(module)
	if module._eventFrame then
		module._eventFrame:UnregisterAllEvents()
		module._eventFrame._handlers = {}
	end
end
