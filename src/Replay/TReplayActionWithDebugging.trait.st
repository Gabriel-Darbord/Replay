"
Applies to actions that can be debugged.
"
Trait {
	#name : 'TReplayActionWithDebugging',
	#category : 'Replay',
	#package : 'Replay'
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

{ #category : 'editing' }
TReplayActionWithDebugging >> debugButtonPresenterOn: editor labeled: label action: aBlock [

	^ SpBoxLayout newLeftToRight
		  spacing: 10;
		  add: (editor newButton
				   icon: (self iconNamed: #bug);
				   label: label;
				   action: aBlock)
		  withConstraints: [ :c | c width: 200 ];
		  yourself
]
