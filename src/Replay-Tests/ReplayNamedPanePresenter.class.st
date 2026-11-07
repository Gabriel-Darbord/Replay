"
Test helper presenter that exposes no names itself: its subpresenters are named by default after their instance variables, with a nested presenter that has an 'items' list too.
"
Class {
	#name : 'ReplayNamedPanePresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'items',
		'details'
	],
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'layout' }
ReplayNamedPanePresenter >> defaultLayout [

	^ SpBoxLayout newLeftToRight
		  add: items;
		  add: details;
		  yourself
]

{ #category : 'accessing' }
ReplayNamedPanePresenter >> details [

	^ details
]

{ #category : 'initialization' }
ReplayNamedPanePresenter >> initializePresenters [

	items := self newList items: #( #one #two ); yourself.
	details := self instantiate: ReplayNamedDetailsPresenter
]

{ #category : 'accessing' }
ReplayNamedPanePresenter >> items [

	^ items
]
