"
User interface for editing scenarios.
"
Class {
	#name : 'ReplayEditor',
	#superclass : 'SpPresenter',
	#instVars : [
		'model',
		'actionDropList',
		'actionEditor',
		'stepList',
		'actionList'
	],
	#category : 'Replay',
	#package : 'Replay'
}

{ #category : 'instance creation' }
ReplayEditor class >> new [

	^ self on: ReplayScenario new
]

{ #category : 'instance creation' }
ReplayEditor class >> on: scenario [

	^ self basicNew initialize scenario: scenario
]

{ #category : 'instance creation' }
ReplayEditor class >> onSton: aScenarioSTONString [

	^ self on: (STON fromString: aScenarioSTONString)
]

{ #category : 'accessing' }
ReplayEditor >> actionEditor [

	^ actionEditor presenterAt: 1
]

{ #category : 'accessing' }
ReplayEditor >> actionEditor: aPresenter [
	"That doesn't seem right, but it works (might have leak though?)"

	actionEditor replaceAtIndex: 1 with: aPresenter.
	aPresenter owner: self
]

{ #category : 'accessing' }
ReplayEditor >> actions [
	"The action list presenter"

	^ actionList
]

{ #category : 'event handling' }
ReplayEditor >> addAction [
	"When creating an action with the editable list"

	self addActionLast: actionDropList selectedItem new.
	^ nil "Do not let the editable list event add something"
]

{ #category : 'adding' }
ReplayEditor >> addAction: action after: another [

	self ensureStep.
	self model currentStep actions add: action after: another.
	actionList selectItem: action.
	actionList rebuildLayout
]

{ #category : 'adding' }
ReplayEditor >> addAction: action before: another [

	self ensureStep.
	self model currentStep actions add: action before: another.
	actionList selectItem: action.
	actionList rebuildLayout
]

{ #category : 'event handling' }
ReplayEditor >> addActionLast: action [

	self ensureStep.
	self model addAction: action.
	actionList selectIndex: actionList items size
]

{ #category : 'initialization' }
ReplayEditor >> connectPresenters [

	stepList
		addItemBlock: [ self model newStep ];
		removeItemBlock: [ :step | self removeStep: step ];
		whenSelectionChangedDo: [ :selection |
			selection selectedItem ifNotNil: [ :step | self selectStep: step ] ].

	actionList
		addItemBlock: [ self addAction ];
		removeItemBlock: [ :item | self removeAction: item ];
		whenSelectionChangedDo: [ :selection |
			selection selectedItem ifNotNil: [ :action |
					self selectAction: action ] ].

	"Create an action when it is selected in the drop list"
	actionDropList whenSelectedItemChangedDo: [ :actionClass |
		self addActionLast: actionClass new ]
]

{ #category : 'layout' }
ReplayEditor >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: self toolbar expand: false;
		  add: (SpPanedLayout newLeftToRight
				   positionOfSlider: 0.3;
				   add: (SpBoxLayout newLeftToRight
						    add: (SpBoxLayout newTopToBottom
								     add: self editScenarioButton expand: false;
								     add: stepList;
								     yourself);
						    add: (SpBoxLayout newTopToBottom
								     add: self stepNavigationEditor expand: false;
								     add: actionDropList expand: false;
								     add: actionList;
								     yourself);
						    yourself);
				   add: (SpBoxLayout newLeftToRight
						    add: actionEditor
						    withConstraints: [ :c | c padding: 10 ]);
				   yourself);
		  yourself
]

{ #category : 'tools' }
ReplayEditor >> editScenario [

	self actionEditor: (self model scenario editionPresenterOn: self)
]

{ #category : 'layout' }
ReplayEditor >> editScenarioButton [

	^ SpButtonPresenter new
		  icon: (self iconNamed: #edit);
		  label: 'Edit scenario data';
		  help: 'Edit the data of the scenario, such as its title';
		  action: [ self editScenario ]
]

{ #category : 'layout' }
ReplayEditor >> editStepNavigation [

	self actionEditor:
		(model currentStep navigation editionPresenterOn: self)
]

{ #category : 'event handling' }
ReplayEditor >> ensureStep [
	"Create a step if necessary"

	self model currentStep ifNil: [
		actionList items: model addStep actions.
		stepList selectIndex: 1.
		stepList rebuildLayout ]
]

{ #category : 'layout' }
ReplayEditor >> homePresenter [

	^ SpPresenter new
		  layout: (SpBoxLayout newTopToBottom
				   add: (SpBoxLayout newLeftToRight
						    spacing: 10;
						    add: (self iconNamed: #example) expand: false;
						    add: 'Create or select an action to edit it.';
						    yourself)
				   withConstraints: [ :c |
					   c expand: false.
					   c padding: 10 ];
				   yourself);
		  yourself
]

{ #category : 'tools' }
ReplayEditor >> importScenario [

	(self uiManager
		 request: 'Paste the STON string of a scenario to edit it.'
		 initialAnswer: ''
		 title: 'Import Scenario') ifNotEmpty: [ :string |
		self scenario: (STON fromString: string) ]
]

{ #category : 'initialization' }
ReplayEditor >> initializePresenters [

	stepList := SpEditableListPresenter new.
	actionList := SpEditableListPresenter new.

	actionDropList := self newDropList.
	actionDropList
		items: ReplayAction actionsForDropList;
		display: [ :action | action displayName ];
		help: 'Choose the type of action to add'.

	actionEditor := SpBoxLayout newLeftToRight.
	actionEditor add: self homePresenter
]

{ #category : 'initialization' }
ReplayEditor >> initializeWindow: aWindow [

	aWindow title: 'Scenario Editor'.
	aWindow initialExtent: 1200 @ 675
]

{ #category : 'accessing' }
ReplayEditor >> model [

	^ model ifNil: [ model := ReplayEditorModel new ]
]

{ #category : 'event handling' }
ReplayEditor >> removeAction: action [
	"When removing an action with the editable list"

	self removeItem: action from: actionList.
	actionList items ifEmpty: [ self actionEditor: self homePresenter ]
]

{ #category : 'event handling' }
ReplayEditor >> removeItem: item from: specList [
	"Elegantly remove an item from a Spec list"

	| items nextIndex |
	items := specList items.
	items ifEmpty: [ ^ self ].

	items size = 1 ifTrue: [ "Delete the only step in the list"
		^ specList removeItem: item "Also unselects! `items remove:` when it matters" ].

	"Select the next element, or the previous if deleted is last"
	nextIndex := (items indexOf: item) min: items size - 1.
	specList items remove: item.
	specList selectIndex: nextIndex.
	specList rebuildLayout
]

{ #category : 'event handling' }
ReplayEditor >> removeStep: step [
	"When removing a step with the editable list"

	step ifNil: [ ^ self ].
	self removeItem: step from: stepList.
	stepList items
		ifEmpty: [ "There are no more steps"
			self model currentStep: nil.
			actionList items: #(  ) "Should never try to add to this array" ]
		ifNotEmpty: [ "The selected step was changed"
			| selectedStep |
			selectedStep := stepList selectedItem.
			self model currentStep: selectedStep.
			actionList items: selectedStep actions ]
]

{ #category : 'tools' }
ReplayEditor >> runScenario [

	model scenario run
]

{ #category : 'tools' }
ReplayEditor >> runStep [

	(ReplayRunner on: model scenario) runStep: model currentStep
]

{ #category : 'tools' }
ReplayEditor >> saveScenario [

	Clipboard
		clipboardText: (STON toString: model scenario)
		informing: 'Scenario copied to clipboard!'
]

{ #category : 'accessing' }
ReplayEditor >> scenario: scenario [

	| steps |
	self model scenario: scenario.
	steps := scenario steps.
	steps ifEmpty: [ self model addStep ].
	stepList items: steps.
	stepList selectItem: steps first
]

{ #category : 'event handling' }
ReplayEditor >> selectAction: action [
	"When an action has been selected in the action list"

	self model currentAction: action.
	self actionEditor: (action editionPresenterOn: self)
]

{ #category : 'event handling' }
ReplayEditor >> selectStep: step [
	"When a step has been selected in the step list"

	model currentStep: step.
	actionList items: step actions.
	step actions
		ifEmpty: [ self actionEditor: self homePresenter ]
		ifNotEmpty: [ actionList selectIndex: 1 ]
]

{ #category : 'layout' }
ReplayEditor >> stepNavigationEditor [

	^ SpButtonPresenter new
		  icon: (self iconNamed: #edit);
		  label: 'Edit step navigation';
		  help:
			  'All steps end with a navigation action that can allow the user to continue or end the scenario';
		  action: [ self editStepNavigation ]
]

{ #category : 'accessing' }
ReplayEditor >> steps [
	"The step list presenter"

	^ stepList
]

{ #category : 'layout' }
ReplayEditor >> toolbar [
	"I wish SpToolbarPresenter made buttons of equal size"

	^ SpToolbarPresenter new
		  add: (SpToolbarButtonPresenter new
				   icon: (self iconNamed: #save);
				   label: 'Save scenario';
				   action: [ self saveScenario ]);
		  add: (SpToolbarButtonPresenter new
				   icon: (self iconNamed: #smallLoadProject);
				   label: 'Import scenario';
				   action: [ self importScenario ]);
		  add: (SpToolbarButtonPresenter new
				   icon: (self iconNamed: #smallDoIt);
				   label: 'Run scenario';
				   action: [ self runScenario ]);
		  add: (SpToolbarButtonPresenter new
				   icon: (self iconNamed: #smallForward);
				   label: 'Run step';
				   action: [ self runStep ]);
		  yourself

	"^ SpPresenter new
		  layout: (SpBoxLayout newLeftToRight
				   add: (SpButtonPresenter new
						    icon: (self iconNamed: #save);
						    label: 'Save scenario';
						    action: [ self saveScenario ]);
				   add: (SpButtonPresenter new
						    icon: (self iconNamed: #smallLoadProject);
						    label: 'Import scenario';
						    action: [ self importScenario ]);
				   add: (SpButtonPresenter new
						    icon: (self iconNamed: #smallDoIt);
						    label: 'Run scenario';
						    action: [ self runScenario ]);
				   add: (SpButtonPresenter new
						    icon: (self iconNamed: #smallForward);
						    label: 'Run step';
						    action: [ self runStep ]);
				   yourself);
		  yourself"
]
