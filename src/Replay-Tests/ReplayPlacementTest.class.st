"
Tests for ReplayPlacement rules, editing, and use by opening actions.
"
Class {
	#name : 'ReplayPlacementTest',
	#superclass : 'TestCase',
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'tests' }
ReplayPlacementTest >> testActionsKeepEmptyPlacementAsNil [

	| open navigate |
	open := ReplayOpenPresenter new placement: ReplayPlacement new.
	navigate := ReplayNavigate new placement: ReplayPlacement new.

	self assert: open placement isNil.
	self assert: navigate placement isNil.
	open placement: (ReplayPlacement extent: 10 @ 20).
	self assert: open placement equals: (ReplayPlacement extent: 10 @ 20)
]

{ #category : 'tests' }
ReplayPlacementTest >> testBoundsForgetPositionAndExtent [

	| placement |
	placement := ReplayPlacement position: 12 @ 34 extent: 320 @ 140.

	placement bounds: (50 @ 70 extent: 360 @ 150).

	self assert: placement position isNil.
	self assert: placement extent isNil.
	self assert: placement requestedPosition equals: 50 @ 70.
	self assert: placement requestedExtent equals: 360 @ 150
]

{ #category : 'tests' }
ReplayPlacementTest >> testClearForgetsEverything [

	| placement |
	placement := ReplayPlacement position: 12 @ 34 extent: 320 @ 140.

	placement clear.

	self assert: placement isEmpty.
	self assert: placement requestedPosition isNil.
	self assert: placement requestedExtent isNil
]

{ #category : 'tests' }
ReplayPlacementTest >> testDimensionSetters [

	| placement |
	placement := ReplayPlacement new.
	placement extentWidth: 1083.
	placement extentHeight: 532.
	self assert: placement extent equals: 1083 @ 532.
	placement positionX: 5.
	placement positionY: 6.
	self assert: placement position equals: 5 @ 6.

	placement boundsLeft: 10.
	placement boundsTop: 20.
	placement boundsRight: 300.
	placement boundsBottom: 400.
	self assert: placement bounds equals: (10 @ 20 corner: 300 @ 400).
	self assert: placement position isNil.
	self assert: placement extent isNil
]

{ #category : 'tests' }
ReplayPlacementTest >> testEqualityComparesFields [

	self assert: (ReplayPlacement position: 1 @ 2) equals: (ReplayPlacement position: 1 @ 2).
	self assert: (ReplayPlacement position: 1 @ 2) hash equals: (ReplayPlacement position: 1 @ 2) hash.
	self deny: (ReplayPlacement position: 1 @ 2) equals: (ReplayPlacement extent: 1 @ 2)
]

{ #category : 'tests' }
ReplayPlacementTest >> testPositionAndExtentForgetBounds [

	| placement |
	placement := ReplayPlacement bounds: (50 @ 70 extent: 360 @ 150).
	placement position: 1 @ 2.
	self assert: placement bounds isNil.

	placement := ReplayPlacement bounds: (50 @ 70 extent: 360 @ 150).
	placement extent: 3 @ 4.
	self assert: placement bounds isNil
]

{ #category : 'tests' }
ReplayPlacementTest >> testPresenterEditsAnUnsetActionPlacement [

	| editor action input |
	editor := ReplayEditor on: ReplayScenario new.
	action := ReplayOpenPresenter new.
	action placementPresenterOn: editor.
	input := editor replayPresenterAt: 'Action extent width' ifAbsent: [ nil ].

	input number: 1234.

	self assert: action placement extent x equals: 1234.
	(editor replayPresenterAt: 'Action clear placement' ifAbsent: [ nil ]) click.
	self assert: action placement isNil
]
