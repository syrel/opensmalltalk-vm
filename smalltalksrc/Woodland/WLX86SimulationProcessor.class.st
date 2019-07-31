"
I'm a processor simulator for x86.
See CogSimulationProcessor for more detail.
"
Class {
	#name : #WLX86SimulationProcessor,
	#superclass : #WLSimulationProcessor,
	#category : #Woodland
}

{ #category : #accessing }
WLX86SimulationProcessor >> cr4 [

	^ self readRegisterId: UcX86Registers cr4
]

{ #category : #accessing }
WLX86SimulationProcessor >> cr4: anInteger [ 

	^ self writeInteger: anInteger registerId: UcX86Registers cr4
]

{ #category : #accessing }
WLX86SimulationProcessor >> eax [

	^ self readRegisterId: UcX86Registers eax
]

{ #category : #accessing }
WLX86SimulationProcessor >> eax: anInteger [ 

	^ self writeInteger: anInteger registerId: UcX86Registers eax
]

{ #category : #accessing }
WLX86SimulationProcessor >> ebp [

	^ self readRegisterId: UcX86Registers ebp
]

{ #category : #accessing }
WLX86SimulationProcessor >> ebp: anInteger [ 

	^ self writeInteger: anInteger registerId: UcX86Registers ebp
]

{ #category : #accessing }
WLX86SimulationProcessor >> ebx [

	^ self readRegisterId: UcX86Registers ebx
]

{ #category : #accessing }
WLX86SimulationProcessor >> ebx: anInteger [ 

	^ self writeInteger: anInteger registerId: UcX86Registers ebx
]

{ #category : #accessing }
WLX86SimulationProcessor >> ecx [

	^ self readRegisterId: UcX86Registers ecx
]

{ #category : #accessing }
WLX86SimulationProcessor >> ecx: anInteger [ 

	^ self writeInteger: anInteger registerId: UcX86Registers ecx
]

{ #category : #accessing }
WLX86SimulationProcessor >> edi [

	^ self readRegisterId: UcX86Registers edi
]

{ #category : #accessing }
WLX86SimulationProcessor >> edi: anInteger [ 

	^ self writeInteger: anInteger registerId: UcX86Registers edi
]

{ #category : #accessing }
WLX86SimulationProcessor >> edx [

	^ self readRegisterId: UcX86Registers edx
]

{ #category : #accessing }
WLX86SimulationProcessor >> edx: anInteger [ 

	^ self writeInteger: anInteger registerId: UcX86Registers edx
]

{ #category : #accessing }
WLX86SimulationProcessor >> eip [

	^ self readRegisterId: UcX86Registers eip
]

{ #category : #accessing }
WLX86SimulationProcessor >> eip: anInteger [ 

	^ self writeInteger: anInteger registerId: UcX86Registers eip
]

{ #category : #accessing }
WLX86SimulationProcessor >> esi [

	^ self readRegisterId: UcX86Registers esi
]

{ #category : #accessing }
WLX86SimulationProcessor >> esi: anInteger [ 

	^ self writeInteger: anInteger registerId: UcX86Registers esi
]

{ #category : #accessing }
WLX86SimulationProcessor >> esp [

	^ self readRegisterId: UcX86Registers esp
]

{ #category : #accessing }
WLX86SimulationProcessor >> esp: anInteger [ 

	^ self writeInteger: anInteger registerId: UcX86Registers esp
]

{ #category : #testing }
WLX86SimulationProcessor >> formatDisassembledOffset: anInteger [ 
	| toPrint prefix |
	toPrint := anInteger signedIntFromLong.
	prefix := (toPrint negative
		ifTrue: [ '-' ]
		ifFalse: [ '' ]), '0x'.
	^ prefix , (toPrint abs printStringBase: 16)
]

{ #category : #initialization }
WLX86SimulationProcessor >> initialize [
	super initialize.
	
	bitsInWord := 32.	
	disassembler := LLVMDisassembler i386
		setOptions: 2;
		yourself.
	simulator := Unicorn x86.
]

{ #category : #testing }
WLX86SimulationProcessor >> memoryShiftFactorArgument [

	^ ''
]

{ #category : #accessing }
WLX86SimulationProcessor >> nopOpcode [
	^16r90
]

{ #category : #accessing }
WLX86SimulationProcessor >> pc [

	^self eip
]

{ #category : #accessing }
WLX86SimulationProcessor >> registerNames [
	
	^ #(eax ecx edx ebx esp ebp esi edi eip)
]

{ #category : #resetting }
WLX86SimulationProcessor >> reset [
	
	super reset.
	"Enable SSE extensions by setting the OSFXSR (Operating System FXSAVE/FXRSTOR Support) bit"
	self cr4: (self cr4 bitOr: 1 << 9)
]

{ #category : #accessing }
WLX86SimulationProcessor >> wordSize [

	^ 4
]

{ #category : #accessing }
WLX86SimulationProcessor >> xmm0 [

	^ self readRegisterId: UcX86Registers xmm0 size: 16
]

{ #category : #accessing }
WLX86SimulationProcessor >> xmm0: aBuffer [

	^ self write: aBuffer registerId: UcX86Registers xmm0
]

{ #category : #accessing }
WLX86SimulationProcessor >> xmm0high: anUnsignedInteger [
	
	^ self xmm0 unsignedLongLongAt: 2 put: anUnsignedInteger
]

{ #category : #accessing }
WLX86SimulationProcessor >> xmm0low [

	^ self readRegisterId: UcX86Registers xmm0low
]

{ #category : #accessing }
WLX86SimulationProcessor >> xmm0low: anUnsignedInteger [
	
	| buffer |
	buffer := self xmm0.
	buffer unsignedLongLongAt: 1 put: anUnsignedInteger.
	^ self xmm0: buffer.
]

{ #category : #accessing }
WLX86SimulationProcessor >> xmm1 [

	^ self readRegisterId: UcX86Registers xmm1 size: 16
]

{ #category : #accessing }
WLX86SimulationProcessor >> xmm1: aBuffer [

	^ self write: aBuffer registerId: UcX86Registers xmm1
]

{ #category : #accessing }
WLX86SimulationProcessor >> xmm1low: anUnsignedInteger [
	
	| buffer |
	buffer := self xmm1.
	buffer unsignedLongLongAt: 1 put: anUnsignedInteger.
	^ self xmm1: buffer.
]
