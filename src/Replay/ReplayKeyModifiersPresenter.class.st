"
I edit a set of keyboard modifiers (a ReplayKeyModifiers mask) with one check box per modifier.

I do not own the modifiers: my model shows me a mask with modifiers:, and I give each edit to the block of whenModifiersChangedDo:, with the new mask. Showing a mask does not run the block.
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

{ #category : 'layout' }
ReplayKeyModifiersPresenter class >> add: aCheckBox fittedTo: aBoxLayout [
	"Check boxes take a large default width even when not expanded, and a fixed width alone makes them fill the height of their row: fit them to their label, at the height of one line."

	aBoxLayout add: aCheckBox withConstraints: [ :constraints |
		constraints
			width: (StandardFonts defaultFont widthOfString: aCheckBox label) + 44;
			height: self inputTextHeight ]
]

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

	| box |
	box := SpBoxLayout newLeftToRight spacing: 8.
	ReplayKeyModifiers all do: [ :mask |
		self class add: (self checkBoxFor: mask) fittedTo: box ].
	^ box
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
ReplayKeyModifiersPresenter >> namedCheckBoxes [
	"My check boxes by field name, for the editors that show me to register them: 'shift', 'control', 'alt option' and 'command'"

	^ ReplayKeyModifiers all collect: [ :mask |
		  ((ReplayKeyModifiers nameOf: mask) copyReplaceAll: '/' with: ' ') asLowercase -> (self checkBoxFor: mask) ]
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
ReplayKeyModifiersPresenter >> whenModifiersChangedDo: aBlock [
	"aBlock receives the new modifiers after each edit"

	changeBlock := aBlock
]
