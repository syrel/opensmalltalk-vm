Class {
	#name : #CoMTJITTests,
	#superclass : #TestCase,
	#instVars : [
		'instructions',
		'lockAddress',
		'processor',
		'interpreter',
		'cogit',
		'tryLock',
		'unLock'
	],
	#category : #'VMMakerMT-Tests'
}

{ #category : #running }
CoMTJITTests >> setUp [

	super setUp.
	self setUpCogit.

	lockAddress := 16r2000.

	tryLock := 0.
	cogit zeroOpcodeIndex.
	cogit backend generateLowLevelTryLock: lockAddress.
	cogit outputInstructionsForGeneratedRuntimeAt: tryLock.
	
	unLock := cogit methodZoneBase.
	cogit zeroOpcodeIndex.
	cogit backend generateLowLevelUnlock: lockAddress.
	cogit outputInstructionsForGeneratedRuntimeAt: unLock.
	
	instructions := ByteArray streamContents: [ :str |
		1 to: cogit methodZoneBase + 1 do: [ :i |
			str nextPut: (interpreter objectMemory memory byteAt: i) ]].
	
	self setUpSimulator.
]

{ #category : #running }
CoMTJITTests >> setUpCogit [
	
	| objectMemory |
	interpreter := CoInterpreterMT new.
	objectMemory := Spur64BitCoMTMemoryManager simulatorClass new.
	objectMemory allocateMemoryOfSize: 1024 * 1024.
	interpreter objectMemory: objectMemory.
	cogit := StackToRegisterMappingCogit new
		 setInterpreter: interpreter processor: WLSimulationProcessor x8664.
	interpreter cogit: cogit.
	cogit allocateOpcodes: 30 bytecodes: 0
]

{ #category : #tests }
CoMTJITTests >> setUpSimulator [
	
	| memory codeRegion |
	processor := WLSimulationProcessor x8664.

	codeRegion := ByteArray new: 4096.
	processor mapHostMemory: codeRegion atAddress: 0 withPermissions: UnicornConstants permissionAll.
	processor memoryAt: 0 writeBytes: instructions.

	memory := ByteArray new: 4096.
	processor mapHostMemory: memory atAddress: lockAddress withPermissions: UnicornConstants permissionAll.

	processor stackPointer: memory size - 8
]

{ #category : #tests }
CoMTJITTests >> simulate: anInstructionAddress [
	"Start simulation from an instruction until it finds a return instruction.
	Expectation: the simulated machine code has a return instruction.
	
	The return instruction will pop the return address from the stack and set it as PC.
	Use that as end clause for the loop"
	
	| returnAddress |
	processor pc: anInstructionAddress.
	returnAddress := 16r777.
	processor push: returnAddress.
	"run until we arrive to ret instruction"
	[processor pc ~= returnAddress]
		whileTrue: [ processor step ]
]

{ #category : #tests }
CoMTJITTests >> testTryLockKeepsLocksIfLockIsTaken [
	
	"64bit one => lock is taken"
	processor memoryAt: lockAddress writeUnsignedInt: 1.

	self simulate: tryLock.

	self assert: (processor readUnsignedIntAt: lockAddress) equals: 1
]

{ #category : #tests }
CoMTJITTests >> testTryLockLocksIfLockIsNotTaken [
	
	"64bit zero => lock not taken"
	processor memoryAt: lockAddress writeUnsignedInt: 0.
	
	self simulate: tryLock.

	self assert: (processor readUnsignedIntAt: lockAddress) equals: 1
]

{ #category : #tests }
CoMTJITTests >> testTryLockPreservesR10RegisterValue [
	
	| r10Before |
	r10Before := processor r10.
	self simulate: tryLock.

	self assert: r10Before equals: processor r10.
]

{ #category : #tests }
CoMTJITTests >> testTryLockReturnsFalseIfLockIsNotTaken [
	
	"64bit one => lock is taken"
	processor memoryAt: lockAddress writeUnsignedInt: 1.
	
	self simulate: tryLock.

	self assert: processor rax signedIntFromLong64 equals: 0
]

{ #category : #tests }
CoMTJITTests >> testTryLockReturnsTrueIfLockIsTaken [
	
	"64bit zero => lock not taken"
	processor memoryAt: lockAddress writeUnsignedInt: 0.
	
	self simulate: tryLock.

	self assert: processor rax signedIntFromLong64 equals: -1
]

{ #category : #tests }
CoMTJITTests >> testUnlockSetsNonTakenLockToZero [
	
	"64bit one => lock is taken"
	processor memoryAt: lockAddress writeUnsignedInt: 0.

	self simulate: unLock.

	self assert: (processor readUnsignedIntAt: lockAddress) equals: 0
]

{ #category : #tests }
CoMTJITTests >> testUnlockSetsTakenLockToZero [
	
	"64bit one => lock is taken"
	processor memoryAt: lockAddress writeUnsignedInt: 1.

	self simulate: unLock.

	self assert: (processor readUnsignedIntAt: lockAddress) equals: 0
]
