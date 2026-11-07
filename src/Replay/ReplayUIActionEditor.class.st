"
I edit an action that opens or interacts with managed UI (a ReplayUIAction). I show two views with a ReplayViewSwitcherPresenter: the fields of the action, and an interactive preview of the UI built with ReplayUIBuilder, without side effects outside the preview (`newUIEditionPresenter`, which my subclasses implement).

When the preview cannot be built, the ReplayError explains why with my help presenters (`helpAbout:`, `helpAboutMissingUI:`, `helpAboutScriptError:`, chosen by the error with `helpPresenterFor:`).

Each view registers its own semantic names: the names of a view are forgotten when the other view is shown.
"
Class {
	#name : 'ReplayUIActionEditor',
	#superclass : 'ReplayActionEditor',
	#instVars : [
		'viewSwitcher'
	],
	#category : 'Replay-Editing',
	#package : 'Replay',
	#tag : 'Editing'
}

{ #category : 'help' }
ReplayUIActionEditor >> helpAbout: error [
	"Explain an error that has no specific help"

	^ self newPresenter
		  layout: (SpBoxLayout newTopToBottom
				   spacing: 10;
				   add: (SpBoxLayout newLeftToRight
						    spacing: 10;
						    add: (self iconNamed: #error) expand: false;
						    add: 'Something went wrong, and this action is unable to help.';
						    yourself)
				   expand: false;
				   add: (SpBoxLayout newTopToBottom
						    add: ' Exception message:' expand: false;
						    add: (self newText beNotEditable text: error printString);
						    yourself);
				   add: (self newButton
						    icon: (self iconNamed: #bug);
						    label: 'Debug exception';
						    action: [ error debug ])
				   withConstraints: [ :constraints | constraints height: 70 ];
				   yourself);
		  yourself
]

{ #category : 'help' }
ReplayUIActionEditor >> helpAboutMissingUI: error [

	^ self helpAbout: error
]

{ #category : 'help' }
ReplayUIActionEditor >> helpAboutScriptError: error [
	"Explain why the script of an action failed, the one of my action or of an action that builds the preview, and offer to debug it"

	| scriptAction |
	scriptAction := error action ifNil: [ action ].
	scriptAction hasScript ifFalse: [ ^ self helpAbout: error ].
	^ self newPresenter
		  layout: (SpBoxLayout newTopToBottom
				   spacing: 10;
				   add: (SpBoxLayout newLeftToRight
						    spacing: 10;
						    add: (self iconNamed: #error) expand: false;
						    add: error messageText;
						    yourself)
				   expand: false;
				   add: (SpBoxLayout newTopToBottom
						    add: (error cause
								     ifNil: [ 'Printing the unexpected value:' ]
								     ifNotNil: [ 'Original error:' ])
						    expand: false;
						    add: (self newText
								     beWrapWord;
								     editable: false;
								     text: (error cause
										      ifNil: [ error subject printString ]
										      ifNotNil: [ :cause | cause description ]));
						    yourself);
				   add: (self debugButton: 'Debug the script' action: [
							    scriptAction class editorClass debugScriptOf: scriptAction in: self scenarioEditor ])
				   expand: false;
				   yourself);
		  yourself
]

{ #category : 'building' }
ReplayUIActionEditor >> newContentLayout [

	viewSwitcher := self instantiate: ReplayViewSwitcherPresenter.
	viewSwitcher setViews: {
			(self settingsViewName -> [
			 self resetFields.
			 self newSettingsPresenter ]).
			(self uiViewName -> [
			 self resetFields.
			 self tryNewUIEditionPresenter ]) }.
	^ SpBoxLayout newTopToBottom
		  add: viewSwitcher;
		  yourself
]

{ #category : 'building' }
ReplayUIActionEditor >> newSettingsPresenter [

	^ self newPresenter
		  layout: self newFieldsLayout;
		  yourself
]

{ #category : 'building' }
ReplayUIActionEditor >> newUIEditionPresenter [
	"The interactive preview of the UI my action works with"

	self subclassResponsibility
]

{ #category : 'accessing' }
ReplayUIActionEditor >> settingsViewName [

	^ 'Edit settings'
]

{ #category : 'building' }
ReplayUIActionEditor >> tryNewUIEditionPresenter [
	"The scenario can be in a state that prevents building the preview: then the error explains why"

	^ [ self newUIEditionPresenter ]
		  on: ReplayError
		  do: [ :error | error helpPresenterFor: self ]
]

{ #category : 'accessing' }
ReplayUIActionEditor >> uiViewName [

	^ 'Edit UI interaction'
]

{ #category : 'accessing' }
ReplayUIActionEditor >> viewSwitcher [

	^ viewSwitcher
]
