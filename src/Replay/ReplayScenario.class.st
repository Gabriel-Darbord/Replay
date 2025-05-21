"
I represent a user interaction scenario.
A scenario is composed of `ReplayStep`s that are executed sequentially.
I can be run by a `ReplayRunner` and edited by a `ReplayEditor`.
"
Class {
	#name : 'ReplayScenario',
	#superclass : 'Object',
	#instVars : [
		'title',
		'steps',
		'description'
	],
	#category : 'Replay',
	#package : 'Replay'
}

{ #category : 'examples' }
ReplayScenario class >> example [
	"Scenarios are conveniently stored as STON strings"

	<example>
	(STON fromString:
		 'ReplayScenario{#title:''Example Scenario'',#steps:OrderedCollection[ReplayStep{#actions:OrderedCollection[ReplayBrowseClass{#target:#ReplayScenario},ReplayAnnotate{#path:[3,6,1,3,7,1,3],#text:''Where the magic happens.''}],#navigation:ReplayNavigate{#skip:false,#acceptLabel:''Next'',#cancelLabel:''Stop'',#text:''Thus concludes this example.''}}],#description:''''}')
		run
]

{ #category : 'adding' }
ReplayScenario >> addStep: step [

	^ self steps add: step
]

{ #category : 'accessing' }
ReplayScenario >> description [

	^ description ifNil: [ description := '' ]
]

{ #category : 'accessing' }
ReplayScenario >> description: aString [

	description := aString
]

{ #category : 'editing' }
ReplayScenario >> edit [

	^ (ReplayEditor on: self) open
]

{ #category : 'editing' }
ReplayScenario >> editionPresenterOn: editor [

	| titlePresenter descriptionPresenter |
	(titlePresenter := SpTextPresenter new)
		text: self title;
		whenTextChangedDo: [ :aString | self title: aString ].

	(descriptionPresenter := SpTextPresenter new)
		text: self description;
		whenTextChangedDo: [ :aString | self description: aString ].

	^ SpPresenter new
		  layout: (SpBoxLayout newTopToBottom
				   add: 'Title:' expand: false;
				   add: titlePresenter expand: false;
				   add: 'Description:' expand: false;
				   add: descriptionPresenter;
				   yourself);
		  yourself
]

{ #category : 'running' }
ReplayScenario >> run [

	^ (ReplayRunner on: self) run
]

{ #category : 'accessing' }
ReplayScenario >> steps [

	^ steps ifNil: [ steps := OrderedCollection new ]
]

{ #category : 'accessing' }
ReplayScenario >> steps: aCollection [

	steps := aCollection
]

{ #category : 'accessing' }
ReplayScenario >> title [

	^ title ifNil: [ title := 'Unnamed Scenario' ]
]

{ #category : 'accessing' }
ReplayScenario >> title: aString [

	title := aString
]
