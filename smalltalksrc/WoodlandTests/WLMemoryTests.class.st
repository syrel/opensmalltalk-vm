Class {
	#name : #WLMemoryTests,
	#superclass : #TestCase,
	#category : #WoodlandTests
}

{ #category : #tests }
WLMemoryTests >> testWriteNegativeSignedInt [

	| processor codeRegion |
	processor := WLSimulationProcessor x8664.
	codeRegion := ByteArray new: 4096.
	processor mapHostMemory: codeRegion atAddress: 0 withPermissions: UnicornConstants permissionAll.
	
	processor memoryAt: 0 writeSignedInt: -1.
	
	self assert: (processor readSignedIntAt: 0) equals: -1
]

{ #category : #tests }
WLMemoryTests >> testWritePositiveSignedInt [

	| processor codeRegion |
	processor := WLSimulationProcessor x8664.
	codeRegion := ByteArray new: 4096.
	processor mapHostMemory: codeRegion atAddress: 0 withPermissions: UnicornConstants permissionAll.
	
	processor memoryAt: 0 writeSignedInt: 1.
	
	self assert: (processor readSignedIntAt: 0) equals: 1
]

{ #category : #tests }
WLMemoryTests >> testWriteUnsignedInt [

	| processor codeRegion |
	processor := WLSimulationProcessor x8664.
	codeRegion := ByteArray new: 4096.
	processor mapHostMemory: codeRegion atAddress: 0 withPermissions: UnicornConstants permissionAll.
	
	processor memoryAt: 0 writeUnsignedInt: 1.
	
	self assert: (processor readUnsignedIntAt: 0) equals: 1
]
