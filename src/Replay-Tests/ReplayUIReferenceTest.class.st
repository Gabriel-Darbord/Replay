"
I test ReplayUIReference descriptions, shown to users when a target cannot be found.
"
Class {
	#name : 'ReplayUIReferenceTest',
	#superclass : 'TestCase',
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'tests' }
ReplayUIReferenceTest >> testDescription [

	self assert: (ReplayUIReference named: 'Hello button') description equals: 'the presenter named ''Hello button'''.
	self assert: (ReplayUIReference morphicPath: #( 2 1 )) description equals: 'the morph at path #(2 1)'.
	self assert: ReplayUIReference keyboardFocus description equals: 'the morph with the keyboard focus'.
	self assert: ReplayUIReference world description equals: 'the World'
]
