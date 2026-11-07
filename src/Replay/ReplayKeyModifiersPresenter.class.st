"
I edit a set of keyboard modifiers (a ReplayKeyModifiers mask) with one check box per modifier.

I do not own the modifiers: my model shows me a mask with modifiers:, and I give each edit to the block of whenChangedDo:, with the new mask. Showing a mask does not run the block.
"
Class {
	#name : 'ReplayKeyModifiersPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'modifiers',
		'changeBlock',
		'checkBoxes',
		'showing'
	],
	#category : 'Replay-Editing',
	#package : 'Replay',
	#tag : 'Editing'
}

{ #category : 'accessing' }
ReplayKeyModifiersPresenter >> altCheckBox [

	^ self checkBoxFor: ReplayKeyModifiers alt
]

{ #category : 'accessing' }
ReplayKeyModifiersPresenter >> checkBoxFor: aMask [

	^ checkBoxes at: aMask
]

{ #category : 'accessing' }
ReplayKeyModifiersPresenter >> commandCheckBox [

	^ self checkBoxFor: ReplayKeyModifiers command
]

{ #category : 'accessing' }
ReplayKeyModifiersPresenter >> controlCheckBox [

	^ self checkBoxFor: ReplayKeyModifiers control
]

{ #category : 'layout' }
ReplayKeyModifiersPresenter >> defaultLayout [

	| layout |
	layout := SpBoxLayout newLeftToRight spacing: 8.
	ReplayKeyModifiers all do: [ :mask | layout add: (self checkBoxFor: mask) expand: false ].
	^ layout
]

{ #category : 'initialization' }
ReplayKeyModifiersPresenter >> initializePresenters [

	modifiers := 0.
	showing := false.
	checkBoxes := Dictionary new.
	ReplayKeyModifiers all do: [ :mask |
		checkBoxes at: mask put: (self newCheckBox
				 label: (ReplayKeyModifiers nameOf: mask);
				 whenChangedDo: [ :state | self setModifier: mask to: state ];
				 yourself) ]
]

{ #category : 'accessing' }
ReplayKeyModifiersPresenter >> modifiers [

	^ modifiers
]

{ #category : 'accessing' }
ReplayKeyModifiersPresenter >> modifiers: anInteger [
	"Show anInteger, without notifying the change block"

	modifiers := anInteger.
	showing := true.
	[
	checkBoxes keysAndValuesDo: [ :mask :checkBox |
		checkBox state: (anInteger bitAnd: mask) ~= 0 ] ] ensure: [ showing := false ]
]

{ #category : 'replay' }
ReplayKeyModifiersPresenter >> registerReplayPresentersOn: anEditor named: aPrefix [
	"Register my check boxes as '<aPrefix> shift', '<aPrefix> alt option'..."

	checkBoxes keysAndValuesDo: [ :mask :checkBox |
		anEditor
			registerReplayPresenter: checkBox
			named: aPrefix , ' ' , ((ReplayKeyModifiers nameOf: mask) copyReplaceAll: '/' with: ' ') asLowercase ]
]

{ #category : 'actions' }
ReplayKeyModifiersPresenter >> setModifier: aMask to: aBoolean [

	showing ifTrue: [ ^ self ].
	modifiers := aBoolean
		             ifTrue: [ modifiers bitOr: aMask ]
		             ifFalse: [ modifiers bitClear: aMask ].
	changeBlock ifNotNil: [ changeBlock value: modifiers ]
]

{ #category : 'accessing' }
ReplayKeyModifiersPresenter >> shiftCheckBox [

	^ self checkBoxFor: ReplayKeyModifiers shift
]

{ #category : 'events' }
ReplayKeyModifiersPresenter >> whenChangedDo: aBlock [
	"aBlock receives the new modifiers after each edit"

	changeBlock := aBlock
]
