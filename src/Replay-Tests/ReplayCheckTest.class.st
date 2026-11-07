"
Tests for ReplayCheck: conditions on a target or the World, waiting until they hold, and failing when they do not.
"
Class {
	#name : 'ReplayCheckTest',
	#superclass : 'ReplayTestCase',
	#instVars : [
		'pane',
		'manager'
	],
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'support' }
ReplayCheckTest >> runCheck: aReplayCheck [
	"Run aReplayCheck on my pane, then a script that sets the focus of the runner to #done. Answer the runner."

	| scenario runner |
	scenario := ReplayScenario new.
	scenario addStep: (ReplayStep new
			 addAction: aReplayCheck;
			 addAction: (ReplayScript new script: 'self focus: #done');
			 yourself).
	runner := ReplayRunner on: scenario.
	runner manager: manager.
	runner run.
	^ runner
]

{ #category : 'running' }
ReplayCheckTest >> setUp [

	super setUp.
	pane := ReplayNamedPanePresenter new.
	manager := ReplayUIManager new managePresenter: pane.
	manager openLabeled: 'Check'
]

{ #category : 'running' }
ReplayCheckTest >> tearDown [

	manager close.
	super tearDown
]

{ #category : 'tests' }
ReplayCheckTest >> testAConditionThatIsNotABooleanFailsAtOnce [

	self
		should: [
			self runCheck: (ReplayCheck new
					 targetNamed: 'items';
					 script: '42';
					 yourself) ]
		raise: ReplayScriptError
]

{ #category : 'tests' }
ReplayCheckTest >> testAFalseConditionFailsAfterTheTimeout [

	| runner |
	runner := self runCheck: (ReplayCheck new
			           targetNamed: 'items';
			           script: 'self selectedItem = #two';
			           timeout: 1;
			           yourself).
	self
		should: [ self waitUntil: [ runner isStopped ] timeout: 3 seconds ]
		raise: ReplayMissingUIError.
	self assert: runner isStopped.
	self assert: runner focus isNil
]

{ #category : 'tests' }
ReplayCheckTest >> testATrueConditionLetsTheScenarioGoOn [

	| runner |
	runner := self runCheck: (ReplayCheck new
			           targetNamed: 'items';
			           script: 'self items size = 2';
			           yourself).
	self waitUntil: [ runner focus = #done ]
]

{ #category : 'tests' }
ReplayCheckTest >> testDefaultTimeoutIsNotSerialized [

	| check |
	check := ReplayCheck new
		         script: 'true';
		         timeout: ReplayCheck defaultTimeout;
		         yourself.
	self deny: ((STON toString: check) includesSubstring: 'timeout').
	check timeout: 5.
	self assert: (STON fromString: (STON toString: check)) timeout equals: 5
]

{ #category : 'tests' }
ReplayCheckTest >> testItWaitsForTheConditionToHold [

	| runner |
	runner := self runCheck: (ReplayCheck new
			           targetNamed: 'items';
			           script: 'self selectedItem = #two';
			           yourself).
	self assert: runner focus isNil.
	pane items selectItem: #two.
	self waitUntil: [ runner focus = #done ]
]

{ #category : 'tests' }
ReplayCheckTest >> testWithoutTargetTheConditionIsOnTheWorld [

	| runner |
	runner := self runCheck: (ReplayCheck new script: 'self isWorldMorph').
	self waitUntil: [ runner focus = #done ]
]
