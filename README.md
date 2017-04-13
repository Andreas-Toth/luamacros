# Why I forked the original…
This version...
* Fixes several compiler errors/warnings
* Drops the 7zip archived code (although the archives have been kept for posterity sake)
* Adds lmc_get_window_path() to the list of LUA commands
* Improves some code
There are several outstanding issues, but these are the main ones…
* Running state always shows “Not running” even when code is executing
* If started with a script from the command-line, clicking Save will crash
Planned improvements
* I really disagree with the current implementation since it is destructive instead of being an enhancement for device input, e.g., when a callback is defined for, say a specific keyboard, one *must* map each and every key of that keyboard to an output or else those keys are swallowed up. In my opinion, the better way would be to implement a “handled” flag that is set to false by default. If the implementer of the callback then wants to trap a specific set of events while letting others pass through as normal, they can do so by controlling the value of the “handled” flag. Unfortunately, the current implementation does not lend itself to implementing such a flag very easily. [Priority: HIGH]
* Add support for handling mouse events. [Priority: LOW]
# LuaMacros
Compared to other Windows macro software, LuaMacros uniquely identifies each keyboard and game HID device, and can even be used to identify the current active application, to execute and control it via macros written in Lua.
Input triggers supported are…
* Different keyboards
* Game devices, e.g., joysticks
* COM interface, e.g., Arduino
* HTTP via a small embedded http server
* Game simulator, e.g., Xplane on a variable change
Macro action can be anything scripted in Lua with some extensions
* Serial communication
* Xplane simulator events (commands, data ref changes)
* HTTP get
* Run programs
For details see http://www.hidmacros.eu/forum/viewforum.php?f=9
# Original binary download
Download me2d13's original binary from [luamacros.zip](http://www.hidmacros.eu/luamacros.zip). Note that this version does not incorporate any of my fixes and/or changes.
# Developer’s guide
To compile & extend LuaMacros yourself you need to download and install the latest Lazarus environment (http://www.lazarus-ide.org/).
Clone the following repositories from me to ensure you have working versions:
* [luamacros]( https://github.com/Andreas-Toth/luamacros)
* [epiktimer]( https://github.com/Andreas-Toth/ epiktimer)
* [ExtraHighlighters]( https://github.com/Andreas-Toth/ ExtraHighlighters)
* [LazSerial]( https://github.com/Andreas-Toth/ LazSerial)
* [lnet]( https://github.com/Andreas-Toth/ lnet)
* [luipack]( https://github.com/Andreas-Toth/ luipack)
Before opening the luamacros project, you will first have to install the following packages into the Lazarus IDE.
* etpackage_dsgn
* extrahighlighters_dt
* LazSerialPort
* lnetvisual
* uniqueinstance_package
Now you should be able to open the three projects that are part of the main repository, i.e.,...
* WinHook - DLL to set global keyboard hook. Be sure to build this or else LuaMacros won’t run (this will pace the DLL in out).
* LuaMacros - The main application exe. Important: if you need to execute compiled EXE, don't forget to copy Lua DLLs from the lib directory to the same place as the EXE file (i.e., out) or the program will crash with a segmentation error (visible in the IDE).
* XplPlugin – Optional XPlane plugin DLL. Note that this is a 64-bit project.
* When starting from your build environment make sure you copy LUA dlls (see lib folder) into your output directory. These dlls must be in the same directory as LuaMacros.exe. Without them program even won't start at all or crashes with some segmentation error (in IDE)

-Andreas