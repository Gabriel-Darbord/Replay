Extension { #name : 'SpCompositeTableColumn' }

{ #category : '*Replay' }
SpCompositeTableColumn >> replayLabelOf: anItem [
	"The text of my first column that shows text, such as the name next to an icon"

	self columns do: [ :column |
		(column replayLabelOf: anItem) ifNotNil: [ :label | ^ label ] ].
	^ nil
]
