"
UI backend for directly managed Morphic morphs.
"
Class {
	#name : 'ReplayMorphicBackend',
	#superclass : 'ReplayUIBackend',
	#instVars : [
		'morph'
	],
	#category : 'Replay-Backends',
	#package : 'Replay',
	#tag : 'Backends'
}

{ #category : 'instance creation' }
ReplayMorphicBackend class >> on: aMorph [

	^ self new
		  morph: aMorph;
		  yourself
]

{ #category : 'accessing' }
ReplayMorphicBackend >> managedUI [

	^ morph
]

{ #category : 'accessing' }
ReplayMorphicBackend >> morph [

	^ morph
]

{ #category : 'accessing' }
ReplayMorphicBackend >> morph: aMorph [

	morph := aMorph
]

{ #category : 'accessing' }
ReplayMorphicBackend >> resolver [

	^ ReplayMorphicResolver on: self
]

{ #category : 'accessing' }
ReplayMorphicBackend >> root [

	^ morph
]

{ #category : 'accessing' }
ReplayMorphicBackend >> surfaceMorph [

	^ morph
]
