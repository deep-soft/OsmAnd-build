# Qt selection: external, system or embedded

set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE BOTH)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY BOTH)
if (DEFINED ENV{OSMAND_EXTERNAL_QT})
	# External
	set(OSMAND_EXTERNAL_QT ON)
	message("Using external Qt5: $ENV{OSMAND_EXTERNAL_QT}")
	list(APPEND CMAKE_PREFIX_PATH "$ENV{OSMAND_EXTERNAL_QT}/lib/cmake")
elseif (DEFINED ENV{OSMAND_SYSTEM_QT})
	# System
	set(OSMAND_SYSTEM_QT ON)
	message("Using system Qt5.")
else()
	# Embedded: shared and static
	set(OSMAND_OWN_SHIPPED_QT ON)

	# Flavour: desktop, iOS or etc.
	if (CMAKE_TARGET_OS STREQUAL "linux" OR
		CMAKE_TARGET_OS STREQUAL "macosx" OR
		CMAKE_TARGET_OS STREQUAL "windows" OR
		CMAKE_TARGET_OS STREQUAL "cygwin")
		set(OSMAND_QT_FLAVOUR "desktop")
	elseif (CMAKE_TARGET_OS STREQUAL "ios")
		set(OSMAND_QT_FLAVOUR "ios")
	elseif (CMAKE_TARGET_OS STREQUAL "android")
		set(OSMAND_QT_FLAVOUR "android")
	else()
		message(FATAL_ERROR "Failed to determine Qt flavour")
	endif()

	# Debug suffix
	set(QT_DEBUG_SUFFIX "d")
	if (CMAKE_TARGET_OS STREQUAL "macosx" OR CMAKE_TARGET_OS STREQUAL "ios")
		set(QT_DEBUG_SUFFIX "_debug")
	endif()

	# Since Qt is also an upstream, configure it and build
	prepare_upstream_ex("${OSMAND_ROOT}/core/externals/qtbase-${OSMAND_QT_FLAVOUR}" QT_WAS_CONFIGURED)
	build_upstream_ex("${OSMAND_ROOT}/core/externals/qtbase-${OSMAND_QT_FLAVOUR}")

	# If shared libs are allowed, they need shared Qt
	if (CMAKE_SHARED_LIBS_ALLOWED_ON_TARGET)
		if (EXISTS "${OSMAND_ROOT}/core/externals/qtbase-${OSMAND_QT_FLAVOUR}/upstream.patched.${CMAKE_TARGET_OS}.${CMAKE_COMPILER_FAMILY}-${CMAKE_TARGET_CPU_ARCH}.shared/lib/cmake")
			set(OSMAND_OWN_SHIPPED_QT_SHARED "${OSMAND_ROOT}/core/externals/qtbase-${OSMAND_QT_FLAVOUR}/upstream.patched.${CMAKE_TARGET_OS}.${CMAKE_COMPILER_FAMILY}-${CMAKE_TARGET_CPU_ARCH}.shared")
		elseif (EXISTS "${OSMAND_ROOT}/core/externals/qtbase-${OSMAND_QT_FLAVOUR}/upstream.patched.${CMAKE_TARGET_OS}.${CMAKE_COMPILER_FAMILY}.shared/lib/cmake")
			set(OSMAND_OWN_SHIPPED_QT_SHARED "${OSMAND_ROOT}/core/externals/qtbase-${OSMAND_QT_FLAVOUR}/upstream.patched.${CMAKE_TARGET_OS}.${CMAKE_COMPILER_FAMILY}.shared")
		endif()

		if (NOT DEFINED OSMAND_OWN_SHIPPED_QT_SHARED)
			message(FATAL_ERROR "Embedded shared Qt not found")
		else()
			message("Using embedded Qt5 (shared): ${OSMAND_OWN_SHIPPED_QT_SHARED}")
		endif()

		find_library(Qt5Core_SHARED_LIBRARY "Qt5Core" PATHS "${OSMAND_OWN_SHIPPED_QT_SHARED}/lib" NO_DEFAULT_PATH)
		find_library(Qt5Cored_SHARED_LIBRARY "Qt5Core${QT_DEBUG_SUFFIX}" PATHS "${OSMAND_OWN_SHIPPED_QT_SHARED}/lib" NO_DEFAULT_PATH)
		set(Qt5Core_SHARED_LIBRARIES "")
		if (Qt5Core_SHARED_LIBRARY AND Qt5Cored_SHARED_LIBRARY)
			set(Qt5Core_SHARED_LIBRARIES ${Qt5Core_SHARED_LIBRARIES}
				optimized ${Qt5Core_SHARED_LIBRARY}
			)
		else()
			set(Qt5Core_SHARED_LIBRARIES ${Qt5Core_SHARED_LIBRARIES}
				${Qt5Core_SHARED_LIBRARY}
			)
		endif()
		if (Qt5Cored_SHARED_LIBRARY)
			set(Qt5Core_SHARED_LIBRARIES ${Qt5Core_SHARED_LIBRARIES}
				debug ${Qt5Cored_SHARED_LIBRARY}
			)
		endif()

		find_library(Qt5Network_SHARED_LIBRARY "Qt5Network" PATHS "${OSMAND_OWN_SHIPPED_QT_SHARED}/lib" NO_DEFAULT_PATH)
		find_library(Qt5Networkd_SHARED_LIBRARY "Qt5Network${QT_DEBUG_SUFFIX}" PATHS "${OSMAND_OWN_SHIPPED_QT_SHARED}/lib" NO_DEFAULT_PATH)
		set(Qt5Network_SHARED_LIBRARIES "")
		if (Qt5Network_SHARED_LIBRARY AND Qt5Networkd_SHARED_LIBRARY)
			set(Qt5Network_SHARED_LIBRARIES ${Qt5Network_SHARED_LIBRARIES}
				optimized ${Qt5Network_SHARED_LIBRARY}
			)
		else()
			set(Qt5Network_SHARED_LIBRARIES ${Qt5Network_SHARED_LIBRARIES}
				${Qt5Network_SHARED_LIBRARY}
			)
		endif()
		if (Qt5Networkd_SHARED_LIBRARY)
			set(Qt5Network_SHARED_LIBRARIES ${Qt5Network_SHARED_LIBRARIES}
				debug ${Qt5Networkd_SHARED_LIBRARY}
			)
		endif()

		find_library(qtpcre_SHARED_LIBRARY "qtpcre2" PATHS "${OSMAND_OWN_SHIPPED_QT_SHARED}/lib" NO_DEFAULT_PATH)
		if (NOT qtpcre_SHARED_LIBRARY)
			find_library(qtpcre_SHARED_LIBRARY "qtpcre" PATHS "${OSMAND_OWN_SHIPPED_QT_SHARED}/lib" NO_DEFAULT_PATH)
		endif()
		find_library(qtpcred_SHARED_LIBRARY "qtpcre2${QT_DEBUG_SUFFIX}" PATHS "${OSMAND_OWN_SHIPPED_QT_SHARED}/lib" NO_DEFAULT_PATH)
		if (NOT qtpcred_SHARED_LIBRARY)
			find_library(qtpcred_SHARED_LIBRARY "qtpcre${QT_DEBUG_SUFFIX}" PATHS "${OSMAND_OWN_SHIPPED_QT_SHARED}/lib" NO_DEFAULT_PATH)
		endif()
		set(qtpcre_SHARED_LIBRARIES "")
		if (qtpcre_SHARED_LIBRARY AND qtpcred_SHARED_LIBRARY)
			set(qtpcre_SHARED_LIBRARIES ${qtpcre_SHARED_LIBRARIES}
				optimized ${qtpcre_SHARED_LIBRARY}
			)
		else()
			set(qtpcre_SHARED_LIBRARIES ${qtpcre_SHARED_LIBRARIES}
				${qtpcre_SHARED_LIBRARY}
			)
		endif()
		if (qtpcred_SHARED_LIBRARY)
			set(qtpcre_SHARED_LIBRARIES ${qtpcre_SHARED_LIBRARIES}
				debug ${qtpcred_SHARED_LIBRARY}
			)
		endif()
	endif()

	# If static libs are allowed, they need static Qt
	if (CMAKE_STATIC_LIBS_ALLOWED_ON_TARGET)
		if (EXISTS "${OSMAND_ROOT}/core/externals/qtbase-${OSMAND_QT_FLAVOUR}/upstream.patched.${CMAKE_TARGET_OS}.${CMAKE_COMPILER_FAMILY}-${CMAKE_TARGET_CPU_ARCH}.static/lib/cmake")
			set(OSMAND_OWN_SHIPPED_QT_STATIC "${OSMAND_ROOT}/core/externals/qtbase-${OSMAND_QT_FLAVOUR}/upstream.patched.${CMAKE_TARGET_OS}.${CMAKE_COMPILER_FAMILY}-${CMAKE_TARGET_CPU_ARCH}.static")
		elseif (EXISTS "${OSMAND_ROOT}/core/externals/qtbase-${OSMAND_QT_FLAVOUR}/upstream.patched.${CMAKE_TARGET_OS}.${CMAKE_COMPILER_FAMILY}.static/lib/cmake")
			set(OSMAND_OWN_SHIPPED_QT_STATIC "${OSMAND_ROOT}/core/externals/qtbase-${OSMAND_QT_FLAVOUR}/upstream.patched.${CMAKE_TARGET_OS}.${CMAKE_COMPILER_FAMILY}.static")
		endif()

		if (NOT DEFINED OSMAND_OWN_SHIPPED_QT_STATIC)
			message(FATAL_ERROR "Embedded static Qt not found")
		else()
			message("Using embedded Qt5 (static): ${OSMAND_OWN_SHIPPED_QT_STATIC}")
		endif()

		find_library(Qt5Core_STATIC_LIBRARY "Qt5Core" PATHS "${OSMAND_OWN_SHIPPED_QT_STATIC}/lib" NO_DEFAULT_PATH)
		find_library(Qt5Cored_STATIC_LIBRARY "Qt5Core${QT_DEBUG_SUFFIX}" PATHS "${OSMAND_OWN_SHIPPED_QT_STATIC}/lib" NO_DEFAULT_PATH)
		set(Qt5Core_STATIC_LIBRARIES "")
		if (Qt5Core_STATIC_LIBRARY AND Qt5Cored_STATIC_LIBRARY)
			set(Qt5Core_STATIC_LIBRARIES ${Qt5Core_STATIC_LIBRARIES}
				optimized ${Qt5Core_STATIC_LIBRARY}
			)
		else()
			set(Qt5Core_STATIC_LIBRARIES ${Qt5Core_STATIC_LIBRARIES}
				${Qt5Core_STATIC_LIBRARY}
			)
		endif()
		if (Qt5Cored_STATIC_LIBRARY)
			set(Qt5Core_STATIC_LIBRARIES ${Qt5Core_STATIC_LIBRARIES}
				debug ${Qt5Cored_STATIC_LIBRARY}
			)
		endif()

		find_library(Qt5Network_STATIC_LIBRARY "Qt5Network" PATHS "${OSMAND_OWN_SHIPPED_QT_STATIC}/lib" NO_DEFAULT_PATH)
		find_library(Qt5Networkd_STATIC_LIBRARY "Qt5Network${QT_DEBUG_SUFFIX}" PATHS "${OSMAND_OWN_SHIPPED_QT_STATIC}/lib" NO_DEFAULT_PATH)
		set(Qt5Network_STATIC_LIBRARIES "")
		if (Qt5Network_STATIC_LIBRARY AND Qt5Networkd_STATIC_LIBRARY)
			set(Qt5Network_STATIC_LIBRARIES ${Qt5Network_STATIC_LIBRARIES}
				optimized ${Qt5Network_STATIC_LIBRARY}
			)
		else()
			set(Qt5Network_STATIC_LIBRARIES ${Qt5Network_STATIC_LIBRARIES}
				${Qt5Network_STATIC_LIBRARY}
			)
		endif()
		if (Qt5Networkd_STATIC_LIBRARY)
			set(Qt5Network_STATIC_LIBRARIES ${Qt5Network_STATIC_LIBRARIES}
				debug ${Qt5Networkd_STATIC_LIBRARY}
			)
		endif()

		find_library(qtpcre_STATIC_LIBRARY "qtpcre2" PATHS "${OSMAND_OWN_SHIPPED_QT_STATIC}/lib" NO_DEFAULT_PATH)
		if (NOT qtpcre_STATIC_LIBRARY)
			find_library(qtpcre_STATIC_LIBRARY "qtpcre" PATHS "${OSMAND_OWN_SHIPPED_QT_STATIC}/lib" NO_DEFAULT_PATH)
		endif()
		find_library(qtpcred_STATIC_LIBRARY "qtpcre2${QT_DEBUG_SUFFIX}" PATHS "${OSMAND_OWN_SHIPPED_QT_STATIC}/lib" NO_DEFAULT_PATH)
		if (NOT qtpcred_STATIC_LIBRARY)
			find_library(qtpcred_STATIC_LIBRARY "qtpcre${QT_DEBUG_SUFFIX}" PATHS "${OSMAND_OWN_SHIPPED_QT_STATIC}/lib" NO_DEFAULT_PATH)
		endif()
		set(qtpcre_STATIC_LIBRARIES "")
		if (qtpcre_STATIC_LIBRARY AND qtpcred_STATIC_LIBRARY)
			set(qtpcre_STATIC_LIBRARIES ${qtpcre_STATIC_LIBRARIES}
				optimized ${qtpcre_STATIC_LIBRARY}
			)
		else()
			set(qtpcre_STATIC_LIBRARIES ${qtpcre_STATIC_LIBRARIES}
				${qtpcre_STATIC_LIBRARY}
			)
		endif()
		if (qtpcred_STATIC_LIBRARY)
			set(qtpcre_STATIC_LIBRARIES ${qtpcre_STATIC_LIBRARIES}
				debug ${qtpcred_STATIC_LIBRARY}
			)
		endif()
	endif()
endif()
