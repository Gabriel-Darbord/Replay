"
A presenter for switching between different views.
```script
ReplayViewSwitcherPresenter example close adapter widget
```

% make space
 
```pharoeval
ReplayViewSwitcherPresenter example
```
"
Class {
	#name : 'ReplayViewSwitcherPresenter',
	#superclass : 'SpPresenter',
	#category : 'Replay',
	#package : 'Replay'
}

{ #category : 'examples' }
ReplayViewSwitcherPresenter class >> example [

	<example>
	^ (ReplayViewSwitcherPresenter new
		   setViews: {
				   ('First' -> (SpTextPresenter new text: 'A first presenter')).
				   ('Second' -> (SpTextPresenter new text:
							     'Cannot select this view from the class comment (because it is a Form)')) };
		   asWindow)
		  initialExtent: 420 @ 100;
		  title: 'View Switcher Example';
		  open
]

{ #category : 'api - focus' }
ReplayViewSwitcherPresenter >> defaultKeyboardFocus [

	^ self view
]

{ #category : 'layout' }
ReplayViewSwitcherPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 10;
		  add: SpBoxLayout newLeftToRight hAlignCenter expand: false;
		  add: SpBoxLayout new "To be replaced"
	"For some reason, hAlignCenter makes the buttons have a minimum size larger than normal"
]

{ #category : 'accessing' }
ReplayViewSwitcherPresenter >> selectViewAt: index [

	(self switcher presenterAt: index) state: true
]

{ #category : 'initialization' }
ReplayViewSwitcherPresenter >> setViews: namesAndActions [

	| buttons |
	self switcher removeAll.
	self switchView: self newPresenter.

	namesAndActions do: [ :nameAndAction |
		| action |
		action := nameAndAction value.
		self switcher add: (self newRadioButton
				 label: nameAndAction key;
				 whenChangedDo: [ :state |
					 state ifTrue: [ self switchView: action value ] ]) ].

	(buttons := self switcher children) first associatedRadioButtons:
		buttons.
	buttons first state: true
]

{ #category : 'initialization' }
ReplayViewSwitcherPresenter >> switchView: presenter [

	layout replaceAtIndex: 2 with: presenter
]

{ #category : 'layout' }
ReplayViewSwitcherPresenter >> switcher [

	^ self layout presenterAt: 1
]

{ #category : 'initialization' }
ReplayViewSwitcherPresenter >> view [

	^ self layout presenterAt: 2
]
