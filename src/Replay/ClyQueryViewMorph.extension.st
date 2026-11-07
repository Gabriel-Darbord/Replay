Extension { #name : 'ClyQueryViewMorph' }

{ #category : '*Replay' }
ClyQueryViewMorph >> replayIsStillLoading [

	^ self areItemsLoaded not
]
