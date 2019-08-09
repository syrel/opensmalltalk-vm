Class {
	#name : #BaselineOfVMMaker,
	#superclass : #BaselineOf,
	#category : #BaselineOfVMMaker
}

{ #category : #baselines }
BaselineOfVMMaker >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [
			
			"Dependencies from other repositories"
			spec 
				baseline: 'Unicorn' 
				with: [ spec repository: 'github://guillep/pharo-unicorn'].
			spec 
				baseline: 'LLVMDisassembler' 
				with: [ spec repository: 'github://guillep/pharo-llvmDisassembler' ].

			spec package: 'Printf' with: [
				spec repository: 'http://www.squeaksource.com/Printf' ].

			spec
				package: 'Woodland' with: [
					spec requires: #( 'Unicorn' 'LLVMDisassembler' ) ];
				package: 'WoodlandTests' with: [ 
					spec requires: 'Woodland' ].
				
			"Main VMMaker packages"	
			spec
				package: 'VMMakerCompatibilityForPharo6';
				package: 'VMMaker' with: [ 
					spec requires: #( 'VMMakerCompatibilityForPharo6' 'Printf') ];
				package: 'Cog' with: [
					spec requires: #( 'VMMaker' 'Woodland')  ];
				package: 'VMMakerTests' with: [
					spec requires: 'VMMaker' ];
				package: 'VMMakerMT-Tests' with: [
					spec requires: #( 'VMMaker' 'Woodland')  ] ]
]
