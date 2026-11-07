"
I edit the data of a scenario, my model: its title and its description, registered as 'Scenario title' and 'Scenario description'. A ReplayEditor shows me in its right pane.

The block of whenTitleChangedDo: is evaluated after each edit of the title, which names the macro of a scenario in a library.
"
Class {
	#name : 'ReplayScenarioDataEditor',
	#superclass : 'SpPresenter',
	#instVars : [
		'scenario',
		'titleInput',
		'descriptionText',
		'titleChangeBlock'
	],
	#category : 'Replay-Editing',
	#package : 'Replay',
	#tag : 'Editing'
}

{ #category : 'layout' }
ReplayScenarioDataEditor >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: 'Title:' expand: false;
		  add: titleInput expand: false;
		  add: 'Description:' expand: false;
		  add: descriptionText;
		  yourself
]

{ #category : 'accessing' }
ReplayScenarioDataEditor >> descriptionText [

	^ descriptionText
]

{ #category : 'initialization' }
ReplayScenarioDataEditor >> initializePresenters [

	titleInput := self newTextInput
		              text: scenario title;
		              whenTextChangedDo: [ :aString |
			              scenario title: aString.
			              titleChangeBlock ifNotNil: [ titleChangeBlock value ] ];
		              yourself.
	descriptionText := self newText
		                   text: scenario description;
		                   whenTextChangedDo: [ :aString | scenario description: aString ];
		                   yourself
]

{ #category : 'semantic names' }
ReplayScenarioDataEditor >> replayPresenterAt: aPresenterName ifAbsent: absentBlock [

	aPresenterName = 'Scenario title' ifTrue: [ ^ titleInput ].
	aPresenterName = 'Scenario description' ifTrue: [ ^ descriptionText ].
	^ absentBlock value
]

{ #category : 'initialization' }
ReplayScenarioDataEditor >> setModelBeforeInitialization: aScenario [

	scenario := aScenario
]

{ #category : 'accessing' }
ReplayScenarioDataEditor >> titleInput [

	^ titleInput
]

{ #category : 'events' }
ReplayScenarioDataEditor >> whenTitleChangedDo: aBlock [

	titleChangeBlock := aBlock
]
