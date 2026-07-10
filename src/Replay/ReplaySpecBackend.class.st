"
UI backend for Spec presenters rendered as Morphic widgets.
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
