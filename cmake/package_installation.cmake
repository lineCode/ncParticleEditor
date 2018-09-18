set(RUNTIME_INSTALL_DESTINATION bin)
set(LIBRARY_INSTALL_DESTINATION lib)

if(MSVC OR APPLE)
	set(README_INSTALL_DESTINATION .)
	set(DATA_INSTALL_DESTINATION data)
	set(SHADERS_INSTALL_DESTINATION data/shaders)
else()
	set(README_INSTALL_DESTINATION share/${PACKAGE_LOWER_NAME})
	set(DATA_INSTALL_DESTINATION share/${PACKAGE_LOWER_NAME}/data)
	set(SHADERS_INSTALL_DESTINATION share/${PACKAGE_LOWER_NAME}/shaders)
endif()

set(CPACK_PACKAGE_NAME "${PACKAGE_NAME}")
set(CPACK_PACKAGE_VENDOR "")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY ${PACKAGE_DESCRIPTION})
set(CPACK_PACKAGE_CONTACT ${PACKAGE_AUTHOR_MAIL})
set(CPACK_PACKAGE_VERSION ${PACKAGE_VERSION})
set(CPACK_PACKAGE_VERSION_MAJOR ${PACKAGE_MAJOR_VERSION})
set(CPACK_PACKAGE_VERSION_MINOR ${PACKAGE_MINOR_VERSION})
set(CPACK_PACKAGE_VERSION_PATCH ${PACKAGE_PATCH_VERSION})
set(CPACK_PACKAGE_INSTALL_DIRECTORY "${PACKAGE_NAME}")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/LICENSE")
set(CPACK_PACKAGE_CHECKSUM MD5)

if(MSVC)
	set(CPACK_GENERATOR NSIS ZIP)
	set(CPACK_NSIS_MUI_ICON "${PACKAGE_DATA_DIR}/icons/${PACKAGE_ICON_NAME}.ico")
	set(CPACK_NSIS_COMPRESSOR "/SOLID lzma")
	# Custom NSIS commands needed in order to set the "Start in" property of the start menu shortcut
	set(CPACK_NSIS_CREATE_ICONS_EXTRA
		"SetOutPath '$INSTDIR\\\\bin'
		CreateShortCut '$SMPROGRAMS\\\\$STARTMENU_FOLDER\\\\${PACKAGE_NAME}.lnk' '$INSTDIR\\\\bin\\\\${PACKAGE_EXE_NAME}.exe'
		SetOutPath '$INSTDIR'")
	set(CPACK_NSIS_DELETE_ICONS_EXTRA "Delete '$SMPROGRAMS\\\\$MUI_TEMP\\\\${PACKAGE_NAME}.lnk'")

	include(InstallRequiredSystemLibraries)
elseif(APPLE)
	set(CPACK_GENERATOR "Bundle")
	set(CPACK_BUNDLE_NAME ${PACKAGE_NAME})
	set(FRAMEWORKS_INSTALL_DESTINATION ../Frameworks)

	configure_file(${CMAKE_SOURCE_DIR}/Info.plist.in ${CMAKE_BINARY_DIR}/Info.plist @ONLY)
	set(CPACK_BUNDLE_PLIST ${CMAKE_BINARY_DIR}/Info.plist)

	file(RELATIVE_PATH RELPATH_TO_BIN ${CMAKE_INSTALL_PREFIX}/MacOS ${CMAKE_INSTALL_PREFIX}/Resources/${RUNTIME_INSTALL_DESTINATION})
	file(WRITE ${CMAKE_BINARY_DIR}/bundle_executable "#!/usr/bin/env sh\ncd \"$(dirname \"$0\")\" \ncd ${RELPATH_TO_BIN} && ./${PACKAGE_EXE_NAME}")
	install(FILES ${CMAKE_BINARY_DIR}/bundle_executable DESTINATION ../MacOS/ RENAME ${CPACK_BUNDLE_NAME}
		PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE COMPONENT tests)

	add_custom_command(
		OUTPUT ${CMAKE_BINARY_DIR}/${CPACK_BUNDLE_NAME}.iconset
		COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/${CPACK_BUNDLE_NAME}.iconset
		COMMAND ${CMAKE_COMMAND} -E copy_if_different ${PACKAGE_DATA_DIR}/icons/icon1024.png ${CMAKE_BINARY_DIR}/${CPACK_BUNDLE_NAME}.iconset/icon_512x512@2x.png
		COMMAND sips -z 512 512 ${PACKAGE_DATA_DIR}/icons/icon1024.png --out ${CMAKE_BINARY_DIR}/${CPACK_BUNDLE_NAME}.iconset/icon_512x512.png
		COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_BINARY_DIR}/${CPACK_BUNDLE_NAME}.iconset/icon_512x512.png ${CMAKE_BINARY_DIR}/${CPACK_BUNDLE_NAME}.iconset/icon_256x256@2x.png
		COMMAND sips -z 256 256 ${PACKAGE_DATA_DIR}/icons/icon1024.png --out ${CMAKE_BINARY_DIR}/${CPACK_BUNDLE_NAME}.iconset/icon_256x256.png
		COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_BINARY_DIR}/${CPACK_BUNDLE_NAME}.iconset/icon_256x256.png ${CMAKE_BINARY_DIR}/${CPACK_BUNDLE_NAME}.iconset/icon_128x128@2x.png
		COMMAND sips -z 128 128 ${PACKAGE_DATA_DIR}/icons/icon1024.png --out ${CMAKE_BINARY_DIR}/${CPACK_BUNDLE_NAME}.iconset/icon_128x128.png
		COMMAND sips -z 64 64 ${PACKAGE_DATA_DIR}/icons/icon1024.png --out ${CMAKE_BINARY_DIR}/${CPACK_BUNDLE_NAME}.iconset/icon_32x32@2x.png
		COMMAND sips -z 32 32 ${PACKAGE_DATA_DIR}/icons/icon1024.png --out ${CMAKE_BINARY_DIR}/${CPACK_BUNDLE_NAME}.iconset/icon_32x32.png
		COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_BINARY_DIR}/${CPACK_BUNDLE_NAME}.iconset/icon_32x32.png ${CMAKE_BINARY_DIR}/${CPACK_BUNDLE_NAME}.iconset/icon_16x16@2x.png
		COMMAND sips -z 16 16 ${PACKAGE_DATA_DIR}/icons/icon1024.png --out ${CMAKE_BINARY_DIR}/${CPACK_BUNDLE_NAME}.iconset/icon_16x16.png
		COMMAND iconutil --convert icns --output ${CMAKE_BINARY_DIR}/${CPACK_BUNDLE_NAME}.icns ${CMAKE_BINARY_DIR}/${CPACK_BUNDLE_NAME}.iconset)
	add_custom_target(iconutil_convert ALL DEPENDS ${CMAKE_BINARY_DIR}/${CPACK_BUNDLE_NAME}.iconset)
	set(CPACK_BUNDLE_ICON ${CMAKE_BINARY_DIR}/${CPACK_BUNDLE_NAME}.icns)
elseif(UNIX AND NOT APPLE)
	set(CPACK_GENERATOR TGZ)
	set(ICONS_INSTALL_DESTINATION share/icons/hicolor)

	if(EXISTS ${PACKAGE_DATA_DIR}/icons)
		install(FILES ${PACKAGE_DATA_DIR}/icons/icon1024.png DESTINATION ${ICONS_INSTALL_DESTINATION}/1024x1024/apps/ RENAME ${PACKAGE_ICON_NAME}.png)
		install(FILES ${PACKAGE_DATA_DIR}/icons/icon192.png DESTINATION ${ICONS_INSTALL_DESTINATION}/192x192/apps/ RENAME ${PACKAGE_ICON_NAME}.png)
		install(FILES ${PACKAGE_DATA_DIR}/icons/icon96.png DESTINATION ${ICONS_INSTALL_DESTINATION}/96x96/apps/ RENAME ${PACKAGE_ICON_NAME}.png)
		install(FILES ${PACKAGE_DATA_DIR}/icons/icon72.png DESTINATION ${ICONS_INSTALL_DESTINATION}/72x72/apps/ RENAME ${PACKAGE_ICON_NAME}.png)
		install(FILES ${PACKAGE_DATA_DIR}/icons/icon48.png DESTINATION ${ICONS_INSTALL_DESTINATION}/48x48/apps/ RENAME ${PACKAGE_ICON_NAME}.png)
	endif()

	install(FILES ${CMAKE_SOURCE_DIR}/${PACKAGE_DESKTOP_FILE} DESTINATION share/applications)
elseif(MINGW)
	set(CPACK_GENERATOR TGZ)
endif()

include(CPack)