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
			package: 'Replay-Demo' with: [ spec requires: 'Replay' ];
			package: 'Replay-Tests' with: [ spec requires: 'Replay' ];
			package: 'Replay-Demo-Tests' with: [ spec requires: 'Replay-Demo' ].
		spec group: 'core' with: #( 'Replay' ).
		spec group: 'demo' with: #( 'Replay-Demo' ).
		spec group: 'tests' with: #( 'Replay-Tests' 'Replay-Demo-Tests' ).
		spec group: 'default' with: #( 'core' ) ]
]
