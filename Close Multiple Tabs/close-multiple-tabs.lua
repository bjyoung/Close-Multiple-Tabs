-- Number of loops before script errors out
local MAX_NUM_LOOPS = 2000

-- Config options END

local debugMode = true

-- TabData class
TabData = {sprite = nil, frameNum = 0}

function TabData:new(o, sprite, frameNum)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.sprite = sprite or nil
  self.frameNum = frameNum or 0
  return o
end

function TabData:equals(otherTabData)
  return self.sprite == otherTabData.sprite and self.frameNum == otherTabData.frameNum
end
-- TabData class END

local function printError(error)
  if debugMode then
    print(error)
  end
end

local function round(num)
  return tonumber(string.format("%.4f", num))
end

-- Get how much time passed since the script started running
-- StartClock must be initialized
local function getElapsedTime()
  if StartClock == nil then
    print("StartClock is not initialized")
    return nil
  end

  local endClock = os.clock()
  local runTime = round(endClock - StartClock)
  return runTime
end

local function getCurrentTabData()
  -- If on home page, then return nil
  if app.sprite == nil then
    return nil
  end

  return TabData:new{nil, sprite = app.sprite, frameNum = app.frame.frameNumber}
end

-- Create dummy frame at the end of the current active frame group and make it active
local function switchToDummyFrame()
  -- If on home page, there is no active frame so nothing can be done
  if app.sprite == nil then
    return
  end

  app.command.GotoLastFrame()
  app.command.NewFrame()
end

-- If the current tab matches the target tab, then removes the dummy frame and switches to the original active frame number
local function cleanUpDummyFrame(targetTabData, originalFrameNumber)
  local currTabData = getCurrentTabData()

  if not currTabData:equals(targetTabData) then
    return
  end

  app.command.RemoveFrame()
  app.frame = originalFrameNumber
end

-- Determines if the current tab can be closed or not
-- Home page can be closed
-- Any tab that doesn't match the original tab can be closed
local function atCloseableTab(origTabData)
  return app.sprite == nil or (not getCurrentTabData():equals(origTabData))
end

-- Close tabs until the original given tab is reached
-- Returns true if successful, false if an error occurred
local function closeTabsUntilOriginal(originalTabData)
  local loopNum = 0

  while atCloseableTab(originalTabData) do
    loopNum = loopNum + 1

    if loopNum >= MAX_NUM_LOOPS then
      printError("Max num loops exceeded")
      return false
    end
    
    app.command.CloseFile()
  end

  return true
end

-- Close all other tabs in the current group except the active tab
local function closeOtherTabs()
  if debugMode then
    StartClock = os.clock()
    print("Start closing other tabs")
  end

  -- Get current tab data
  local originalFrameNumber = app.frame.frameNumber
  switchToDummyFrame()
  local currTabData = getCurrentTabData()

  -- Scroll through other tabs and close them until current tab is reached again
  app.command.GotoNextTab()
  local closeSuccessful = closeTabsUntilOriginal(currTabData)

  if not closeSuccessful then
    cleanUpDummyFrame(originalTabData, originalFrameNumber)
    return
  end

  app.command.GotoNextTab()
  closeSuccessful = closeTabsUntilOriginal(currTabData)

  if not closeSuccessful then
    cleanUpDummyFrame(originalTabData, originalFrameNumber)
    return
  end

  cleanUpDummyFrame(currTabData, originalFrameNumber)

  if debugMode then
    print("\nFinished closing other tabs")
    print("\nElapsed time is: " .. getElapsedTime() .. "s")
  end
end

-- Make the first tab in the current group active
local function switchToFrontTab()
  app.command.DuplicateView()
  app.command.CloseFile()
  app.command.GotoNextTab()
end

-- Close all of the tabs to the left of the active tab
local function closeTabsToTheLeft()
  if debugMode then
    StartClock = os.clock()
    print("Start closing tabs to the left")
  end

  local originalFrameNumber = app.frame.frameNumber
  switchToDummyFrame()
  local originalTabData = getCurrentTabData()
  switchToFrontTab()
  local closeSuccessful = closeTabsUntilOriginal(originalTabData)

  if not closeSuccessful then
    cleanUpDummyFrame(originalTabData, originalFrameNumber)
    return
  end

  cleanUpDummyFrame(originalTabData, originalFrameNumber)

  if debugMode then
    print("\nFinished closing tabs to the left")
    print("\nElapsed time is: " .. getElapsedTime() .. "s")
  end
end

-- Make the last tab in the current group active
local function switchToLastTab()
  app.command.DuplicateView()
  app.command.CloseFile()
end

-- Close all of the tabs to the right of the active tab
local function closeTabsToTheRight()
  if debugMode then
    StartClock = os.clock()
    print("Start closing tabs to the right")
  end

  local originalFrameNumber = app.frame.frameNumber
  switchToDummyFrame()
  local originalTabData = getCurrentTabData()
  switchToLastTab()
  local closeSuccessful = closeTabsUntilOriginal(originalTabData)

  if not closeSuccessful then
    cleanUpDummyFrame(originalTabData, originalFrameNumber)
    return
  end

  cleanUpDummyFrame(originalTabData, originalFrameNumber)
  
  if debugMode then
    print("\nFinished closing tabs to the right")
    print("\nElapsed time is: " .. getElapsedTime() .. "s")
  end
end

-- Close all tabs in the row that the active tab is in
local function closeAllTabs()
  if debugMode then
    StartClock = os.clock()
    print("Start closing all tabs")
  end

  closeOtherTabs()
  app.command.CloseFile()

  if debugMode then
    print("Finished closing all tabs")
    print("\nElapsed time is: " .. getElapsedTime() .. "s")
  end
end

function init(plugin)
  if debugMode then
    print("Adding Close Multiple Tabs plugin...")
  end

  plugin:newCommand {
    id="CloseOtherTabs",
    title="Close Others",
    group="document_tab_close",
    onclick=closeOtherTabs
  }

  plugin:newCommand {
    id="CloseTabsToLeft",
    title="Close to the Left",
    group="document_tab_close",
    onclick=closeTabsToTheLeft
  }

  plugin:newCommand {
    id="CloseTabsToRight",
    title="Close to the Right",
    group="document_tab_close",
    onclick=closeTabsToTheRight
  }

  plugin:newCommand {
    id="CloseAllTabs",
    title="Close Row",
    group="document_tab_close",
    onclick=closeAllTabs
  }

  if debugMode then
    print("\nInstalled Close Multiple Tabs plugin successfully!")
  end
end
