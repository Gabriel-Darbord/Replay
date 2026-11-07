"
I edit a ReplayScroll: after its target, its direction ('Action direction'), count ('Action count'), modifiers and offset from the top-left corner of the target ('Action x', 'Action y').
"
Class {
	#name : 'ReplayScrollEditor',
	#superclass : 'ReplayPointerActionEditor',
	#category : 'Replay-Editing',
	#package : 'Replay',
	#tag : 'Editing'
}

{ #category : 'building' }
ReplayScrollEditor >> addFieldsTo: aLayout [

	aLayout
		add: (self
				 choiceField: 'direction'
				 label: 'Scroll direction:'
				 choices: action class directionChoices
				 get: [ action direction ]
				 set: [ :aSymbol | action direction: aSymbol ])
		expand: false;
		add: (self
				 positiveIntegerField: 'count'
				 label: 'Scroll count:'
				 get: [ action count ]
				 set: [ :anInteger | action count: anInteger ])
		expand: false;
		add: self modifiersField expand: false;
		add: (self
				 pointField: nil
				 label: 'Offset from target top-left:'
				 get: [ action positionOrZero ]
				 set: [ :aPoint | action position: aPoint ])
		expand: false
]
