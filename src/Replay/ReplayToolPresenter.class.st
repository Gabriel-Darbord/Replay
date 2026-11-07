"
I am the abstract superclass of the Replay tools that edit, record and run scenarios: the scenario editor (ReplayEditor) and the library window (ReplayMacroLibraryEditor).

A tool shows a single window per subject: openInstanceSuchThat:ifNone: brings the window of an open instance forward instead of opening a second one. The windows of tools are never the subject of a recording or of an attach to the active window (see ReplayAttachActiveWindow).

I work with the hand of the world by default; tests give me another hand (hand:) so that the listeners I install stay off the real one.
"
Class {
	#name : 'ReplayToolPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'hand'
	],
	#category : 'Replay-Editing',
	#package : 'Replay',
	#tag : 'Editing'
}

{ #category : 'testing' }
ReplayToolPresenter class >> isAbstract [

	^ self == ReplayToolPresenter
]

{ #category : 'testing' }
ReplayToolPresenter class >> isToolWindow: aMorph [
	"Whether aMorph is the window of a Replay tool"

	| windowPresenter |
	windowPresenter := aMorph model.
	^ (windowPresenter isKindOf: SpWindowPresenter) and: [ windowPresenter presenter isKindOf: ReplayToolPresenter ]
]

{ #category : 'accessing' }
ReplayToolPresenter class >> openInstances [
	"The tools of my kind that have their own window"

	^ (self currentWorld systemWindows collect: [ :window | window model ])
		  select: [ :model | (model isKindOf: SpWindowPresenter) and: [ model presenter isKindOf: self ] ]
		  thenCollect: [ :model | model presenter ]
]

{ #category : 'instance creation' }
ReplayToolPresenter class >> openInstanceSuchThat: aBlock ifNone: aCreationBlock [
	"Bring forward the window of the open tool for which aBlock answers true, or open the tool aCreationBlock answers. Answer the tool."

	^ self openInstances
		  detect: aBlock
		  ifFound: [ :tool |
				  tool window activate.
				  tool ]
		  ifNone: [
				  aCreationBlock value
					  open;
					  yourself ]
]

{ #category : 'accessing' }
ReplayToolPresenter >> hand [
	"The hand whose events I listen to"

	^ hand ifNil: [ self currentWorld activeHand ]
]

{ #category : 'accessing' }
ReplayToolPresenter >> hand: aHandMorph [

	hand := aHandMorph
]

{ #category : 'accessing' }
ReplayToolPresenter >> windowMorph [
	"The system window that shows me, my own or the one of the tool that embeds me, or nil when I am not shown"

	^ self adapter ifNotNil: [ :adapter |
		  adapter widget ifNotNil: [ :widget |
			  (widget isKindOf: SystemWindow)
				  ifTrue: [ widget ]
				  ifFalse: [ widget ownerThatIsA: SystemWindow ] ] ]
]
