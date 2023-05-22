set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# PNG
find_package(ZLIB REQUIRED)
find_package(PNG REQUIRED)

# the source files
file(GLOB SOURCE_FILES
        "*.h"
        "*.cpp"
        "areachart/*.cpp"
        "areachart/*.h"
        "lib/*.h"
        "lib/*.cpp"
        )

# Find Qt. Use a CMake definition to point it to your Qt installation
# location (if necessary), e.g: -DCMAKE_PREFIX_PATH=/home/user/Qt/5.15.2/gcc_64
find_package(Qt5 REQUIRED COMPONENTS Core Widgets Gui Charts Network DBus Svg Xml Quick QuickWidgets Qml QuickControls2 QuickCompiler)

qtquick_compiler_add_resources(RESOURCES assets.qrc)

set(EXECUTABLE_FLAG)

# Mac OS bundle
if(APPLE)
    set(ICON ${PROJECT_SOURCE_DIR}/src/assets/appicons/appicon.icns)
    set_source_files_properties(${ICON} PROPERTIES MACOSX_PACKAGE_LOCATION "Resources")
    list(APPEND RESOURCES ${ICON})
endif()

add_executable(nomweather ${EXECUTABLE_FLAG} main.cpp
        ${SOURCE_FILES}
        ${RESOURCES}
        )

# Mac OS bundle
if(APPLE)
    set_target_properties(nomweather PROPERTIES
            RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
            MACOSX_BUNDLE TRUE
            MACOSX_BUNDLE_INFO_PLIST "${CMAKE_SOURCE_DIR}/utils/Info.plist"
            LINK_FLAGS_RELEASE -s
            )
endif()

set_property(TARGET nomweather PROPERTY RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")

target_include_directories(nomweather PUBLIC ${Qt5Gui_PRIVATE_INCLUDE_DIRS})

target_include_directories(nomweather PUBLIC
        ${CMAKE_SOURCE_DIR}/src
        ${X11_INCLUDE_DIR}
        ${OPENSSL_INCLUDE_DIR}
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${Qt5Core_INCLUDE_DIRS}
        ${Qt5Widgets_INCLUDE_DIRS}
        ${Qt5Gui_INCLUDE_DIRS}
        ${Qt5Network_INCLUDE_DIRS}
        ${Qt5Svg_INCLUDE_DIRS}
        ${Qt5Xml_INCLUDE_DIRS}
        ${Qt5WebSockets_INCLUDE_DIRS}
        ${Qt5Charts_PRIVATE_INCLUDE_DIRS}
        )

add_definitions(${QT_DEFINITIONS})
if(NOT "${CMAKE_BUILD_TYPE}" EQUAL "Debug")
    add_definitions(-DQT_NO_DEBUG)
endif()

if(${CMAKE_BUILD_TYPE} STREQUAL Debug)
    target_compile_definitions(nomweather PRIVATE DEBUG=1)
endif()

if(MAEMO)
    # @TODO: should not be necessary, but definition `Q_WS_MAEMO` is *not* available via CMake
    target_compile_definitions(nomweather PRIVATE MAEMO=1)
endif()

target_compile_definitions(nomweather
        PUBLIC
        ${Qt5Core_DEFINITIONS}
        ${Qt5Widgets_DEFINITIONS}
        ${Qt5Gui_DEFINITIONS}
        ${Qt5Network_DEFINITIONS}
        ${Qt5Svg_DEFINITIONS}
        ${Qt5Xml_DEFINITIONS}
        ${Qt5WebSockets_DEFINITIONS}
        )

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${Qt5Widgets_EXECUTABLE_COMPILE_FLAGS}")

target_link_libraries(nomweather PUBLIC
        ${OPENSSL_LIBRARIES}
        ${CMAKE_DL_LIBS}
        Qt5::Core
        Qt5::Widgets
        Qt5::Gui
        Qt5::Network
        Qt5::Charts
        Qt5::Svg
        Qt5::QSvgPlugin
        Qt5::QSvgIconPlugin
        Qt5::Xml
        Qt5::Quick
        Qt5::QuickWidgets
        Qt5::Qml
        Qt5::QuickControls2
        Threads::Threads
)

if(NOT APPLE)
    target_link_libraries(nomweather PUBLIC
            Qt5::QSvgIconPlugin
            Qt5::QSvgPlugin
            )
endif()

if(STATIC)
    target_link_libraries(nomweather PUBLIC
            Qt5::QSvgIconPlugin
            Qt5::QSvgPlugin)
    if(UNIX AND NOT APPLE)
        target_link_libraries(nomweather PUBLIC
                Qt5::QXcbIntegrationPlugin)
    endif()
endif()

if(X11_FOUND)
    target_link_libraries(nomweather PUBLIC ${X11_LIBRARIES})
endif()

if(APPLE)
    include(Deploy)
endif()

install(TARGETS nomweather
        DESTINATION ${CMAKE_INSTALL_PREFIX}
        )
