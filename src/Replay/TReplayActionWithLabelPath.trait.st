"
I add a path of labels to actions that find a UI element by the text it shows, such as an item of a tree or of a menu with submenus. A single label is a path of one label.

The path is written as one string with ' > ' between labels, as in 'Refactorings > Rename', for editing (see labelPath).
"
Trait {
	#name : 'TReplayActionWithLabelPath',
	#instVars : [
		'labels'
	],
	#category : 'Replay-Traits',
	#package : 'Replay',
	#tag : 'Traits'
}

{ #category : 'error handling' }
TReplayActionWithLabelPath >> ensureLabels [

	self labels ifEmpty: [
		ReplayError new
			messageText: self class displayName , ' needs the label of the element to find.';
			subject: self;
			signal ]
]

{ #category : 'accessing' }
TReplayActionWithLabelPath >> labelPath [
	"My labels as one string"

	^ self labelSeparator join: self labels
]

{ #category : 'accessing' }
TReplayActionWithLabelPath >> labelPath: aString [

	self labels: (((aString splitOn: self labelSeparator) collect: [ :label |
			  label trimBoth ]) reject: [ :label | label isEmpty ])
]

{ #category : 'accessing' }
TReplayActionWithLabelPath >> labelSeparator [
	"Separates my labels when they are written as one string"

	^ ' > '
]

{ #category : 'accessing' }
TReplayActionWithLabelPath >> labels [
	"The labels of the path to my element, from the outermost"

	^ labels ifNil: [ #(  ) ]
]

{ #category : 'accessing' }
TReplayActionWithLabelPath >> labels: aCollection [

	labels := aCollection asArray
]

{ #category : 'error handling' }
TReplayActionWithLabelPath >> missingLabel: aString in: aDescription among: shownLabels [
	"Signal that no element labelled aString is in the element described by aDescription, which shows shownLabels"

	| shown |
	shown := (shownLabels first: (shownLabels size min: 10)) collect: [ :label |
		         label printString ].
	shownLabels size > 10 ifTrue: [ shown := shown copyWith: '...' ].
	ReplayMissingUIError new
		messageText: 'No item labelled ' , aString printString , ' in ' , aDescription
			, (shownLabels
					 ifEmpty: [ ', which has no items.' ]
					 ifNotEmpty: [ ', which shows ' , (', ' join: shown) , '.' ]);
		subject: self;
		signal
]
