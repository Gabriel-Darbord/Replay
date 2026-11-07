"
I am the abstract superclass of Replay tests that drive the UI process or open windows.

I wait on conditions while processing UI cycles, with a timeout instead of a fixed number of cycles, and I close the windows a test leaves open.

I also press keys on a hand that is not the one of the World (see press:on:), so that tests reach the listeners of that hand only.
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

{ #category : 'support' }
ReplayTestCase >> dispatch: anEvent toListenersOf: aHandMorph [
	"Give anEvent to the event listeners of aHandMorph, as the hand does before dispatching it"

	aHandMorph sendListenEvent: anEvent to: aHandMorph eventListeners
]

{ #category : 'support' }
ReplayTestCase >> press: aReplayKeyBinding on: aHandMorph [
	"Press and release the keys of the single chord of aReplayKeyBinding, for the listeners of aHandMorph"

	#( #keyDown #keystroke #keyUp ) do: [ :type |
		| event |
		event := aReplayKeyBinding chords first keyboardEventOfType: type.
		event setHand: aHandMorph.
		self dispatch: event toListenersOf: aHandMorph ]
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
