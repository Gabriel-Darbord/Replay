"
I am the presenter that edits a Replay action in the right pane of a ReplayEditor, my owner. Actions are model objects serialized with STON: they only answer which class of mine edits them (`editorClass` on their class side), and I build their editing UI.

I show the fields of my action (`addFieldsTo:`, which my subclasses implement), or a notice when the action has nothing to edit. My field builders (`positiveIntegerField:label:get:set:`, `choiceField:label:choices:get:set:`, `textField:label:get:set:`, `pointField:label:get:set:`, `placementField:get:set:`, ...) read the action through a get block and write it through a set block each time they change, then notify my editor once with `actionChanged:`, which shows the new label of the action in the action list.

Semantic names: each field is registered as 'Action <field>' (`register:as:`), with field names unique within the pane, such as 'Action count', 'Action x', 'Action shift' or 'Action text'. I answer them with replayPresenterAt:ifAbsent:, which my editor asks while I am shown.
"
Class {
	#name : 'ReplayActionEditor',
	#superclass : 'SpPresenter',
	#instVars : [
		'action',
		'fields'
	],
	#category : 'Replay-Editing',
	#package : 'Replay',
	#tag : 'Editing'
}

{ #category : 'debugging' }
ReplayActionEditor class >> debugScriptOf: anAction in: aReplayEditor [
	"Debug the script of anAction, an action of the scenario of aReplayEditor that I edit, with the receiver it has when the scenario runs"

	anAction debugScriptOn: (ReplayRunner on: aReplayEditor scenario)
]

{ #category : 'instance creation' }
ReplayActionEditor class >> on: anAction in: aReplayEditor [

	^ aReplayEditor instantiate: self on: anAction
]

{ #category : 'accessing' }
ReplayActionEditor >> action [
	"The action I edit"

	^ action
]

{ #category : 'notifying' }
ReplayActionEditor >> actionChanged [
	"Sent once after each edit of my action"

	self scenarioEditor actionChanged: action
]

{ #category : 'building' }
ReplayActionEditor >> addFieldsTo: aLayout [
	"Add the fields that edit my action. Actions without settings add none."
]

{ #category : 'fields' }
ReplayActionEditor >> checkBoxField: aField label: label get: getBlock set: setBlock [

	^ self register: (self newCheckBox
			   label: label;
			   state: getBlock value;
			   whenChangedDo: [ :state |
				   setBlock value: state.
				   self actionChanged ];
			   yourself)
		  as: aField
]

{ #category : 'fields' }
ReplayActionEditor >> choiceField: aField label: label choices: associations get: getBlock set: setBlock [
	"A drop list of the keys of associations, shown by their values"

	| dropList |
	dropList := self newDropList.
	dropList
		items: associations;
		display: [ :association | association value ];
		selectItem: (associations
				 detect: [ :association | association key = getBlock value ]
				 ifNone: [ associations first ]);
		whenSelectedItemChangedDo: [ :association |
			association ifNotNil: [
					setBlock value: association key.
					self actionChanged ] ].
	^ self labeled: label field: (self register: dropList as: aField)
]

{ #category : 'fields' }
ReplayActionEditor >> codeField: aField label: label get: getBlock set: setBlock [

	^ self
		  labeled: label
		  expandedField: (self register: (self newCode
					    text: getBlock value;
					    whenTextChangedDo: [ :aString |
						    setBlock value: aString.
						    self actionChanged ];
					    yourself)
				   as: aField)
]

{ #category : 'fields' }
ReplayActionEditor >> debugButton: label action: aBlock [

	^ SpBoxLayout newLeftToRight
		  add: (self newButton
				   icon: (self iconNamed: #bug);
				   label: label;
				   action: aBlock;
				   yourself)
		  withConstraints: [ :constraints | constraints width: 200 ];
		  yourself
]

{ #category : 'fields' }
ReplayActionEditor >> labeled: label expandedField: aPresenter [

	^ SpBoxLayout newTopToBottom
		  add: label expand: false;
		  add: aPresenter;
		  yourself
]

{ #category : 'fields' }
ReplayActionEditor >> labeled: label field: aPresenterOrLayout [

	^ SpBoxLayout newTopToBottom
		  add: label expand: false;
		  add: aPresenterOrLayout expand: false;
		  yourself
]

{ #category : 'fields' }
ReplayActionEditor >> lineField: aField label: label get: getBlock set: setBlock [
	"A single line of text"

	^ self labeled: label field: (self register: (self newTextInput
				    text: getBlock value;
				    whenTextChangedDo: [ :aString |
					    setBlock value: aString.
					    self actionChanged ];
				    yourself)
			   as: aField)
]

{ #category : 'fields' }
ReplayActionEditor >> modifiersField: label get: getBlock set: setBlock [
	"A check box per keyboard modifier, registered as 'Action shift', 'Action control', 'Action alt option' and 'Action command'"

	| presenter |
	presenter := self instantiate: ReplayKeyModifiersPresenter.
	presenter
		modifiers: getBlock value;
		whenModifiersChangedDo: [ :newModifiers |
			setBlock value: newModifiers.
			self actionChanged ].
	presenter namedCheckBoxes do: [ :association | self register: association value as: association key ].
	^ self labeled: label field: presenter
]

{ #category : 'building' }
ReplayActionEditor >> newContentLayout [
	"The layout of the whole pane"

	^ self newFieldsLayout
]

{ #category : 'building' }
ReplayActionEditor >> newFieldsLayout [

	| layout |
	layout := SpBoxLayout newTopToBottom
		          spacing: 10;
		          yourself.
	self addFieldsTo: layout.
	layout children ifEmpty: [ layout add: self newNoFieldsNotice expand: false ].
	^ layout
]

{ #category : 'building' }
ReplayActionEditor >> newNoFieldsNotice [

	^ SpBoxLayout newLeftToRight
		  vAlignStart;
		  spacing: 10;
		  add: (self iconNamed: #info) expand: false;
		  add: 'This action cannot be edited.';
		  yourself
]

{ #category : 'fields' }
ReplayActionEditor >> numberInput: aField get: getBlock set: setBlock [
	"A number input, without label"

	^ self register: (self newNumberInput
			   numberType: Float;
			   number: getBlock value;
			   whenNumberChangedDo: [ :number |
				   setBlock value: number.
				   self actionChanged ];
			   yourself)
		  as: aField
]

{ #category : 'fields' }
ReplayActionEditor >> placementField: getBlock set: setBlock [
	"Edit a window placement, a ReplayPlacement or nil, as 'Action position x', 'Action extent width', 'Action bounds left', ... and 'Action clear placement'.
	Each edit sets a changed copy of the placement read from getBlock."

	| edit current clearButton |
	current := getBlock value ifNil: [ ReplayPlacement new ].
	edit := [ :aField :value :update |
	        self numberInput: aField get: [ value ] set: [ :number |
		        | placement |
		        placement := (getBlock value ifNil: [ ReplayPlacement new ]) copy.
		        update value: placement value: number.
		        setBlock value: placement ] ].
	clearButton := self register: (self newButton
			                label: 'Clear placement';
			                action: [
				                setBlock value: nil.
				                self actionChanged ];
			                yourself)
		               as: 'clear placement'.
	^ SpBoxLayout newTopToBottom
		  spacing: 10;
		  add: (self labeled: 'Position:' field: (SpBoxLayout newLeftToRight
					    spacing: 8;
					    add: 'X' expand: false;
					    add: (edit value: 'position x' value: current positionForEditing x value: [ :placement :number | placement positionX: number ]);
					    add: 'Y' expand: false;
					    add: (edit value: 'position y' value: current positionForEditing y value: [ :placement :number | placement positionY: number ]);
					    yourself))
		  expand: false;
		  add: (self labeled: 'Extent:' field: (SpBoxLayout newLeftToRight
					    spacing: 8;
					    add: 'Width' expand: false;
					    add: (edit value: 'extent width' value: current extentForEditing x value: [ :placement :number | placement extentWidth: number ]);
					    add: 'Height' expand: false;
					    add: (edit value: 'extent height' value: current extentForEditing y value: [ :placement :number | placement extentHeight: number ]);
					    yourself))
		  expand: false;
		  add: (self labeled: 'Bounds:' field: (SpBoxLayout newTopToBottom
					    add: (SpBoxLayout newLeftToRight
							     spacing: 8;
							     add: 'Left' expand: false;
							     add: (edit value: 'bounds left' value: current boundsForEditing left value: [ :placement :number | placement boundsLeft: number ]);
							     add: 'Top' expand: false;
							     add: (edit value: 'bounds top' value: current boundsForEditing top value: [ :placement :number | placement boundsTop: number ]);
							     yourself)
					    expand: false;
					    add: (SpBoxLayout newLeftToRight
							     spacing: 8;
							     add: 'Right' expand: false;
							     add: (edit value: 'bounds right' value: current boundsForEditing right value: [ :placement :number | placement boundsRight: number ]);
							     add: 'Bottom' expand: false;
							     add: (edit value: 'bounds bottom' value: current boundsForEditing bottom value: [ :placement :number | placement boundsBottom: number ]);
							     yourself)
					    expand: false;
					    yourself))
		  expand: false;
		  add: clearButton expand: false;
		  yourself
]

{ #category : 'fields' }
ReplayActionEditor >> pointField: aPrefix label: label get: getBlock set: setBlock [
	"Inputs for a point, registered as 'Action x' and 'Action y', or 'Action <aPrefix> x' and 'Action <aPrefix> y'.
	Each input reads the current point, so that editing X then Y keeps both edits."

	| names |
	names := #( 'x' 'y' ) collect: [ :coordinate |
		         aPrefix isEmptyOrNil
			         ifTrue: [ coordinate ]
			         ifFalse: [ aPrefix , ' ' , coordinate ] ].
	^ self labeled: label field: (SpBoxLayout newLeftToRight
			   add: 'X' expand: false;
			   add: (self numberInput: names first get: [ getBlock value x ] set: [ :number |
					    setBlock value: number @ getBlock value y ]);
			   add: 'Y' expand: false;
			   add: (self numberInput: names second get: [ getBlock value y ] set: [ :number |
					    setBlock value: getBlock value x @ number ]);
			   yourself)
]

{ #category : 'fields' }
ReplayActionEditor >> positiveIntegerField: aField label: label get: getBlock set: setBlock [

	^ self labeled: label field: (self register: (self newNumberInput
				    minimum: 1;
				    numberType: Integer;
				    number: getBlock value;
				    whenNumberChangedDo: [ :number |
					    setBlock value: number.
					    self actionChanged ];
				    yourself)
			   as: aField)
]

{ #category : 'semantic names' }
ReplayActionEditor >> register: aPresenter as: aField [
	"Register aPresenter as 'Action <aField>', and answer it"

	fields at: 'Action ' , aField put: aPresenter.
	^ aPresenter
]

{ #category : 'semantic names' }
ReplayActionEditor >> replayPresenterAt: aPresenterName ifAbsent: absentBlock [

	^ fields at: aPresenterName ifAbsent: absentBlock
]

{ #category : 'semantic names' }
ReplayActionEditor >> resetFields [
	"Forget the fields of the view I replace"

	fields := Dictionary new
]

{ #category : 'accessing' }
ReplayActionEditor >> scenario [

	^ self scenarioEditor scenario
]

{ #category : 'accessing' }
ReplayActionEditor >> scenarioEditor [
	"The ReplayEditor that shows me"

	^ self owner
]

{ #category : 'initialization' }
ReplayActionEditor >> initializePresenters [

	self resetFields.
	self layout: self newContentLayout
]

{ #category : 'initialization' }
ReplayActionEditor >> setModelBeforeInitialization: anAction [

	action := anAction
]

{ #category : 'fields' }
ReplayActionEditor >> textField: aField label: label get: getBlock set: setBlock [
	"A text area that takes the remaining height"

	^ self
		  labeled: label
		  expandedField: (self register: (self newText
					    text: getBlock value;
					    whenTextChangedDo: [ :aString |
						    setBlock value: aString.
						    self actionChanged ];
					    yourself)
				   as: aField)
]
