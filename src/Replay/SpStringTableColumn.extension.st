Extension { #name : 'SpStringTableColumn' }

{ #category : '*Replay' }
SpStringTableColumn >> replayLabelOf: anItem [

	^ (self readObject: anItem) asString
]
