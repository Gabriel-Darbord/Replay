"
I configure the navigation prompt shown between scenario steps, including labels, skip behavior, and optional window placement.
"
Class {
	#name : 'ReplayNavigate',
	#superclass : 'ReplayAction',
	#traits : 'TReplayActionWithText',
	#classTraits : 'TReplayActionWithText classTrait',
	#instVars : [
		'skip',
		'acceptLabel',
		'cancelLabel',
		'position',
		'extent',
		'bounds'
	],
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'accessing' }
ReplayNavigate class >> displayName [

	^ 'Navigate'
]

{ #category : 'testing' }
ReplayNavigate class >> shouldBeDropListElement [

	^ false
]

{ #category : 'accessing' }
ReplayNavigate >> acceptLabel [

	^ acceptLabel ifNil: [ acceptLabel := 'Next' ]
]

{ #category : 'accessing' }
ReplayNavigate >> acceptLabel: aString [

	acceptLabel := aString
]

{ #category : 'running' }
ReplayNavigate >> applyPlacementTo: aWindowPresenter [

	self bounds
		ifNotNil: [ :rectangle |
			aWindowPresenter
				initialPosition: rectangle origin;
				initialExtent: rectangle extent ]
		ifNil: [
			self position ifNotNil: [ :point | aWindowPresenter initialPosition: point ].
			self extent ifNotNil: [ :point | aWindowPresenter initialExtent: point ] ]
]

{ #category : 'accessing' }
ReplayNavigate >> bounds [
	"Answer requested navigation window bounds, or nil to apply position/extent independently."

	^ bounds
]

{ #category : 'accessing' }
ReplayNavigate >> bounds: aRectangle [
	"Set requested navigation window bounds. Nil applies position/extent independently."

	bounds := aRectangle.
	aRectangle ifNotNil: [
		position := nil.
		extent := nil ]
]

{ #category : 'editing' }
ReplayNavigate >> boundsBottom: aNumber [

	| current |
	current := self boundsForEditing.
	self bounds: (current topLeft corner: current right @ aNumber asNumber)
]

{ #category : 'editing' }
ReplayNavigate >> boundsForEditing [

	^ self bounds ifNil: [ self positionForEditing extent: self extentForEditing ]
]

{ #category : 'editing' }
ReplayNavigate >> boundsLeft: aNumber [

	| current |
	current := self boundsForEditing.
	self bounds: (aNumber asNumber @ current top corner: current bottomRight)
]

{ #category : 'editing' }
ReplayNavigate >> boundsPresenterOn: editor [

	| current |
	current := self boundsForEditing.
	^ SpBoxLayout newTopToBottom
		add: 'Bounds:' expand: false;
		add: (SpBoxLayout newLeftToRight
				spacing: 8;
				add: 'Left' expand: false;
				add: (self numberPresenterOn: editor named: 'bounds left' value: current left update: [ :number |
						self boundsLeft: number ]);
				add: 'Top' expand: false;
				add: (self numberPresenterOn: editor named: 'bounds top' value: current top update: [ :number |
						self boundsTop: number ]);
				yourself)
		expand: false;
		add: (SpBoxLayout newLeftToRight
				spacing: 8;
				add: 'Right' expand: false;
				add: (self numberPresenterOn: editor named: 'bounds right' value: current right update: [ :number |
						self boundsRight: number ]);
				add: 'Bottom' expand: false;
				add: (self numberPresenterOn: editor named: 'bounds bottom' value: current bottom update: [ :number |
						self boundsBottom: number ]);
				yourself)
		expand: false;
		yourself
]

{ #category : 'editing' }
ReplayNavigate >> boundsRight: aNumber [

	| current |
	current := self boundsForEditing.
	self bounds: (current topLeft corner: aNumber asNumber @ current bottom)
]

{ #category : 'editing' }
ReplayNavigate >> boundsTop: aNumber [

	| current |
	current := self boundsForEditing.
	self bounds: (current left @ aNumber asNumber corner: current bottomRight)
]

{ #category : 'accessing' }
ReplayNavigate >> cancelLabel [

	^ cancelLabel ifNil: [ cancelLabel := 'Stop' ]
]

{ #category : 'accessing' }
ReplayNavigate >> cancelLabel: aString [

	cancelLabel := aString
]

{ #category : 'editing' }
ReplayNavigate >> clearPlacement [
	"Forget explicit navigation placement requests."

	position := nil.
	extent := nil.
	bounds := nil
]

{ #category : 'editing' }
ReplayNavigate >> defaultExtent [

	^ 420 @ 180
]

{ #category : 'editing' }
ReplayNavigate >> defaultPosition [

	^ 100 @ 100
]

{ #category : 'editing' }
ReplayNavigate >> editionPresenterOn: editor [

	^ editor newPresenter
		layout: (SpBoxLayout newTopToBottom
				spacing: 10;
				add: (editor newCheckBox
						label: 'Skip user navigation';
						state: skip;
						whenActivatedDo: [ skip := true ];
						whenDeactivatedDo: [ skip := false ])
				expand: false;
				add: (SpBoxLayout newTopToBottom
						add: 'Continue label:' expand: false;
						add: (editor newText
								text: self acceptLabel;
								whenTextChangedDo: [ :aString |
									self acceptLabel: aString ]))
				expand: false;
				add: (SpBoxLayout newTopToBottom
						add: 'Cancel label:' expand: false;
						add: (editor newText
								text: self cancelLabel;
								whenTextChangedDo: [ :aString |
									self cancelLabel: aString ]))
				expand: false;
				add: (self textPresenterOn: editor labeled: 'Write rich text display on navigation window:');
				add: (self placementPresenterOn: editor) expand: false;
				yourself);
		yourself
]

{ #category : 'accessing' }
ReplayNavigate >> extent [
	"Answer requested navigation window extent, or nil to keep natural dialog size."

	^ extent
]

{ #category : 'accessing' }
ReplayNavigate >> extent: aPoint [
	"Set requested navigation window extent. Nil keeps natural dialog size."

	extent := aPoint.
	aPoint ifNotNil: [ bounds := nil ]
]

{ #category : 'editing' }
ReplayNavigate >> extentForEditing [

	^ self extent ifNil: [
		self bounds
			ifNil: [ self defaultExtent ]
			ifNotNil: [ :rectangle | rectangle extent ] ]
]

{ #category : 'editing' }
ReplayNavigate >> extentHeight: aNumber [

	| current |
	current := self extentForEditing.
	self extent: current x @ aNumber asNumber
]

{ #category : 'editing' }
ReplayNavigate >> extentPresenterOn: editor [

	| current |
	current := self extentForEditing.
	^ SpBoxLayout newTopToBottom
		add: 'Extent:' expand: false;
		add: (SpBoxLayout newLeftToRight
				spacing: 8;
				add: 'Width' expand: false;
				add: (self numberPresenterOn: editor named: 'extent width' value: current x update: [ :number |
						self extentWidth: number ]);
				add: 'Height' expand: false;
				add: (self numberPresenterOn: editor named: 'extent height' value: current y update: [ :number |
						self extentHeight: number ]);
				yourself)
		expand: false;
		yourself
]

{ #category : 'editing' }
ReplayNavigate >> extentWidth: aNumber [

	| current |
	current := self extentForEditing.
	self extent: aNumber asNumber @ current y
]

{ #category : 'initialization' }
ReplayNavigate >> initialize [

	skip := false
]

{ #category : 'editing' }
ReplayNavigate >> numberPresenterOn: editor named: targetName value: value update: updateBlock [

	| input |
	input := editor newNumberInput.
	input
		numberType: Float;
		number: value;
		whenNumberChangedDo: [ :number |
			updateBlock value: number.
			editor actions rebuildLayout ].
	editor registerReplayPresenter: input named: 'Navigation ' , targetName.
	editor registerReplayPresenter: input named: self class displayName , ' ' , targetName.
	^ input
]

{ #category : 'editing' }
ReplayNavigate >> placementPresenterOn: editor [

	| clearButton |
	clearButton := editor newButton
		label: 'Clear placement';
		action: [
			self clearPlacement.
			editor actions rebuildLayout ];
		yourself.
	editor registerReplayPresenter: clearButton named: 'Navigation clear placement'.
	editor registerReplayPresenter: clearButton named: self class displayName , ' clear placement'.
	^ SpBoxLayout newTopToBottom
		spacing: 10;
		add: (self positionPresenterOn: editor) expand: false;
		add: (self extentPresenterOn: editor) expand: false;
		add: (self boundsPresenterOn: editor) expand: false;
		add: clearButton expand: false;
		yourself
]

{ #category : 'accessing' }
ReplayNavigate >> position [
	"Answer requested navigation window position, or nil to let the backend place it."

	^ position
]

{ #category : 'accessing' }
ReplayNavigate >> position: aPoint [
	"Set requested navigation window position. Nil keeps backend default placement."

	position := aPoint.
	aPoint ifNotNil: [ bounds := nil ]
]

{ #category : 'editing' }
ReplayNavigate >> positionForEditing [

	^ self position ifNil: [
		self bounds
			ifNil: [ self defaultPosition ]
			ifNotNil: [ :rectangle | rectangle origin ] ]
]

{ #category : 'editing' }
ReplayNavigate >> positionPresenterOn: editor [

	| current |
	current := self positionForEditing.
	^ SpBoxLayout newTopToBottom
		add: 'Position:' expand: false;
		add: (SpBoxLayout newLeftToRight
				spacing: 8;
				add: 'X' expand: false;
				add: (self numberPresenterOn: editor named: 'position x' value: current x update: [ :number |
						self positionX: number ]);
				add: 'Y' expand: false;
				add: (self numberPresenterOn: editor named: 'position y' value: current y update: [ :number |
						self positionY: number ]);
				yourself)
		expand: false;
		yourself
]

{ #category : 'editing' }
ReplayNavigate >> positionX: aNumber [

	| current |
	current := self positionForEditing.
	self position: aNumber asNumber @ current y
]

{ #category : 'editing' }
ReplayNavigate >> positionY: aNumber [

	| current |
	current := self positionForEditing.
	self position: current x @ aNumber asNumber
]

{ #category : 'printing' }
ReplayNavigate >> printOn: stream [

	super printOn: stream.
	text isEmptyOrNil ifTrue: [ ^ self ].
	stream nextPutAll: ': '.
	stream nextPutAll: (text printStringLimitedTo: 100)
]

{ #category : 'running' }
ReplayNavigate >> runOn: runner [
	"Has control runner continuation."

	| dialog window |
	skip ifTrue: [ ^ runner nextStep ].
	dialog := SpConfirmDialog new
		title: runner scenario title;
		icon: (self iconNamed: #info);
		label: (Microdown asRichText: self text);
		acceptLabel: self acceptLabel;
		onAccept: [
			"Defer so windows appear in same spot between steps."
			runner defer: [ runner nextStep ] ];
		cancelLabel: self cancelLabel;
		onCancel: [ runner stop ];
		yourself.
	window := dialog asDialogWindow.
	self applyPlacementTo: window.
	window open
]

{ #category : 'accessing' }
ReplayNavigate >> skip [

	^ skip ifNil: [ skip := false ]
]

{ #category : 'accessing' }
ReplayNavigate >> skip: aBoolean [

	skip := aBoolean
]

{ #category : 'accessing' }
ReplayNavigate >> text [

	^ text ifNil: [ text := 'Proceed?' ]
]
