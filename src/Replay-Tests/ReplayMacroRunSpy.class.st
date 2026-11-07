"
I stand for the scenario of a macro in tests, to assert that a macro shortcut reaches its scenario through the Keymapping dispatch path.
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

{ #category : 'accessing' }
ReplayMacroRunSpy >> title [
	"Macros are named after their scenario"

	^ 'Run spy'
]
