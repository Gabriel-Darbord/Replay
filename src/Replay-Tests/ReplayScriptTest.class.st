"
Tests for script evaluation shared by script actions: receiver, error wrapping, printing, and debugging.
"
Class {
	#name : 'ReplayScriptTest',
	#superclass : 'ReplayTestCase',
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'tests' }
ReplayScriptTest >> testCompilationErrorIsWrappedWithItsCause [

	| action |
	action := ReplayScript new script: '1 +'.

	self
		should: [ action runOn: ReplayRunner new ]
		raise: ReplayScriptError
		withExceptionDo: [ :error |
			self assert: error action identicalTo: action.
			self assert: error cause notNil ]
]

{ #category : 'tests' }
ReplayScriptTest >> testDebugScriptStopsInTheScriptWithTheRunReceiver [

	| runner session context |
	runner := ReplayRunner on: ReplayScenario new.

	session := ((ReplayScript new script: 'self scenario') scriptDebugRequestOn: runner) debugSession.

	[
		session stepIntoUntil: [ :each | each method isDoIt ].
		context := session interruptedContext.
		self assert: context receiver identicalTo: runner.
		self assert: context method sourceCode equals: 'self scenario' ]
		ensure: [ session terminate ]
]

{ #category : 'tests' }
ReplayScriptTest >> testDefaultScriptIsNotStored [

	| action |
	action := ReplayScript new.

	self assert: action script equals: ''.
	self assert: action printString equals: 'Script'.
	self assert: (action instVarNamed: #script) isNil
]

{ #category : 'tests' }
ReplayScriptTest >> testOpenersReportUnexpectedResultsAsScriptErrors [

	| action |
	action := ReplayOpenPresenter new script: '42'.

	self
		should: [ action uiManagerOn: ReplayRunner new ]
		raise: ReplayScriptError
		withExceptionDo: [ :error |
			self assert: error action identicalTo: action.
			self assert: error subject equals: 42.
			self assert: error cause isNil.
			self assert: (error messageText includesSubstring: 'Spec presenter') ]
]

{ #category : 'tests' }
ReplayScriptTest >> testPresenterScriptHasItsOwnLabel [

	| editor |
	editor := ReplayEditor new.
	self
		deny: (editor editAction: ReplayPresenterScript new) scriptLabel
		equals: (editor editAction: ReplayScript new) scriptLabel.
	self assert: ((editor editAction: ReplayPresenterScript new) scriptLabel includesSubstring: 'presenter')
]

{ #category : 'tests' }
ReplayScriptTest >> testPreviewDoesNotRunScript [

	| runner |
	runner := ReplayRunner new.

	(ReplayScript new script: 'self focus: #ran') previewOn: runner.

	self assert: runner focus isNil
]

{ #category : 'tests' }
ReplayScriptTest >> testPrintsScript [

	self
		assert: (ReplayScript new script: '1 + 1') printString
		equals: 'Script: ''1 + 1'''.
	self
		assert: (ReplayAttachUI new script: 'self focus') printString
		equals: 'Attach UI: ''self focus'''
]

{ #category : 'tests' }
ReplayScriptTest >> testReplayErrorsAreNotWrapped [

	self
		should: [ (ReplayScript new script: 'ReplayMissingUIError signal: ''Missing''') runOn: ReplayRunner new ]
		raise: ReplayMissingUIError
]

{ #category : 'tests' }
ReplayScriptTest >> testRunUsesTheRunnerAsReceiver [

	| runner |
	runner := ReplayRunner new.

	(ReplayScript new script: 'self focus: self') runOn: runner.

	self assert: runner focus identicalTo: runner
]

{ #category : 'tests' }
ReplayScriptTest >> testRuntimeErrorIsWrappedWithItsCause [

	| action |
	action := ReplayScript new script: 'self error: ''Boom'''.

	self
		should: [ action runOn: ReplayRunner new ]
		raise: ReplayScriptError
		withExceptionDo: [ :error |
			self assert: error action identicalTo: action.
			self assert: error cause messageText equals: 'Boom'.
			self assert: (error messageText includesSubstring: 'Boom') ]
]
