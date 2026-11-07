"
I am the hand of the synthetic mouse events of Replay pointer actions.

I am not a hand of the World, so a replay does not move the pointer or the mouse focus of the user, but the World is my owner: the events I handle go through the usual Morphic processing, with click and drag detection, morphs grabbed by a drag and dropped on mouse up.
Replay overlays block the events of the user but let mine through to the UI they cover.

A gesture starts by giving the mouse focus to the morph that handles it, and ends with endGesture, which leaves no state behind.
"
Class {
	#name : 'ReplayHandMorph',
	#superclass : 'HandMorph',
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'instance creation' }
ReplayHandMorph class >> at: aPoint in: aWorld [

	^ self new
		  position: aPoint;
		  privateOwner: aWorld;
		  yourself
]

{ #category : 'events' }
ReplayHandMorph >> endGesture [
	"Finish the current gesture: handle the events held back by click detection, such as a mouse up, then forget the click state, drop what I still carry and release the mouse focus"

	self handleQueuedEvents.
	self resetClickState.
	self hasSubmorphs ifTrue: [ self dropMorphs ].
	self releaseMouseFocus
]

{ #category : 'events' }
ReplayHandMorph >> handleQueuedEvents [
	"Handle the events queued while handling others. Hands of the World handle them in later UI cycles, which never come for me."

	| event |
	[ (event := self pendingEventQueue nextOrNil) isNotNil ] whileTrue: [
		event == #invalid ifFalse: [ self handleEvent: event ] ]
]

{ #category : 'testing' }
ReplayHandMorph >> isReplayHand [

	^ true
]
