"
I add common debugging helpers for Replay actions that can open a debugger on their simulated work.
"
Trait {
	#name : 'TReplayActionWithDebugging',
	#category : 'Replay-Traits',
	#package : 'Replay',
	#tag : 'Traits'
}

{ #category : 'debugging' }
TReplayActionWithDebugging >> debug: aBlock [
	"Spawn a debugger on a block"

	| process |
	process := aBlock newProcess.

	^ (OupsDebugRequest newForContext: process suspendedContext)
		  process: process;
		  label: 'Debug Action: ' , self class displayName;
		  submit;
		  debugSession
]
