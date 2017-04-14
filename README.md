# Why I forked the original…
This version...
* Fixes several compiler errors/warnings
* Drops the inclusion of third-party code and instead forks the originals (in all but one instance, i.e., ExtraHighlighters, I have managed to track down the original code repositories and forked from those while ensuring any changes have been maintained) 
* Adds lmc_get_window_path() to the list of LUA commands
* Improves some code

There are several outstanding issues, but these are the main ones…
* Running state always shows “Not running” even when code is executing
* If started with a script from the command-line, clicking Save will crash
* XplPlugin compiles with compiler warnings (some of which would prevent it from supporting 32-bit)

Planned improvements
* I really disagree with the current implementation since it is destructive instead of being an enhancement for device input, e.g., when a callback is defined for, say a specific keyboard, one *must* map each and every key of that keyboard to an output or else those keys are swallowed up. In my opinion, the better way would be to implement a “handled” flag that is set to false by default. If the implementer of the callback then wants to trap a specific set of events while letting others pass through as normal, they can do so by controlling the value of the “handled” flag. Unfortunately, the current implementation does not lend itself to implementing such a flag very easily. [Priority: HIGH]
* Add support for handling mouse events. [Priority: LOW]
# LuaMacros
Compared to other Windows macro software, LuaMacros uniquely identifies each keyboard and game HID device, and can even be used to identify the current active application, to execute and control it via macros written in Lua.
Input triggers supported are…
* Different keyboards
* Game devices, e.g., joysticks
* COM interface, e.g., Arduino
* HTTP via a small embedded server
* Game simulator, e.g., X-Plane on a variable change

Macro action can be anything scripted in Lua with some extensions
* Serial communication
* X-Plane simulator events, e.g., commands and DataRef changes
* HTTP get
* Run programs

For details, see LuaMacro's [forum](http://www.hidmacros.eu/forum/viewforum.php?f=9) run by me2d13 (the developer of the original).
# Original binary download
You can download the binaries from https://github.com/Andreas-Toth/LuaMacros-Bin.
# Developer’s guide
To compile LuaMacros you need to download and install the latest Lazarus environment (http://www.lazarus-ide.org/).
Clone the following repositories into one location...
* [luamacros](https://github.com/Andreas-Toth/luamacros)
* [Ararat-Synapse](https://github.com/Andreas-Toth/Ararat-Synapse)
* [epiktimer](https://github.com/Andreas-Toth/epiktimer)
* [ExtraHighlighters](https://github.com/Andreas-Toth/ExtraHighlighters)
* [LazSerial](https://github.com/Andreas-Toth/LazSerial)
* [Lua](https://github.com/Andreas-Toth/Lua)
* [lnet](https://github.com/Andreas-Toth/lnet)
* [luipack](https://github.com/Andreas-Toth/luipack)
* [wifly](https://github.com/Andreas-Toth/wifly)

Before opening the LuaMacros project, you will first have to install the following packages into the Lazarus IDE.
* etpackage_dsgn
* extrahighlighters_dt
* LazSerialPort
* lnetvisual
* uniqueinstance_package

Now you should be able to open the three projects that are part of the main repository, i.e.,...
* WinHook - DLL to set global keyboard hook. Be sure to build this or else LuaMacros won’t run (this will pace the DLL in out).
* LuaMacros - The main application exe. Important: if you need to execute compiled EXE, don't forget to copy Lua DLLs from the lib directory to the same place as the EXE file (i.e., out) or the program will crash with a segmentation error (visible in the IDE).
* XplPlugin – Optional XPlane plugin DLL. Note that this is a 64-bit project.

# Notes
* The binaries built from this fork are tagged with the name of the repository (i.e., "https://github.com/Andreas-Toth/luamacros") so that they can be distinguished from other builds.


-Andreas