"
I place the labels of the annotations (ReplayAnnotation) of an overlay, the overlay of a ReplayUIManager, so that they stay readable: in the visible area of the World, off their target, and off the targets and labels of the other annotations.

Each label has eight candidate placements around its target, in the order the automatic placement prefers them: right, left, below, above, below right, above right, below left and above left. An explicit placement comes first, then the others as fallbacks. Each candidate is clamped into the layout bounds and scored; the best one wins.
"
Class {
	#name : 'ReplayAnnotationLayout',
	#superclass : 'Object',
	#instVars : [
		'overlay'
	],
	#category : 'Replay-Morphs',
	#package : 'Replay',
	#tag : 'Morphs'
}

{ #category : 'instance creation' }
ReplayAnnotationLayout class >> on: anOverlayMorph [

	^ self new
		  setOverlay: anOverlayMorph;
		  yourself
]

{ #category : 'accessing' }
ReplayAnnotationLayout >> annotationsWithLabels [

	^ overlay submorphs select: [ :each |
		  (each isKindOf: ReplayAnnotation) and: [ each hasLabel ] ]
]

{ #category : 'candidates' }
ReplayAnnotationLayout >> automaticLabelCandidatesFor: anAnnotation [

	^ (self labelCandidatesByPlacementFor: anAnnotation) values
]

{ #category : 'placing' }
ReplayAnnotationLayout >> bestLabelBoundsFor: anAnnotation avoiding: placedBounds [

	| layoutBounds targetBounds bestBounds bestScore |
	layoutBounds := self layoutBoundsFor: anAnnotation.
	targetBounds := anAnnotation targetBoundsInWorld.
	self fitLabelOf: anAnnotation within: layoutBounds.
	(self labelCandidatesFor: anAnnotation) withIndexDo: [ :rawBounds :index |
		| candidateBounds score |
		candidateBounds := self clampRectangle: rawBounds within: layoutBounds.
		score := self
			         scoreLabelBounds: candidateBounds
			         rawBounds: rawBounds
			         target: targetBounds
			         avoiding: placedBounds
			         preference: index.
		(bestScore isNil or: [ score < bestScore ]) ifTrue: [
			bestScore := score.
			bestBounds := candidateBounds ] ].
	^ bestBounds
]

{ #category : 'placing' }
ReplayAnnotationLayout >> clampRectangle: aRectangle within: containerBounds [

	| x y |
	x := containerBounds width >= aRectangle width
		     ifTrue: [ (aRectangle left max: containerBounds left) min: containerBounds right - aRectangle width ]
		     ifFalse: [ containerBounds left ].
	y := containerBounds height >= aRectangle height
		     ifTrue: [ (aRectangle top max: containerBounds top) min: containerBounds bottom - aRectangle height ]
		     ifFalse: [ containerBounds top ].
	^ x @ y extent: aRectangle extent
]

{ #category : 'placing' }
ReplayAnnotationLayout >> distanceFrom: firstPoint to: secondPoint [

	^ (firstPoint x - secondPoint x) abs + (firstPoint y - secondPoint y) abs
]

{ #category : 'placing' }
ReplayAnnotationLayout >> fitLabelOf: anAnnotation within: layoutBounds [

	| maxWidth |
	anAnnotation label ifNil: [ ^ self ].
	maxWidth := layoutBounds width - (self labelMargin * 2).
	maxWidth := maxWidth max: 80.
	anAnnotation label fitWidth: maxWidth
]

{ #category : 'candidates' }
ReplayAnnotationLayout >> labelCandidatesByPlacementFor: anAnnotation [
	"The bounds of the label of anAnnotation at each explicit placement, in the order automatic placement prefers them"

	| target extent margin centeredX centeredY right left below above |
	target := anAnnotation targetBoundsInWorld.
	extent := anAnnotation label extent.
	margin := self labelMargin.
	centeredX := target center x - (extent x / 2).
	centeredY := target center y - (extent y / 2).
	right := target right + margin.
	left := target left - extent x - margin.
	below := target bottom + margin.
	above := target top - extent y - margin.
	^ OrderedDictionary new
		  at: #right put: (right @ centeredY extent: extent);
		  at: #left put: (left @ centeredY extent: extent);
		  at: #below put: (centeredX @ below extent: extent);
		  at: #above put: (centeredX @ above extent: extent);
		  at: #belowRight put: (right @ below extent: extent);
		  at: #aboveRight put: (right @ above extent: extent);
		  at: #belowLeft put: (left @ below extent: extent);
		  at: #aboveLeft put: (left @ above extent: extent);
		  yourself
]

{ #category : 'candidates' }
ReplayAnnotationLayout >> labelCandidatesFor: anAnnotation [
	"The bounds of the placement of anAnnotation first, if it is explicit, then the other candidates"

	| candidates preferred |
	candidates := self labelCandidatesByPlacementFor: anAnnotation.
	preferred := candidates at: anAnnotation placement ifAbsent: [ ^ candidates values ].
	^ { preferred } , (candidates values reject: [ :candidate | candidate = preferred ])
]

{ #category : 'accessing' }
ReplayAnnotationLayout >> labelMargin [

	^ 20
]

{ #category : 'placing' }
ReplayAnnotationLayout >> layoutAnnotations [
	"Place the label of each annotation, avoiding the targets of all of them and the labels already placed"

	| placedBounds annotations |
	annotations := self annotationsWithLabels.
	placedBounds := annotations collect: [ :annotation | annotation targetBoundsInWorld ] as: OrderedCollection.
	annotations do: [ :annotation |
		| bestBounds |
		annotation ensureLabelInWorld.
		annotation label isInWorld ifTrue: [
			bestBounds := self bestLabelBoundsFor: annotation avoiding: placedBounds.
			annotation placeLabelAt: bestBounds origin.
			annotation step.
			placedBounds add: annotation label bounds ] ]
]

{ #category : 'accessing' }
ReplayAnnotationLayout >> layoutBounds [
	"The visible area of the World, or my overlay out of the World"

	| world |
	world := overlay world.
	world ifNil: [ ^ overlay bounds ].
	^ world visibleClearArea
]

{ #category : 'accessing' }
ReplayAnnotationLayout >> layoutBoundsFor: anAnnotation [
	"My layout bounds, grown to my overlay when the target of anAnnotation is out of them"

	| layoutBounds targetBounds |
	layoutBounds := self layoutBounds.
	targetBounds := anAnnotation targetBoundsInWorld.
	(layoutBounds containsRect: targetBounds) ifTrue: [ ^ layoutBounds ].
	overlay world ifNil: [ ^ layoutBounds merge: targetBounds ].
	^ layoutBounds merge: overlay boundsInWorld
]

{ #category : 'placing' }
ReplayAnnotationLayout >> scoreLabelBounds: candidateBounds rawBounds: rawBounds target: targetBounds avoiding: placedBounds preference: preferenceIndex [
	"Lower is better: prefer earlier candidates, moved the least by clamping, off the target and the placed bounds, and close to the target"

	| score |
	score := preferenceIndex * 1000.
	score := score + ((self distanceFrom: rawBounds origin to: candidateBounds origin) * 100).
	(candidateBounds intersects: targetBounds) ifTrue: [ score := score + 100000 ].
	placedBounds do: [ :each |
		(candidateBounds intersects: each) ifTrue: [ score := score + 50000 ] ].
	score := score + (self distanceFrom: candidateBounds center to: targetBounds center).
	^ score
]

{ #category : 'initialization' }
ReplayAnnotationLayout >> setOverlay: anOverlayMorph [

	overlay := anOverlayMorph
]
