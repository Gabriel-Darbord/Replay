"
I am a requested window placement, used by actions that open a window (ReplayOpenUI subclasses and ReplayNavigate).

I hold either exact bounds, or a position and/or an extent. Bounds exclude the other two: setting bounds forgets the position and extent, and setting a position or an extent forgets the bounds. A nil field leaves the choice to the window system, and an empty placement requests nothing.

I am a value object compared by my fields, and serialize to STON with my non-nil fields only. Actions keep nil instead of an empty placement.
"
Class {
	#name : 'ReplayPlacement',
	#superclass : 'Object',
	#instVars : [
		'position',
		'extent',
		'bounds'
	],
	#category : 'Replay-Core',
	#package : 'Replay',
	#tag : 'Core'
}

{ #category : 'instance creation' }
ReplayPlacement class >> bounds: aRectangle [

	^ self new
		  bounds: aRectangle;
		  yourself
]

{ #category : 'instance creation' }
ReplayPlacement class >> extent: aPoint [

	^ self new
		  extent: aPoint;
		  yourself
]

{ #category : 'instance creation' }
ReplayPlacement class >> position: aPoint [

	^ self new
		  position: aPoint;
		  yourself
]

{ #category : 'instance creation' }
ReplayPlacement class >> position: positionPoint extent: extentPoint [

	^ self new
		  position: positionPoint;
		  extent: extentPoint;
		  yourself
]

{ #category : 'comparing' }
ReplayPlacement >> = anObject [

	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ position = anObject position and: [
		  extent = anObject extent and: [ bounds = anObject bounds ] ]
]

{ #category : 'applying' }
ReplayPlacement >> applyToWindowPresenter: aWindowPresenter [
	"Request my placement from a Spec window presenter before it opens."

	self requestedPosition ifNotNil: [ :point |
		aWindowPresenter initialPosition: point ].
	self requestedExtent ifNotNil: [ :point |
		aWindowPresenter initialExtent: point ]
]

{ #category : 'accessing' }
ReplayPlacement >> bounds [
	"Answer the requested window bounds, or nil."

	^ bounds
]

{ #category : 'accessing' }
ReplayPlacement >> bounds: aRectangle [
	"Request exact window bounds, forgetting any position or extent. Nil requests no bounds."

	bounds := aRectangle.
	aRectangle ifNotNil: [
		position := nil.
		extent := nil ]
]

{ #category : 'editing' }
ReplayPlacement >> boundsBottom: aNumber [

	| current |
	current := self boundsForEditing.
	self bounds: (current topLeft corner: current right @ aNumber asNumber)
]

{ #category : 'editing' }
ReplayPlacement >> boundsForEditing [

	^ self bounds ifNil: [ self positionForEditing extent: self extentForEditing ]
]

{ #category : 'editing' }
ReplayPlacement >> boundsLeft: aNumber [

	| current |
	current := self boundsForEditing.
	self bounds: (aNumber asNumber @ current top corner: current bottomRight)
]

{ #category : 'editing' }
ReplayPlacement >> boundsPresenterOn: editor targetPrefixes: prefixes whenChangedDo: aBlock [

	| current |
	current := self boundsForEditing.
	^ SpBoxLayout newTopToBottom
		add: 'Bounds:' expand: false;
		add: (SpBoxLayout newLeftToRight
				spacing: 8;
				add: 'Left' expand: false;
				add: (self numberPresenterOn: editor targetPrefixes: prefixes named: 'bounds left' value: current left update: [ :number |
						self boundsLeft: number ] whenChangedDo: aBlock);
				add: 'Top' expand: false;
				add: (self numberPresenterOn: editor targetPrefixes: prefixes named: 'bounds top' value: current top update: [ :number |
						self boundsTop: number ] whenChangedDo: aBlock);
				yourself)
		expand: false;
		add: (SpBoxLayout newLeftToRight
				spacing: 8;
				add: 'Right' expand: false;
				add: (self numberPresenterOn: editor targetPrefixes: prefixes named: 'bounds right' value: current right update: [ :number |
						self boundsRight: number ] whenChangedDo: aBlock);
				add: 'Bottom' expand: false;
				add: (self numberPresenterOn: editor targetPrefixes: prefixes named: 'bounds bottom' value: current bottom update: [ :number |
						self boundsBottom: number ] whenChangedDo: aBlock);
				yourself)
		expand: false;
		yourself
]

{ #category : 'editing' }
ReplayPlacement >> boundsRight: aNumber [

	| current |
	current := self boundsForEditing.
	self bounds: (current topLeft corner: aNumber asNumber @ current bottom)
]

{ #category : 'editing' }
ReplayPlacement >> boundsTop: aNumber [

	| current |
	current := self boundsForEditing.
	self bounds: (current left @ aNumber asNumber corner: current bottomRight)
]

{ #category : 'editing' }
ReplayPlacement >> clear [
	"Forget every request."

	position := nil.
	extent := nil.
	bounds := nil
]

{ #category : 'editing' }
ReplayPlacement >> defaultExtent [
	"Extent shown while editing when none is requested."

	^ 640 @ 400
]

{ #category : 'editing' }
ReplayPlacement >> defaultPosition [
	"Position shown while editing when none is requested."

	^ 100 @ 100
]

{ #category : 'accessing' }
ReplayPlacement >> extent [
	"Answer the requested extent, or nil."

	^ extent
]

{ #category : 'accessing' }
ReplayPlacement >> extent: aPoint [
	"Request an extent, forgetting any bounds. Nil requests no extent."

	extent := aPoint.
	aPoint ifNotNil: [ bounds := nil ]
]

{ #category : 'editing' }
ReplayPlacement >> extentForEditing [

	^ self requestedExtent ifNil: [ self defaultExtent ]
]

{ #category : 'editing' }
ReplayPlacement >> extentHeight: aNumber [

	self extent: self extentForEditing x @ aNumber asNumber
]

{ #category : 'editing' }
ReplayPlacement >> extentPresenterOn: editor targetPrefixes: prefixes whenChangedDo: aBlock [

	| current |
	current := self extentForEditing.
	^ SpBoxLayout newTopToBottom
		add: 'Extent:' expand: false;
		add: (SpBoxLayout newLeftToRight
				spacing: 8;
				add: 'Width' expand: false;
				add: (self numberPresenterOn: editor targetPrefixes: prefixes named: 'extent width' value: current x update: [ :number |
						self extentWidth: number ] whenChangedDo: aBlock);
				add: 'Height' expand: false;
				add: (self numberPresenterOn: editor targetPrefixes: prefixes named: 'extent height' value: current y update: [ :number |
						self extentHeight: number ] whenChangedDo: aBlock);
				yourself)
		expand: false;
		yourself
]

{ #category : 'editing' }
ReplayPlacement >> extentWidth: aNumber [

	self extent: aNumber asNumber @ self extentForEditing y
]

{ #category : 'comparing' }
ReplayPlacement >> hash [

	^ (position hash bitXor: extent hash) bitXor: bounds hash
]

{ #category : 'testing' }
ReplayPlacement >> isEmpty [

	^ position isNil and: [ extent isNil and: [ bounds isNil ] ]
]

{ #category : 'editing' }
ReplayPlacement >> numberPresenterOn: editor targetPrefixes: prefixes named: targetName value: value update: updateBlock whenChangedDo: aBlock [

	| input |
	(input := editor newNumberInput)
		numberType: Float;
		number: value;
		whenNumberChangedDo: [ :number |
			updateBlock value: number.
			aBlock value: self ].
	prefixes do: [ :prefix |
		editor registerReplayPresenter: input named: prefix , ' ' , targetName ].
	^ input
]

{ #category : 'accessing' }
ReplayPlacement >> position [
	"Answer the requested window position, or nil."

	^ position
]

{ #category : 'accessing' }
ReplayPlacement >> position: aPoint [
	"Request a window position, forgetting any bounds. Nil requests no position."

	position := aPoint.
	aPoint ifNotNil: [ bounds := nil ]
]

{ #category : 'editing' }
ReplayPlacement >> positionForEditing [

	^ self requestedPosition ifNil: [ self defaultPosition ]
]

{ #category : 'editing' }
ReplayPlacement >> positionPresenterOn: editor targetPrefixes: prefixes whenChangedDo: aBlock [

	| current |
	current := self positionForEditing.
	^ SpBoxLayout newTopToBottom
		add: 'Position:' expand: false;
		add: (SpBoxLayout newLeftToRight
				spacing: 8;
				add: 'X' expand: false;
				add: (self numberPresenterOn: editor targetPrefixes: prefixes named: 'position x' value: current x update: [ :number |
						self positionX: number ] whenChangedDo: aBlock);
				add: 'Y' expand: false;
				add: (self numberPresenterOn: editor targetPrefixes: prefixes named: 'position y' value: current y update: [ :number |
						self positionY: number ] whenChangedDo: aBlock);
				yourself)
		expand: false;
		yourself
]

{ #category : 'editing' }
ReplayPlacement >> positionX: aNumber [

	self position: aNumber asNumber @ self positionForEditing y
]

{ #category : 'editing' }
ReplayPlacement >> positionY: aNumber [

	self position: self positionForEditing x @ aNumber asNumber
]

{ #category : 'editing' }
ReplayPlacement >> presenterOn: editor targetPrefixes: prefixes whenChangedDo: aBlock [
	"Build the layout editing me. Each input is registered in the editor under every prefix,
	for example 'Action extent width'. aBlock receives me after each change."

	| clearButton |
	clearButton := editor newButton
		label: 'Clear placement';
		action: [
			self clear.
			aBlock value: self ];
		yourself.
	prefixes do: [ :prefix |
		editor registerReplayPresenter: clearButton named: prefix , ' clear placement' ].
	^ SpBoxLayout newTopToBottom
		spacing: 10;
		add: (self positionPresenterOn: editor targetPrefixes: prefixes whenChangedDo: aBlock) expand: false;
		add: (self extentPresenterOn: editor targetPrefixes: prefixes whenChangedDo: aBlock) expand: false;
		add: (self boundsPresenterOn: editor targetPrefixes: prefixes whenChangedDo: aBlock) expand: false;
		add: clearButton expand: false;
		yourself
]

{ #category : 'printing' }
ReplayPlacement >> printOn: aStream [

	super printOn: aStream.
	aStream nextPut: $(.
	bounds ifNotNil: [ aStream print: bounds ].
	position ifNotNil: [ aStream nextPutAll: 'at '; print: position ].
	(position notNil and: [ extent notNil ]) ifTrue: [ aStream space ].
	extent ifNotNil: [ aStream nextPutAll: 'size '; print: extent ].
	aStream nextPut: $)
]

{ #category : 'accessing' }
ReplayPlacement >> requestedExtent [
	"Answer the extent I request, from my bounds or my extent, or nil."

	^ bounds ifNil: [ extent ] ifNotNil: [ bounds extent ]
]

{ #category : 'accessing' }
ReplayPlacement >> requestedPosition [
	"Answer the window position I request, from my bounds or my position, or nil."

	^ bounds ifNil: [ position ] ifNotNil: [ bounds origin ]
]
