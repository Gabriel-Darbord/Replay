"
I adapt Replay UI management and target resolution for directly managed Morphic morphs: my morph is the managed UI, and the native element of my resolved targets is their morph.
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
