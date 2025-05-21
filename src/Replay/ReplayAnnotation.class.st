"
I annotate an element in the World by adding a border around it.
I am based on bounds, usually taken from a target Morph but it can be arbitrary.
I can include a linked label that can be moved independently.
Note that when applying a label, the target must already be open.
% Well there's probably a way to trigger the label only when building...

% The example is randomized but when a comment is parsed, it is made into a Form and cached so it will not change
```script
TutorialAnnotation example close adapter widget
```

% The following line adds a space to separate from the above
 
Try with a label and moving both it and the window around:
```pharoeval
TutorialAnnotation exampleWithLabel
```
"
Class {
	#name : 'ReplayAnnotation',
	#superclass : 'Morph',
	#instVars : [
		'label',
		'line'
	],
	#category : 'Replay',
	#package : 'Replay'
}

{ #category : 'instance creation' }
ReplayAnnotation class >> annotate: bounds [

	^ self new annotate: bounds
]

{ #category : 'instance creation' }
ReplayAnnotation class >> annotate: bounds label: label [

	| annotation |
	annotation := self new.
	annotation annotate: bounds.
	label isEmptyOrNil ifFalse: [ annotation label: label ].
	^ annotation
]

{ #category : 'instance creation' }
ReplayAnnotation class >> annotateMorph: aMorph [

	^ self annotate: aMorph bounds
]

{ #category : 'instance creation' }
ReplayAnnotation class >> annotateMorph: morph label: label [

	^ self annotate: morph bounds label: label
]

{ #category : 'examples' }
ReplayAnnotation class >> example [

	<example>
	| buttons randomMorph annotation root |
	buttons := SpDemoTextInputPresenter new open close presenter adapter
		           widget position: 0 @ 0.
	randomMorph := buttons submorphs atRandom.

	annotation := ReplayAnnotation annotateMorph: randomMorph.

	(root := Morph new beTransparent)
		addMorph: buttons;
		addMorph: annotation.
	^ (SpMorphPresenter new
		   morph: root;
		   asWindow)
		  initialExtent: 390 @ 166;
		  title: 'Example annotation';
		  open
]

{ #category : 'examples' }
ReplayAnnotation class >> exampleWithLabel [

	<example>
	| buttons randomMorph annotation root window |
	buttons := SpDemoTextInputPresenter new open close presenter adapter
		           widget position: 0 @ 0.
	randomMorph := buttons submorphs atRandom.
	(root := Morph new beTransparent) addMorph: buttons.

	"When using a label, the annotated element must already be open!"
	(window := SpMorphPresenter new
		           morph: root;
		           asWindow)
		initialExtent: 390 @ 166;
		title: 'Example annotation';
		open.
	annotation := ReplayAnnotation
		              annotate: randomMorph bounds
		              label: 'This is annotated.
Try moving me or the window around!'.

	root addMorph: annotation.
	^ window
]

{ #category : 'wiw support' }
ReplayAnnotation class >> morphicLayerNumber [
	"In front of most other UI morphs, below user or meta Morphs such as selection or halo"

	^ 9
]

{ #category : 'accessing' }
ReplayAnnotation >> annotate: rectangle [

	self bounds:
		(Rectangle origin: rectangle origin - 5 corner: rectangle corner + 5)
]

{ #category : 'utilities' }
ReplayAnnotation >> diagonalBetween: rectA and: rectB [
	"Compute the line between the center of two rectangles and cut at their edges.
	Precondition: rectA and rectB have no X or Y overlap."

	| gRectA gRectB gLine |
	gRectA := GRectangle origin: rectA origin corner: rectA corner.
	gRectB := GRectangle origin: rectB origin corner: rectB corner.
	gLine := GSegment with: rectA center with: rectB center.

	^ {
		  (gLine intersectionsWithPolygon: gRectA) anyOne asPoint.
		  (gLine intersectionsWithPolygon: gRectB) anyOne asPoint }
]

{ #category : 'utilities' }
ReplayAnnotation >> edgeBetween: rectA and: rectB [
	"If two rectangles overlap on an axis, the shortest edge between them is straight.
	To make it aesthetically pleasing, the center of the overlap is used as the anchor.
	If there is no overlap, the edge is a diagonal between their center."

	| aL aR aT aB bL bR bT bB center |
	aL := rectA left.
	aR := rectA right.
	aT := rectA top.
	aB := rectA bottom.
	bL := rectB left.
	bR := rectB right.
	bT := rectB top.
	bB := rectB bottom.

	(aL <= bR and: [ aR >= bL and: [ aT <= bB and: [ aB >= bT ] ] ])
		ifTrue: [ "Rectangles overlap in 2D, no edge" ^ { (0 @ 0) } ].

	"Check X overlap (vertical alignment)"
	(aR > bL and: [ bR > aL ]) ifTrue: [
		center := (aL max: bL) + (aR min: bR) / 2.
		^ {
			  (center @ (aB < bT
				    ifTrue: [ aB ]
				    ifFalse: [ aT ])). "A's bottom or top"
			  (center @ (aB < bT
				    ifTrue: [ bT ]
				    ifFalse: [ bB ])) "B's top or bottom" } ].

	"Check Y overlap (horizontal alignment)"
	(aB > bT and: [ bB > aT ]) ifTrue: [
		center := (aT max: bT) + (aB min: bB) / 2.
		^ {
			  ((aR < bL
				    ifTrue: [ aR ]
				    ifFalse: [ aL ]) @ center). "A's right or left"
			  ((aR < bL
				    ifTrue: [ bL ]
				    ifFalse: [ bR ]) @ center) "B's left or right" } ].

	"No overlap, use a diagonal line"
	^ self diagonalBetween: rectA and: rectB
]

{ #category : 'initialization' }
ReplayAnnotation >> initialize [

	super initialize.
	self beTransparent.
	self borderStyle: (BorderStyle width: 5 color: Color red)
]

{ #category : 'accessing' }
ReplayAnnotation >> label [

	^ label
]

{ #category : 'accessing' }
ReplayAnnotation >> label: string [
	"To decide: Microdown or not...?"

	(label := ReplayAnnotationLabel new)
		contents: (Microdown asRichText: string);
		borderStyle: (BorderStyle color: Color red width: 1).

	line := ReplayAnnotationLine new lock
]

{ #category : 'accessing' }
ReplayAnnotation >> line [
	"The LineMorph between the highlight and the label"

	^ line
]

{ #category : 'wiw support' }
ReplayAnnotation >> morphicLayerNumber [

	^ self class morphicLayerNumber
]

{ #category : 'submorphs - accessing' }
ReplayAnnotation >> noteNewOwner: theOwner [
	"When affected to a morph to annotate, move next to it on the top right."

	(label isNil or: [ label isInWorld ]) ifTrue: [ ^ self ].
	label position:
		bounds right + 20 @ (bounds center y - (bounds height / 2)).
	label ifNotNil: [
		label openInWorld: self world.
		line openInWorld: self world ]
]

{ #category : 'initialize' }
ReplayAnnotation >> outOfWorld: aWorld [

	label ifNotNil: [ label delete ].
	line ifNotNil: [ line delete ].
	self submorphsDo: [ :m | m outOfWorld: aWorld ]
]

{ #category : 'stepping and presenter' }
ReplayAnnotation >> step [

	| vertices |
	label ifNil: [ ^ self ].

	"Trying out 'wantsToBeTopmost' instead of updating"
	"(hasMoved := lastBounds ~= bounds) ifTrue: [
		label comeToFront.
		line comeToFront ]."

	"Verify if label moved and update the line"
	vertices := self edgeBetween: self bounds and: label bounds.
	line vertices = vertices ifTrue: [ ^ self ].
	line setVertices: vertices

	"hasMoved ifFalse: [ line comeToFront ]"
]

{ #category : 'accessing' }
ReplayAnnotation >> wantsToBeTopmost [
	"Not sure about this, maybe stepping with comeToFront on updates instead?"

	^ true
]
