Class {
	#name : 'TutorialActionTest',
	#superclass : 'TestCase',
	#instVars : [
		'runner',
		'scenario'
	],
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'testing' }
TutorialActionTest class >> isAbstract [

	^ true "((name allButLast: 4) asClassInEnvironment: self environment)
		  isAbstract"
]

{ #category : 'running' }
TutorialActionTest >> setUp [

	super setUp.
	scenario := ReplayScenario new.
	runner := ReplayRunner new scenario: scenario
]
