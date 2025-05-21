Class {
	#name : 'BaselineOfReplay',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfReplay',
	#package : 'BaselineOfReplay'
}

{ #category : 'baselines' }
BaselineOfReplay >> baseline: spec [

	<baseline>
	spec for: #common do: [
		spec
			package: 'Replay';
			package: 'Replay-Tests' with: [ spec requires: 'Replay' ] ]
]
