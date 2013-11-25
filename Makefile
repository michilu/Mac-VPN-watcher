all:
	@pbpaste|tr "\r" "\n" > main.applescript
	@osacompile main.applescript
	@diff a.scpt Mac\ VPN\ watcher.app/Contents/Resources/Scripts/main.scpt
	@rm a.scpt
	@echo OK

open:
	open -a applescript\ editor Mac\ VPN\ watcher.app
