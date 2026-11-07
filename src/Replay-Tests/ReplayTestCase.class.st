"
I am the abstract superclass of Replay tests that drive the UI process or open windows.

I wait on conditions while processing UI cycles, with a timeout instead of a fixed number of cycles, and I close the windows a test leaves open.
"
Class {
	#name : 'ReplayTestCase',
	#superclass : 'TestCase',
	#instVars : [
		'windowsBefore'
	],
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'testing' }
ReplayTestCase class >> isAbstract [

	^ self == ReplayTestCase
]

{ #category : 'support' }
ReplayTestCase >> newWindows [
	"Answer the windows opened since the test started."

	^ self currentWorld systemWindows reject: [ :each |
		  windowsBefore includes: each ]
]

{ #category : 'support' }
ReplayTestCase >> newWindowsLabeled: aString [

	^ self newWindows select: [ :each | each label = aString ]
]

{ #category : 'running' }
ReplayTestCase >> setUp [

	super setUp.
	windowsBefore := self currentWorld systemWindows asIdentitySet
]

{ #category : 'running' }
ReplayTestCase >> tearDown [

	self newWindows do: [ :each | each close ].
	self currentWorld doOneCycle.
	super tearDown
]

{ #category : 'support' }
ReplayTestCase >> waitUntil: aBlock [

	self waitUntil: aBlock timeout: 2 seconds
]

{ #category : 'support' }
ReplayTestCase >> waitUntil: aBlock timeout: aDuration [
	"Process UI cycles until aBlock answers true, failing after aDuration."

	| deadline |
	deadline := DateAndTime now + aDuration.
	[ aBlock value ] whileFalse: [
		DateAndTime now > deadline ifTrue: [
			^ self fail: 'Timed out waiting for a condition' ].
		self currentWorld doOneCycle.
		(Delay forMilliseconds: 5) wait ]
]
