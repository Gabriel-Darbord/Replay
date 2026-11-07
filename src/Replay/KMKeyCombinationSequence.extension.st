Extension { #name : 'KMKeyCombinationSequence' }

{ #category : '*Replay' }
KMKeyCombinationSequence >> replayKeyBindings [
	"Every sequence of the bindings of my combinations"

	^ self sequence
		  inject: { ReplayKeyBinding new }
		  into: [ :prefixes :combination |
			  | suffixes |
			  suffixes := combination replayKeyBindings.
			  prefixes flatCollect: [ :prefix |
				  suffixes collect: [ :suffix | prefix , suffix ] ] ]
]
