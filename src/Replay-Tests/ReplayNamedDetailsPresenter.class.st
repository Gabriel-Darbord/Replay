"
Test helper presenter nested in a ReplayNamedPanePresenter, whose subpresenters are named by default after their instance variables.
"
Class {
	#name : 'ReplayNamedDetailsPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'items',
		'runButton'
	],
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'layout' }
ReplayNamedDetailsPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: items;
		  add: runButton expand: false;
		  yourself
]

{ #category : 'initialization' }
ReplayNamedDetailsPresenter >> initializePresenters [

	items := self newList items: #( #detail ); yourself.
	runButton := self newButton label: 'Run'; yourself
]

{ #category : 'accessing' }
ReplayNamedDetailsPresenter >> items [

	^ items
]

{ #category : 'accessing' }
ReplayNamedDetailsPresenter >> runButton [

	^ runButton
]
