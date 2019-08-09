Class {
	#name : #CoPthreadVMLock,
	#superclass : #CoAbstractVMLock,
	#category : #'VMMaker-Multithreading'
}

{ #category : #initialization }
CoPthreadVMLock >> initializeVMOwnerLock [

	self
		cCode: 'pthread_mutex_init(&vmOwnerLock, NULL)'
		inSmalltalk: [ self halt ]
]

{ #category : #initialization }
CoPthreadVMLock >> tryLockVMOwner [

	<api>
	^ self
		cCode: '!pthread_mutex_trylock(&vmOwnerLock)'
		inSmalltalk: [ true "taken" ]
]

{ #category : #initialization }
CoPthreadVMLock >> unlockVMOwner [

	^ self
		cCode: 'pthread_mutex_unlock(&vmOwnerLock)'
		inSmalltalk: [ self halt ]
]
