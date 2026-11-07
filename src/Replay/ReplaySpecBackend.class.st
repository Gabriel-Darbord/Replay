"
I adapt Replay UI management and target resolution for Spec presenters rendered through Morphic: my presenter is the managed presenter, which exposes semantic names, and my morph, its rendered widget, is the managed UI. The native element of targets resolved by name is their presenter.
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
ReplaySpecBackend >> semanticScriptReceiver [

	^ presenter
]
