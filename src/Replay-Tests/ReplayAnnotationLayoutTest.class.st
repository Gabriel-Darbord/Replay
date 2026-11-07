"
Tests for ReplayAnnotationLayout: the candidate placements of annotation labels, the fallbacks of an explicit placement, clamping, and the placement of the labels of an overlay out of the World.
"
Class {
	#name : 'ReplayAnnotationLayoutTest',
	#superclass : 'TestCase',
	#instVars : [
		'overlay',
		'layout'
	],
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'support' }
ReplayAnnotationLayoutTest >> annotationAt: aRectangle placement: aSymbol [

	| annotation |
	annotation := ReplayAnnotation annotate: aRectangle label: 'Label'.
	annotation placement: aSymbol.
	overlay addMorph: annotation.
	^ annotation
]

{ #category : 'running' }
ReplayAnnotationLayoutTest >> setUp [

	super setUp.
	overlay := Morph new bounds: (0 @ 0 extent: 600 @ 400).
	layout := ReplayAnnotationLayout on: overlay
]

{ #category : 'tests' }
ReplayAnnotationLayoutTest >> testAutomaticPlacementTriesEveryPlacementInPreferenceOrder [

	| annotation candidates byPlacement |
	annotation := self annotationAt: (200 @ 150 extent: 50 @ 30) placement: #automatic.
	byPlacement := layout labelCandidatesByPlacementFor: annotation.

	candidates := layout labelCandidatesFor: annotation.

	self assert: byPlacement keys asArray equals: #( #right #left #below #above #belowRight #aboveRight #belowLeft #aboveLeft ).
	self assert: candidates asArray equals: byPlacement values asArray
]

{ #category : 'tests' }
ReplayAnnotationLayoutTest >> testCandidatesSurroundTheTargetAtTheMargin [

	| annotation target extent margin byPlacement |
	annotation := self annotationAt: (200 @ 150 extent: 50 @ 30) placement: #automatic.
	target := annotation targetBoundsInWorld.
	extent := annotation label extent.
	margin := layout labelMargin.
	byPlacement := layout labelCandidatesByPlacementFor: annotation.

	self assert: (byPlacement at: #right) left equals: target right + margin.
	self assert: (byPlacement at: #left) right equals: target left - margin.
	self assert: (byPlacement at: #below) top equals: target bottom + margin.
	self assert: (byPlacement at: #above) bottom equals: target top - margin.
	self assert: (byPlacement at: #aboveLeft) bottomRight equals: target topLeft - margin.
	self assert: (byPlacement at: #belowRight) topLeft equals: target bottomRight + margin.
	byPlacement do: [ :each | self assert: each extent equals: extent ]
]

{ #category : 'tests' }
ReplayAnnotationLayoutTest >> testClampKeepsRectanglesInsideTheContainer [

	| container |
	container := 0 @ 0 extent: 100 @ 100.

	self
		assert: (layout clampRectangle: (90 @ -10 extent: 20 @ 20) within: container)
		equals: (80 @ 0 extent: 20 @ 20).
	self
		assert: (layout clampRectangle: (10 @ 10 extent: 200 @ 20) within: container)
		equals: (0 @ 10 extent: 200 @ 20)
]

{ #category : 'tests' }
ReplayAnnotationLayoutTest >> testExplicitPlacementComesFirstThenTheOthers [

	| annotation candidates byPlacement |
	annotation := self annotationAt: (200 @ 150 extent: 50 @ 30) placement: #above.
	byPlacement := layout labelCandidatesByPlacementFor: annotation.

	candidates := layout labelCandidatesFor: annotation.

	self assert: candidates first equals: (byPlacement at: #above).
	self assert: candidates size equals: 8.
	self deny: (candidates allButFirst includes: (byPlacement at: #above)).
	self assert: candidates asSet equals: byPlacement values asSet
]

{ #category : 'tests' }
ReplayAnnotationLayoutTest >> testLayoutOutOfTheWorldUsesTheOverlayBounds [

	self assert: overlay world isNil.
	self assert: layout layoutBounds equals: overlay bounds
]

{ #category : 'tests' }
ReplayAnnotationLayoutTest >> testOnlyAnnotationsWithLabelsAreLaidOut [

	| labelled |
	labelled := self annotationAt: (10 @ 10 extent: 20 @ 20) placement: #automatic.
	overlay addMorph: (ReplayAnnotation annotate: (50 @ 50 extent: 20 @ 20)).
	overlay addMorph: Morph new.

	self assert: layout annotationsWithLabels asArray equals: { labelled }
]

{ #category : 'tests' }
ReplayAnnotationLayoutTest >> testScorePrefersCandidatesOffTheTargetAndPlacedLabels [

	| target free onTarget onPlaced placed |
	target := 100 @ 100 extent: 50 @ 50.
	free := 200 @ 100 extent: 40 @ 20.
	onTarget := 110 @ 110 extent: 40 @ 20.
	onPlaced := 200 @ 200 extent: 40 @ 20.
	placed := { 190 @ 190 extent: 60 @ 40 }.

	self
		assert: (layout scoreLabelBounds: free rawBounds: free target: target avoiding: placed preference: 2)
		< (layout scoreLabelBounds: onTarget rawBounds: onTarget target: target avoiding: placed preference: 1).
	self
		assert: (layout scoreLabelBounds: free rawBounds: free target: target avoiding: placed preference: 2)
		< (layout scoreLabelBounds: onPlaced rawBounds: onPlaced target: target avoiding: placed preference: 1)
]
