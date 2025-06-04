"
Applies to actions that use a bitwise-encoded integer to represent flags.
"
Trait {
	#name : 'TReplayActionWithFlags',
	#instVars : [
		'flags'
	],
	#category : 'Replay',
	#package : 'Replay'
}

{ #category : 'accessing' }
TReplayActionWithFlags >> flags [

	^ flags ifNil: [ flags := 0 ]
]

{ #category : 'accessing' }
TReplayActionWithFlags >> flags: anInteger [

	flags := anInteger
]

{ #category : 'editing' }
TReplayActionWithFlags >> flagsPresenterOn: editor namesAndValues: pairs [
	"Pairs contain:
	1. Display string of the flag.
	2. Integer encoding the flag."

	^ SpGridLayout build: [ :layout |
		  pairs pairsDo: [ :name :value |
			  layout add: (editor newCheckBox
					   label: name;
					   state: (self flags bitAnd: value) = value;
					   whenActivatedDo: [ self flags: (self flags bitOr: value) ];
					   whenDeactivatedDo: [ self flags: (self flags bitClear: value) ]) ] ]
]
