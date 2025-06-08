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

{ #category : 'adding' }
TReplayActionWithFlags >> addFlags: anInteger [

	self flags: (self flags bitOr: anInteger).
	^ anInteger
]

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
					   state: (self hasFlags: value);
					   whenActivatedDo: [ self addFlags: value ];
					   whenDeactivatedDo: [ self removeFlags: value ]) ] ]
]

{ #category : 'testing' }
TReplayActionWithFlags >> hasFlags: anInteger [

	^ (self flags bitAnd: anInteger) = anInteger
]

{ #category : 'removing' }
TReplayActionWithFlags >> removeFlags: anInteger [

	self flags: (self flags bitClear: anInteger).
	^ anInteger
]
