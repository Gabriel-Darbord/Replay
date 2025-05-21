"
Simulates a mouse click on a UI element.
"
Class {
	#name : 'ReplayClick',
	#superclass : 'ReplayUIHandler',
	#traits : 'TReplayActionWithDebugging',
	#classTraits : 'TReplayActionWithDebugging classTrait',
	#instVars : [
		'buttons'
	],
	#category : 'Replay',
	#package : 'Replay'
}

{ #category : 'accessing' }
ReplayClick class >> displayName [

	^ 'Click'
]

{ #category : 'editing' }
ReplayClick >> buttonsPresenterOn: editor [

	^ SpBoxLayout newTopToBottom
		  vAlignStart;
		  add: ' Which buttons to press:';
		  add: (SpCheckBoxPresenter new
				   label: 'Left click';
				   state:
					   (buttons bitAnd: MouseEvent redButton) = MouseEvent redButton;
				   whenActivatedDo: [
					   buttons := buttons bitOr: MouseEvent redButton ];
				   whenDeactivatedDo: [
					   buttons := buttons bitClear: MouseEvent redButton ])
		  expand: false;
		  add: (SpCheckBoxPresenter new
				   label: 'Right click';
				   state:
					   (buttons bitAnd: MouseEvent yellowButton)
					   = MouseEvent yellowButton;
				   whenActivatedDo: [
					   buttons := buttons bitOr: MouseEvent yellowButton ];
				   whenDeactivatedDo: [
					   buttons := buttons bitClear: MouseEvent yellowButton ])
		  expand: false;
		  add: (SpCheckBoxPresenter new
				   label: 'Middle click';
				   state:
					   (buttons bitAnd: MouseEvent blueButton)
					   = MouseEvent blueButton;
				   whenActivatedDo: [
					   buttons := buttons bitOr: MouseEvent blueButton ];
				   whenDeactivatedDo: [
					   buttons := buttons bitClear: MouseEvent blueButton ])
		  expand: false;
		  yourself
]

{ #category : 'running' }
ReplayClick >> clickOn: ui [
	"Simulate a user click on the given Morph.
	Can still be improved:
	- right clicking opens the menu on the actual hand instead of at the UI position.
	Maybe the managed UI needs its own world...?"

	| position target hand event |
	position := ui pointInWorld: ui center.

	"Use a fake hand to keep a coherent state"
	(hand := HandMorph new)
		position: position;
		privateOwner: self currentWorld.

	(event := MouseButtonEvent new)
		setType: #mouseDown
		position: position
		which: buttons
		buttons: buttons
		hand: hand
		stamp: Time millisecondClockValue.

	"Target the first element in the owner chain that listens"
	target := ui.
	[ target handlesMouseDown: event ] whileFalse: [
		target := target owner ].
	hand mouseFocus: target.

	"A user click consists of 3 events: mouseDown, click, mouseUp"
	event sentTo: target. "mouseDown"
	target click: event. "Usually sent from the hand on mouseDown(?)"
	(event := MouseButtonEvent new)
		setType: #mouseUp
		position: position
		which: buttons
		buttons: 0
		hand: hand
		stamp: Time millisecondClockValue.
	event sentTo: target "mouseUp with all buttons released"
]

{ #category : 'debugging' }
ReplayClick >> debugClickOn: editor [

	| builder |
	builder := ReplayUIBuilder on: editor model scenario.

	builder whenDone: [
		self findElementIn: builder manager managedUI thenDo: [ :ui |
			| debugSession |
			debugSession := self debug: [ self clickOn: ui ].
			3 timesRepeat: [ debugSession stepInto ] ] ].

	"We need to open the window for the UI to load correctly"
	(SpMorphPresenter new morph:
			 (builder uiForAction: self inStep: editor model currentStep))
		asWindow
		title: 'Debugging Click Event';
		open;
		maximize
]

{ #category : 'initialization' }
ReplayClick >> initialize [

	buttons := MouseEvent redButton "left lick"
]

{ #category : 'testing' }
ReplayClick >> isClick [

	^ true
]

{ #category : 'running' }
ReplayClick >> runOn: runner onUI: ui [

	self clickOn: ui
]

{ #category : 'editing' }
ReplayClick >> settingsPresenterOn: editor [
	"So much hacking with spacing and padding just to avoid clipping..."

	^ SpPresenter new
		  layout: (SpBoxLayout newLeftToRight
				   add: (SpBoxLayout newTopToBottom
						    spacing: 10;
						    add: self pathStatePresenter expand: false;
						    add: (self buttonsPresenterOn: editor) expand: false;
						    in: [ :layout |
							    path ifNotNil: [
									    layout
										    add: (self
												     debugButtonPresenterLabeled: 'Debug the click event'
												     action: [ self debugClickOn: editor ])
										    expand: false ] ];
						    yourself)
				   withConstraints: [ :c | c padding: 10 ];
				   yourself);
		  yourself
]

{ #category : 'accessing' }
ReplayClick >> settingsViewName [

	^ 'Click settings'
]
