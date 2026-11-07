Extension { #name : 'KMKeyCombinationChoice' }

{ #category : '*Replay' }
KMKeyCombinationChoice >> replayKeyBindings [
	"The bindings of each of my alternatives"

	^ Array streamContents: [ :stream |
		  self combinationsDo: [ :combination |
			  stream nextPutAll: combination replayKeyBindings ] ]
]
