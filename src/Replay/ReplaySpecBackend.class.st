"
I adapt Replay UI management and target resolution for Spec presenters rendered through Morphic.
"
Class {
	#name : 'ReplaySpecBackend',
	#superclass : 'ReplayUIBackend',
	#instVars : [
		'presenter',
		'morph'
	],
	#category : 'Replay-Backends',
	#package : 'Replay',
	#tag : 'Backends'
}

{ #category : 'instance creation' }
ReplaySpecBackend class >> presenter: aSpecPresenter morph: aMorph [

	^ self new
		  presenter: aSpecPresenter;
		  morph: aMorph;
		  yourself
]

{ #category : 'testing' }
ReplaySpecBackend >> canPerformNativeClickOn: aPresenter [

	aPresenter ifNil: [ ^ false ].
	^ (aPresenter isKindOf: SpButtonPresenter)
		or: [ (aPresenter isKindOf: SpLinkPresenter)
				or: [ (aPresenter isKindOf: SpToolbarButtonPresenter)
						or: [ aPresenter isKindOf: SpToolbarToggleButtonPresenter ] ] ]
]

{ #category : 'testing' }
ReplaySpecBackend >> canRun: anAction nativelyOn: nativeElement [

	(anAction isKindOf: ReplayClick) ifTrue: [
		^ anAction isSimpleLeftClick
			and: [ self canPerformNativeClickOn: nativeElement ] ].
	(anAction isKindOf: ReplayFocus) ifTrue: [
		^ nativeElement isKindOf: SpAbstractPresenter ].
	(anAction isKindOf: ReplaySelectText) ifTrue: [
		^ anAction canSelectTextIn: nativeElement ].
	^ false
]

{ #category : 'accessing' }
ReplaySpecBackend >> managedPresenter [

	^ presenter
]

{ #category : 'accessing' }
ReplaySpecBackend >> managedUI [

	^ morph
]

{ #category : 'accessing' }
ReplaySpecBackend >> morph [

	^ morph
]

{ #category : 'accessing' }
ReplaySpecBackend >> morph: aMorph [

	morph := aMorph
]

{ #category : 'accessing' }
ReplaySpecBackend >> presenter [

	^ presenter
]

{ #category : 'accessing' }
ReplaySpecBackend >> presenter: aSpecPresenter [

	presenter := aSpecPresenter
]

{ #category : 'resolving' }
ReplaySpecBackend >> presenterNamed: aString ifAbsent: absentBlock [

	presenter ifNil: [ ^ absentBlock value ].
	^ presenter replayPresenterAt: aString ifAbsent: absentBlock
]

{ #category : 'accessing' }
ReplaySpecBackend >> resolver [

	^ ReplaySpecResolver on: self
]

{ #category : 'accessing' }
ReplaySpecBackend >> root [

	^ presenter
]

{ #category : 'running' }
ReplaySpecBackend >> runClick: aReplayClick on: aResolvedUI [

	| targetPresenter |
	targetPresenter := aResolvedUI nativeElement.
	(aReplayClick isSimpleLeftClick and: [ self canPerformNativeClickOn: targetPresenter ])
		ifTrue: [ targetPresenter performAction ]
		ifFalse: [ super runClick: aReplayClick on: aResolvedUI ]
]

{ #category : 'accessing' }
ReplaySpecBackend >> semanticScriptReceiver [

	^ presenter
]

{ #category : 'accessing' }
ReplaySpecBackend >> surfaceMorph [

	^ morph
]

{ #category : 'accessing' }
ReplaySpecBackend >> surfaceRoot [

	^ morph
]
