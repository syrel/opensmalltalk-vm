"
I'm a processor simulator for ARM 32 bits.
See CogSimulationProcessor for more detail.
"
Class {
	#name : #WLARMSimulationProcessor,
	#superclass : #WLSimulationProcessor,
	#category : #Woodland
}

{ #category : #accessing }
WLARMSimulationProcessor >> d0 [

	^ self readRegisterId: UcARMRegisters  d0
]

{ #category : #accessing }
WLARMSimulationProcessor >> d0: anInteger [ 

	^ self writeInteger: anInteger registerId: UcARMRegisters d0
]

{ #category : #accessing }
WLARMSimulationProcessor >> d1 [

	^ self readRegisterId: UcARMRegisters  d1
]

{ #category : #accessing }
WLARMSimulationProcessor >> d10 [

	^ self readRegisterId: UcARMRegisters  d10
]

{ #category : #accessing }
WLARMSimulationProcessor >> d10: anInteger [ 

	^ self writeInteger: anInteger registerId: UcARMRegisters d10
]

{ #category : #accessing }
WLARMSimulationProcessor >> d11 [

	^ self readRegisterId: UcARMRegisters  d11
]

{ #category : #accessing }
WLARMSimulationProcessor >> d11: anInteger [ 

	^ self writeInteger: anInteger registerId: UcARMRegisters d11
]

{ #category : #accessing }
WLARMSimulationProcessor >> d12 [

	^ self readRegisterId: UcARMRegisters  d12
]

{ #category : #accessing }
WLARMSimulationProcessor >> d12: anInteger [ 

	^ self writeInteger: anInteger registerId: UcARMRegisters d12
]

{ #category : #accessing }
WLARMSimulationProcessor >> d13 [

	^ self readRegisterId: UcARMRegisters  d13
]

{ #category : #accessing }
WLARMSimulationProcessor >> d13: anInteger [ 

	^ self writeInteger: anInteger registerId: UcARMRegisters d13
]

{ #category : #accessing }
WLARMSimulationProcessor >> d14 [

	^ self readRegisterId: UcARMRegisters  d14
]

{ #category : #accessing }
WLARMSimulationProcessor >> d14: anInteger [ 

	^ self writeInteger: anInteger registerId: UcARMRegisters d14
]

{ #category : #accessing }
WLARMSimulationProcessor >> d15 [

	^ self readRegisterId: UcARMRegisters  d15
]

{ #category : #accessing }
WLARMSimulationProcessor >> d15: anInteger [ 

	^ self writeInteger: anInteger registerId: UcARMRegisters d15
]

{ #category : #accessing }
WLARMSimulationProcessor >> d1: anInteger [ 

	^ self writeInteger: anInteger registerId: UcARMRegisters d1
]

{ #category : #accessing }
WLARMSimulationProcessor >> d2 [

	^ self readRegisterId: UcARMRegisters  d2
]

{ #category : #accessing }
WLARMSimulationProcessor >> d2: anInteger [ 

	^ self writeInteger: anInteger registerId: UcARMRegisters d2
]

{ #category : #accessing }
WLARMSimulationProcessor >> d3 [

	^ self readRegisterId: UcARMRegisters  d3
]

{ #category : #accessing }
WLARMSimulationProcessor >> d3: anInteger [ 

	^ self writeInteger: anInteger registerId: UcARMRegisters d3
]

{ #category : #accessing }
WLARMSimulationProcessor >> d4 [

	^ self readRegisterId: UcARMRegisters  d4
]

{ #category : #accessing }
WLARMSimulationProcessor >> d4: anInteger [ 

	^ self writeInteger: anInteger registerId: UcARMRegisters d4
]

{ #category : #accessing }
WLARMSimulationProcessor >> d5 [

	^ self readRegisterId: UcARMRegisters  d5
]

{ #category : #accessing }
WLARMSimulationProcessor >> d5: anInteger [ 

	^ self writeInteger: anInteger registerId: UcARMRegisters d5
]

{ #category : #accessing }
WLARMSimulationProcessor >> d6 [

	^ self readRegisterId: UcARMRegisters  d6
]

{ #category : #accessing }
WLARMSimulationProcessor >> d6: anInteger [ 

	^ self writeInteger: anInteger registerId: UcARMRegisters d6
]

{ #category : #accessing }
WLARMSimulationProcessor >> d7 [

	^ self readRegisterId: UcARMRegisters  d7
]

{ #category : #accessing }
WLARMSimulationProcessor >> d7: anInteger [ 

	^ self writeInteger: anInteger registerId: UcARMRegisters d7
]

{ #category : #accessing }
WLARMSimulationProcessor >> d8 [

	^ self readRegisterId: UcARMRegisters  d8
]

{ #category : #accessing }
WLARMSimulationProcessor >> d8: anInteger [ 

	^ self writeInteger: anInteger registerId: UcARMRegisters d8
]

{ #category : #accessing }
WLARMSimulationProcessor >> d9 [

	^ self readRegisterId: UcARMRegisters  d9
]

{ #category : #accessing }
WLARMSimulationProcessor >> d9: anInteger [ 

	^ self writeInteger: anInteger registerId: UcARMRegisters d9
]

{ #category : #accessing }
WLARMSimulationProcessor >> eflags [

	^ self readRegisterId: UcARMRegisters  eflags
]

{ #category : #accessing }
WLARMSimulationProcessor >> eflags: anInteger [ 

	^ self writeInteger: anInteger registerId: UcARMRegisters eflags
]

{ #category : #accessing }
WLARMSimulationProcessor >> fp [

	^ self readRegisterId: UcARMRegisters  fp
]

{ #category : #accessing }
WLARMSimulationProcessor >> fp: anInteger [ 

	^ self writeInteger: anInteger registerId: UcARMRegisters fp
]

{ #category : #testing }
WLARMSimulationProcessor >> initialize [
	super initialize.
	
	bitsInWord := 32.	
	disassembler := LLVMDisassembler arm
		printImmediatesInHexa
]

{ #category : #initialization }
WLARMSimulationProcessor >> instantiateSimulator [
	
	^ Unicorn arm
]

{ #category : #accessing }
WLARMSimulationProcessor >> lr [

	^ self readRegisterId: UcARMRegisters  lr
]

{ #category : #accessing }
WLARMSimulationProcessor >> lr: anInteger [ 

	^ self writeInteger: anInteger registerId: UcARMRegisters lr
]

{ #category : #accessing }
WLARMSimulationProcessor >> pc [

	^ self readRegisterId: UcARMRegisters pc
]

{ #category : #accessing }
WLARMSimulationProcessor >> pc: anInteger [ 

	^ self writeInteger: anInteger registerId: UcARMRegisters pc
]

{ #category : #accessing }
WLARMSimulationProcessor >> r0 [

	^ self readRegisterId: UcARMRegisters  r0
]

{ #category : #accessing }
WLARMSimulationProcessor >> r0: anInteger [ 

	^ self writeInteger: anInteger registerId: UcARMRegisters r0
]

{ #category : #accessing }
WLARMSimulationProcessor >> r1 [

	^ self readRegisterId: UcARMRegisters  r1
]

{ #category : #accessing }
WLARMSimulationProcessor >> r12 [

	^ self readRegisterId: UcARMRegisters  r12
]

{ #category : #accessing }
WLARMSimulationProcessor >> r12: anInteger [ 

	^ self writeInteger: anInteger registerId: UcARMRegisters r12
]

{ #category : #accessing }
WLARMSimulationProcessor >> r1: anInteger [ 

	^ self writeInteger: anInteger registerId: UcARMRegisters r1
]

{ #category : #accessing }
WLARMSimulationProcessor >> r2 [

	^ self readRegisterId: UcARMRegisters  r2
]

{ #category : #accessing }
WLARMSimulationProcessor >> r2: anInteger [ 

	^ self writeInteger: anInteger registerId: UcARMRegisters r2
]

{ #category : #accessing }
WLARMSimulationProcessor >> r3 [

	^ self readRegisterId: UcARMRegisters  r3
]

{ #category : #accessing }
WLARMSimulationProcessor >> r3: anInteger [ 

	^ self writeInteger: anInteger registerId: UcARMRegisters r3
]

{ #category : #accessing }
WLARMSimulationProcessor >> r4 [

	^ self readRegisterId: UcARMRegisters  r4
]

{ #category : #accessing }
WLARMSimulationProcessor >> r4: anInteger [ 

	^ self writeInteger: anInteger registerId: UcARMRegisters r4
]

{ #category : #accessing }
WLARMSimulationProcessor >> r5 [

	^ self readRegisterId: UcARMRegisters  r5
]

{ #category : #accessing }
WLARMSimulationProcessor >> r5: anInteger [ 

	^ self writeInteger: anInteger registerId: UcARMRegisters r5
]

{ #category : #accessing }
WLARMSimulationProcessor >> r6 [

	^ self readRegisterId: UcARMRegisters  r6
]

{ #category : #accessing }
WLARMSimulationProcessor >> r6: anInteger [ 

	^ self writeInteger: anInteger registerId: UcARMRegisters r6
]

{ #category : #accessing }
WLARMSimulationProcessor >> r7 [

	^ self readRegisterId: UcARMRegisters  r7
]

{ #category : #accessing }
WLARMSimulationProcessor >> r7: anInteger [ 

	^ self writeInteger: anInteger registerId: UcARMRegisters r7
]

{ #category : #accessing }
WLARMSimulationProcessor >> r8 [

	^ self readRegisterId: UcARMRegisters  r8
]

{ #category : #accessing }
WLARMSimulationProcessor >> r8: anInteger [ 

	^ self writeInteger: anInteger registerId: UcARMRegisters r8
]

{ #category : #accessing }
WLARMSimulationProcessor >> r9 [

	^ self readRegisterId: UcARMRegisters  r9
]

{ #category : #accessing }
WLARMSimulationProcessor >> r9: anInteger [ 

	^ self writeInteger: anInteger registerId: UcARMRegisters r9
]

{ #category : #accessing }
WLARMSimulationProcessor >> registerNames [

	^ #(	r0 r1 r2 r3 r4 r5 r6 r7 r8 r9 sl fp r12 sp lr pc eflags
		d0 d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15)
]

{ #category : #accessing }
WLARMSimulationProcessor >> sl [

	^ self readRegisterId: UcARMRegisters  sl
]

{ #category : #accessing }
WLARMSimulationProcessor >> sl: anInteger [ 

	^ self writeInteger: anInteger registerId: UcARMRegisters sl
]

{ #category : #accessing }
WLARMSimulationProcessor >> sp [

	^ self readRegisterId: UcARMRegisters  sp
]

{ #category : #accessing }
WLARMSimulationProcessor >> sp: anInteger [ 

	^ self writeInteger: anInteger registerId: UcARMRegisters sp
]
