# VMMaker support file
#
# Manage the pharo-vm to C generation
#
# This support file defines the following variables
#
#     VMSOURCEFILES        - a list of generated VM files
#     PLUGIN_GENERATED_FILES - a list of generated plugin files
#
# and the following targets
#
#     generate-sources
#     vmmaker
#
# TODOs:
#  - Make the VMFlavours autodescribed? Slang could output a list of generated files that we could use

set(CMAKE_VERBOSE_MAKEFILE TRUE)

#Setting vmmaker directory and image 
set( VMMAKER_DIR    "${CMAKE_CURRENT_BINARY_DIR_TO_OUT}/build/vmmaker")
set( VMMAKER_IMAGE  "${VMMAKER_DIR}/image/VMMaker.image")

if(${SIZEOF_VOID_P} STREQUAL "8")
    set(PHARO_CURRENT_GENERATED ${GENERATED_SOURCE_DIR}/generated/64)
else()
    set(PHARO_CURRENT_GENERATED ${GENERATED_SOURCE_DIR}/generated/32)
endif()

#If not StackVM, include also JIT related files
if(FLAVOUR MATCHES "StackVM")
  if(${FEATURE_COMPILE_GNUISATION})
      set(VMSOURCEFILES ${PHARO_CURRENT_GENERATED}/vm/src/gcc3x-interp.c)
  else()
      set(VMSOURCEFILES ${PHARO_CURRENT_GENERATED}/vm/src/interp.c)
  endif()
else()
  list(APPEND VMSOURCEFILES ${PHARO_CURRENT_GENERATED}/vm/src/cogit.c)
  if(${FEATURE_COMPILE_GNUISATION})
      list(APPEND VMSOURCEFILES ${PHARO_CURRENT_GENERATED}/vm/src/gcc3x-cointerp.c)
  else()
      list(APPEND VMSOURCEFILES ${PHARO_CURRENT_GENERATED}/vm/src/cointerp.c)
  endif()
endif()

set(PLUGIN_GENERATED_FILES 
    ${PHARO_CURRENT_GENERATED}/plugins/src/FilePlugin/FilePlugin.c
    ${PHARO_CURRENT_GENERATED}/plugins/src/SurfacePlugin/SurfacePlugin.c)

if(GENERATE_SOURCES)

    #Setting platform specific vmmaker virtual machine, with cached download or override
    if (NOT "${GENERATE_PHARO_VM}" STREQUAL "")
        message("Overriding VM used for code generation")  
        set(VMMAKER_VM ${GENERATE_PHARO_VM})
        # add empty target because is required later when installing vmmaker
        add_custom_target(build_vmmaker_get_vm-build)
    else()
        #Pick platform specific VM to download
        if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
            message("Defining Windows VM to download for code generation")
            set(VMMAKER_VM ${VMMAKER_DIR}/vm/PharoConsole.exe)
            set(VM_URL https://files.pharo.org/vm/pharo-spur64-headless/Windows-x86_64/PharoVM-9.0.11-9e688828-Windows-x86_64-bin.zip)
            set(VM_URL_HASH SHA256=269cbffbb7e7377d09382f0059249eb7c031e5e472dd3647ee6539e6f18528ee)
        elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux" AND (${CMAKE_SYSTEM_PROCESSOR} MATCHES "aarch64"))
            message("Defining Linux AARCH64 VM to download for code generation")
            set(VMMAKER_VM       ${VMMAKER_DIR}/vm/pharo)
            set(VM_URL https://files.pharo.org/vm/pharo-spur64/Linux-aarch64/stable.zip)
            set(VM_URL_HASH      SHA256=924e5a25f8e2d51773e8571ebefa2404da9561418af2b54af1330357b75ae865)
        elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux" AND (${CMAKE_SYSTEM_PROCESSOR} MATCHES "armv7l"))
            message("Defining Linux ARM 32 VM to download for code generation")
            set(VMMAKER_VM       ${VMMAKER_DIR}/vm/pharo)
            set(VM_URL https://files.pharo.org/vm/pharo-spur32/Linux-armv7l/stable.zip)
            set(VM_URL_HASH      SHA256=1816e44523e08e7effe3226a3cabc4ea701fb9582c00456ab90936efb5c645c4)
        elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
            message("Defining Linux VM x86_64 to download for code generation")
            set(VMMAKER_VM       ${VMMAKER_DIR}/vm/pharo)
            set(VM_URL https://files.pharo.org/vm/pharo-spur64-headless/Linux-x86_64/PharoVM-9.0.11-9e68882-Linux-x86_64-bin.zip)
            set(VM_URL_HASH      SHA256=f885241a56f9f15daa0b44c506f390d9de44da67d93c6549e4cd7b455f37d872)
        elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
            message("Defining OSX VM to download for code generation")
            set(VMMAKER_VM       ${VMMAKER_DIR}/vm/Contents/MacOS/Pharo)
            set(VM_URL https://files.pharo.org/vm/pharo-spur64-headless/Darwin-x86_64/PharoVM-9.0.11-9e688828-Darwin-x86_64-bin.zip)
            set(VM_URL_HASH      SHA256=dc21952f5708766d5d6afb90c7fa3de17b4165d37907138e143be9339160a754)
        else()
            message(FATAL_ERROR "VM DOWNLOAD NOT HANDLED FOR CMAKE SYSTEM: ${CMAKE_SYSTEM_NAME}")
        endif()

        #Download VM
        ExternalProject_Add(
            build_vmmaker_get_vm

            URL ${VM_URL}
            URL_HASH ${VM_URL_HASH}
            BUILD_COMMAND       echo 
            UPDATE_COMMAND      echo 
            CONFIGURE_COMMAND   echo 
            INSTALL_COMMAND     echo 

            PREFIX "${VMMAKER_DIR}"
            SOURCE_DIR "${VMMAKER_DIR}/vm"
            BUILD_IN_SOURCE True

            STEP_TARGETS   build
            )
    endif()

    if(NOT "${GENERATE_PHARO_IMAGE}" STREQUAL "")
        add_custom_target(
            build_vmmaker_save_image
            COMMAND ${VMMAKER_VM} --headless ${GENERATE_PHARO_IMAGE} save "${VMMAKER_DIR}/image/VMMaker"
            DEPENDS build_vmmaker_get_vm-build
            COMMENT "Saving VMMaker image: ${VMMAKER_DIR}/image/VMMaker from ${GENERATE_PHARO_IMAGE}")
        get_filename_component(GENERATE_PHARO_IMAGE_DIRECTORY ${GENERATE_PHARO_IMAGE} DIRECTORY)

        file(GLOB GENERATE_PHARO_IMAGE_SOURCES "${GENERATE_PHARO_IMAGE_DIRECTORY}/*.sources")

        add_custom_target(
            build_vmmaker_copy_sources
            COMMAND ${CMAKE_COMMAND} -E copy ${GENERATE_PHARO_IMAGE_SOURCES} "${VMMAKER_DIR}/image/"
            DEPENDS build_vmmaker_save_image
            COMMENT "Copy sources to the VMMaker ${GENERATE_PHARO_IMAGE_SOURCES}")

        add_custom_target(
            build_vmmaker_get_image
            COMMAND ${VMMAKER_VM} --headless ${VMMAKER_IMAGE} --no-default-preferences --save --quit "${CMAKE_CURRENT_SOURCE_DIR_TO_OUT}/scripts/installVMMaker.st" "${CMAKE_CURRENT_SOURCE_DIR_TO_OUT}" "${ICEBERG_DEFAULT_REMOTE}"
            DEPENDS build_vmmaker_copy_sources
            COMMENT "Installing VMMaker in ${VMMAKER_IMAGE}")
    else()

        #Bootstrap VMMaker.image from downloaded image
        ExternalProject_Add(
            build_vmmaker_get_image

            URL https://files.pharo.org/image/100/Pharo10-SNAPSHOT.build.349.sha.3e26baf.arch.64bit.zip
            URL_HASH SHA256=92ca96c8a9eea320b0fef5043d9b89a8cfdbfc4a0d6a5552de33d4cd2fb525a4
            BUILD_COMMAND ${VMMAKER_VM} --headless ${VMMAKER_DIR}/image/Pharo10-SNAPSHOT-64bit-3e26baf.image --no-default-preferences save VMMaker
            COMMAND ${VMMAKER_VM} --headless ${VMMAKER_IMAGE} --no-default-preferences --save --quit "${CMAKE_CURRENT_SOURCE_DIR_TO_OUT}/scripts/installVMMaker.st" "${CMAKE_CURRENT_SOURCE_DIR_TO_OUT}" "${ICEBERG_DEFAULT_REMOTE}"
            UPDATE_COMMAND      echo 
            CONFIGURE_COMMAND   echo
            INSTALL_COMMAND     echo

            PREFIX "${VMMAKER_DIR}"
            SOURCE_DIR "${VMMAKER_DIR}/image"
            BUILD_IN_SOURCE True
            WORKING_DIRECTORY "${VMMAKER_DIR}"

            DEPENDS build_vmmaker_get_vm-build
            )
    endif()

    #Custom command that generates the vm source code from VMMaker into "out/build/XXXX/generated" folder
    add_custom_command(
        OUTPUT ${VMSOURCEFILES} ${PLUGIN_GENERATED_FILES}
        COMMAND ${VMMAKER_VM} --headless ${VMMAKER_IMAGE} --no-default-preferences eval \"PharoVMMaker generate: \#\'${FLAVOUR}\' outputDirectory: \'${CMAKE_CURRENT_BINARY_DIR_TO_OUT}\'\"
        DEPENDS build_vmmaker_get_image
        COMMENT "Generating VM files for flavour: ${FLAVOUR}")
    
    add_custom_target(vmmaker DEPENDS build_vmmaker_get_image)
    add_custom_target(generate-sources DEPENDS ${VMSOURCEFILES} ${PLUGIN_GENERATED_FILES})

endif()
