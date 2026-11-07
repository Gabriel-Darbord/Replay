"
I test ReplayInform, which shows its Microdown text as a notification.
"
Class {
	#name : 'ReplayInformTest',
	#superclass : 'ReplayTestCase',
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'tests' }
ReplayInformTest >> testRunShowsTheTextWithoutFailing [
	"Object>>uiManager, which this action used to send, no longer exists in Pharo 14."

	| runner |
	runner := ReplayRunner on: ReplayScenario new.
	self
		shouldnt: [ (ReplayInform new text: 'Replay *inform* test') runOn: runner ]
		raise: Error
]
