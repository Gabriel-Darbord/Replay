"
Test helper used by ReplayMacroTest to assert that a macro shortcut reaches its scenario through the Keymapping dispatch path.
"
Class {
	#name : 'ReplayMacroRunSpy',
	#superclass : 'Object',
	#instVars : [
		'hasRun'
	],
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'testing' }
ReplayMacroRunSpy >> hasRun [

	^ hasRun = true
]

{ #category : 'running' }
ReplayMacroRunSpy >> run [

	hasRun := true
]
