"
I resolve ReplayUIReference values against a Morphic surface using semantic names when possible and morph paths otherwise.
"
Class {
	#name : 'ReplayMorphicResolver',
	#superclass : 'ReplayUIResolver',
	#category : 'Replay-Backends',
	#package : 'Replay',
	#tag : 'Backends'
}

{ #category : 'resolving' }
ReplayMorphicResolver >> resolve: aReference thenDo: foundBlock onMissing: missingBlock [

	aReference isMorphicPath ifFalse: [
		^ self
			missingReference: aReference
			reason: 'Morphic backend can only resolve Morphic path references.'
			onMissing: missingBlock ].
	^ ReplayUIPathResolver new
		root: backend surfaceMorph;
		path: aReference value;
		scheduleWith: [ :block | backend defer: block ];
		whenFound: [ :morph |
			foundBlock value: (self
				resolvedElementFor: aReference
				nativeElement: morph
				morph: morph) ];
		whenMissing: missingBlock;
		resolve
]

{ #category : 'testing' }
ReplayMorphicResolver >> supportsReference: aReference [

	^ aReference isMorphicPath
]
