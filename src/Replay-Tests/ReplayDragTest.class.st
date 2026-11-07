"
Tests for ReplayDrag on live widgets: drag detection by the hand, and drag and drop through the overlay of a Replay managed UI.
"
Class {
	#name : 'ReplayDragTest',
	#superclass : 'ReplayTestCase',
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'support' }
ReplayDragTest >> drawOffscreen: aMorph [
	"Lists create their rows when drawn, which a headless image never does by itself"

	aMorph fullDrawOn: (Form extent: aMorph extent depth: 32) getCanvas
]

{ #category : 'support' }
ReplayDragTest >> gesturesOfDragFrom: startOffset to: endOffset [

	| target |
	target := ReplayClickOrDragMorph new.
	target openInWorld.
	[
		ReplayDrag new
			startPosition: startOffset;
			endPosition: endOffset;
			dragOn: target ] ensure: [ target delete ].
	^ target gestures asArray
]

{ #category : 'tests' }
ReplayDragTest >> testDragAndDropBetweenListsUnderTheOverlay [

	| source destination container manager |
	source := SpListPresenter new
		          items: #( #one #two );
		          dragEnabled: true;
		          yourself.
	destination := SpListPresenter new
		               items: #(  );
		               dropEnabled: true;
		               wantsDrop: [ :transfer | true ];
		               yourself.
	destination acceptDrop: [ :transfer |
		destination items: destination items , transfer passenger asArray ].
	container := SpPresenter new.
	container layout: (SpBoxLayout newLeftToRight
			 add: source;
			 add: destination;
			 yourself).
	manager := ReplayUIManager new managePresenter: container.
	"The World of a headless image is small, and rejects a drop outside its bounds"
	manager
		openLabeled: 'Drag and drop'
		placement: (ReplayPlacement bounds: (0 @ 0 extent: 240 @ 120)).
	[
		| sourceMorph |
		manager settleUI.
		sourceMorph := source adapter widget.
		self drawOffscreen: sourceMorph.
		ReplayDrag new
			startPosition: 20 @ 10;
			endPosition: destination adapter widget center - sourceMorph topLeft;
			steps: 3;
			dragOn: sourceMorph.
		self assert: destination items asArray equals: #( #one ) ]
		ensure: [ manager close ]
]

{ #category : 'tests' }
ReplayDragTest >> testHandEndsGestureWithoutState [

	| hand carried focus |
	hand := ReplayHandMorph at: 0 @ 0 in: self currentWorld.
	focus := Morph new.
	carried := Morph new.
	hand mouseFocus: focus.
	hand addMorph: carried.
	hand endGesture.
	self deny: hand hasSubmorphs.
	self assert: hand mouseFocus isNil
]

{ #category : 'tests' }
ReplayDragTest >> testLongDragStartsADrag [

	self
		assert: (self gesturesOfDragFrom: 10 @ 10 to: 60 @ 40)
		equals: #( #mouseDown #startDrag #mouseUp )
]

{ #category : 'tests' }
ReplayDragTest >> testOverlayLetsOnlyReplayHandEventsThrough [

	| overlay |
	overlay := ReplayOverlayMorph new.
	self assert: (overlay rejectsEvent: (MouseMoveEvent new
				  setType: #mouseMove startPoint: 0 @ 0 endPoint: 1 @ 1 trail: #(  ) buttons: 0
				  hand: (ReplayHandMorph at: 0 @ 0 in: self currentWorld)
				  stamp: 0)).
	self deny: (overlay rejectsEvent: (MouseMoveEvent new
				  setType: #mouseMove startPoint: 0 @ 0 endPoint: 1 @ 1 trail: #(  ) buttons: 0
				  hand: HandMorph new
				  stamp: 0))
]

{ #category : 'tests' }
ReplayDragTest >> testShortDragIsAClickAndDeliversTheMouseUp [
	"Below the drag threshold of the hand, the gesture is a click. The hand holds the mouse up back while it waits for a double click, and still delivers it."

	self
		assert: (self gesturesOfDragFrom: 10 @ 10 to: 13 @ 12)
		equals: #( #mouseDown #click #mouseUp )
]
