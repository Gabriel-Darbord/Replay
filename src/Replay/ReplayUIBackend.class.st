"
Abstract base for UI backend adapters used by ReplayUIManager.
"
Class {
	#name : 'ReplayUIBackend',
	#superclass : 'Object',
	#category : 'Replay-Backends',
	#package : 'Replay',
	#tag : 'Backends'
}

{ #category : 'accessing' }
ReplayUIBackend >> managedPresenter [

	^ nil
]

{ #category : 'accessing' }
ReplayUIBackend >> managedUI [

	^ nil
]

{ #category : 'resolving' }
ReplayUIBackend >> resolve: aReference thenDo: foundBlock onMissing: missingBlock [

	^ self resolver
		resolve: aReference
		thenDo: foundBlock
		onMissing: missingBlock
]

{ #category : 'accessing' }
ReplayUIBackend >> resolver [

	^ ReplayUIResolver on: self
]

{ #category : 'accessing' }
ReplayUIBackend >> root [

	^ self managedUI
]

{ #category : 'accessing' }
ReplayUIBackend >> semanticScriptReceiver [

	^ nil
]

{ #category : 'accessing' }
ReplayUIBackend >> surfaceMorph [

	^ self managedUI
]
