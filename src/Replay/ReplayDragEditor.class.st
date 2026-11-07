"
I edit a ReplayDrag: after its target, its buttons and modifiers, its start and end offsets from the top-left corner of the target ('Action start x', 'Action start y', 'Action end x', 'Action end y') and its number of move steps ('Action steps').
"
Class {
	#name : 'ReplayDragEditor',
	#superclass : 'ReplayPointerActionEditor',
	#category : 'Replay-Editing',
	#package : 'Replay',
	#tag : 'Editing'
}

{ #category : 'building' }
ReplayDragEditor >> addFieldsTo: aLayout [

	aLayout
		add: self buttonsField expand: false;
		add: self modifiersField expand: false;
		add: (self
				 pointField: 'start'
				 label: 'Start offset:'
				 get: [ action startPositionOrZero ]
				 set: [ :aPoint | action startPosition: aPoint ])
		expand: false;
		add: (self
				 pointField: 'end'
				 label: 'End offset:'
				 get: [ action endPositionOrZero ]
				 set: [ :aPoint | action endPosition: aPoint ])
		expand: false;
		add: (self
				 positiveIntegerField: 'steps'
				 label: 'Move steps:'
				 get: [ action steps ]
				 set: [ :anInteger | action steps: anInteger ])
		expand: false
]
