Extension { #name : 'KMComposedModifier' }

{ #category : '*Replay' }
KMComposedModifier >> replayModifiers [

	^ modifiers inject: 0 into: [ :mask :modifier | mask bitOr: modifier replayModifiers ]
]
