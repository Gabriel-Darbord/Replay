"
I edit a ReplayClick: after its target, its mouse phase ('Action phase'), buttons, modifiers, offset from the top-left corner of the target ('Action x', 'Action y') and click count ('Action count').

With a specific target, a button debugs the click: it previews the UI up to the click in a window, then opens a debugger on the click.
"
Class {
	#name : 'ReplayClickEditor',
	#superclass : 'ReplayPointerActionEditor',
	#category : 'Replay-Editing',
	#package : 'Replay',
	#tag : 'Editing'
}

{ #category : 'building' }
ReplayClickEditor >> addFieldsTo: aLayout [

	aLayout
		add: (self
				 choiceField: 'phase'
				 label: 'Mouse phase:'
				 choices: action class mousePhaseChoices
				 get: [ action mousePhase ]
				 set: [ :aSymbol | action mousePhase: aSymbol ])
		expand: false;
		add: self buttonsField expand: false;
		add: self modifiersField expand: false;
		add: (self
				 pointField: nil
				 label: 'Offset from target top-left:'
				 get: [ action positionOrZero ]
				 set: [ :aPoint | action position: aPoint ])
		expand: false;
		add: (self
				 positiveIntegerField: 'count'
				 label: 'Click count:'
				 get: [ action clickCount ]
				 set: [ :anInteger | action clickCount: anInteger ])
		expand: false.
	action hasSpecificTarget ifTrue: [
		aLayout add: (self debugButton: ' Debug click event' action: [ self debugClick ]) expand: false ]
]

{ #category : 'debugging' }
ReplayClickEditor >> debugClick [
	"Preview the UI up to my click in a window, for the UI to load correctly, then debug the click there"

	| builder |
	builder := ReplayUIBuilder on: self scenario.
	builder whenDone: [ action debugClickIn: builder manager ].
	(SpMorphPresenter new morph: (builder uiForAction: action)) asWindow
		title: 'Debugging Click Event';
		open;
		maximize
]

{ #category : 'accessing' }
ReplayClickEditor >> settingsViewName [

	^ 'Click settings'
]
