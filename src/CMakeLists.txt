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
find_package(Qt6 REQUIRED COMPONENTS Core Widgets Gui QuickWidgets Charts Network Svg Xml QuickControls2)

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

target_include_directories(nomweather PUBLIC ${Qt6Gui_PRIVATE_INCLUDE_DIRS})

target_include_directories(nomweather PUBLIC
        ${CMAKE_SOURCE_DIR}/src
        ${X11_INCLUDE_DIR}
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${Qt6Core_INCLUDE_DIRS}
        ${Qt6Widgets_INCLUDE_DIRS}
        ${Qt6Gui_INCLUDE_DIRS}
        ${Qt6Network_INCLUDE_DIRS}
        ${Qt6Svg_INCLUDE_DIRS}
        ${Qt6Xml_INCLUDE_DIRS}
        ${Qt6WebSockets_INCLUDE_DIRS}
        ${Qt6Charts_PRIVATE_INCLUDE_DIRS}
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
        ${Qt6Core_DEFINITIONS}
        ${Qt6Widgets_DEFINITIONS}
        ${Qt6Gui_DEFINITIONS}
        ${Qt6Network_DEFINITIONS}
        ${Qt6Svg_DEFINITIONS}
        ${Qt6Xml_DEFINITIONS}
        ${Qt6WebSockets_DEFINITIONS}
        )

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${Qt6Widgets_EXECUTABLE_COMPILE_FLAGS}")

target_link_libraries(nomweather PUBLIC
        ${CMAKE_DL_LIBS}
        Qt6::Core
        Qt6::Widgets
        Qt6::Gui
        Qt6::Network
        Qt6::Charts
        Qt6::Xml
        Qt6::Quick
        Qt6::QuickWidgets
        Qt6::Qml
        Qt6::QuickControls2
        ${X11_LIBRARIES}
        Threads::Threads
)

qt6_add_qml_module(Main
        STATIC
        URI Main
        VERSION 1.0
        OUTPUT_DIRECTORY qml_main
        RESOURCE_PREFIX ""
        RESOURCES
            assets/Glance/0.png
            assets/Glance/10.png
            assets/Glance/11.png
            assets/Glance/12.png
            assets/Glance/13.png
            assets/Glance/14.png
            assets/Glance/15.png
            assets/Glance/16.png
            assets/Glance/17.png
            assets/Glance/18.png
            assets/Glance/19.png
            assets/Glance/1.png
            assets/Glance/20.png
            assets/Glance/21.png
            assets/Glance/22.png
            assets/Glance/23.png
            assets/Glance/24.png
            assets/Glance/25.png
            assets/Glance/26.png
            assets/Glance/27.png
            assets/Glance/28.png
            assets/Glance/29.png
            assets/Glance/2.png
            assets/Glance/30.png
            assets/Glance/31.png
            assets/Glance/32.png
            assets/Glance/33.png
            assets/Glance/34.png
            assets/Glance/35.png
            assets/Glance/36.png
            assets/Glance/37.png
            assets/Glance/38.png
            assets/Glance/39.png
            assets/Glance/3.png
            assets/Glance/40.png
            assets/Glance/41.png
            assets/Glance/42.png
            assets/Glance/43.png
            assets/Glance/44a.png
            assets/Glance/44.png
            assets/Glance/45.png
            assets/Glance/46.png
            assets/Glance/47.png
            assets/Glance/48.png
            assets/Glance/4.png
            assets/Glance/5.png
            assets/Glance/6.png
            assets/Glance/7.png
            assets/Glance/8.png
            assets/Glance/9.png
            assets/Glance/dark_cloud.png
            assets/Glance/dropice.png
            assets/Glance/drop.png
            assets/Glance/dust.png
            assets/Glance/fog.png
            assets/Glance/fulllight.png
            assets/Glance/gray_cloud.png
            assets/Glance/haze.png
            assets/Glance/hotsun.png
            assets/Glance/ice_cloud.png
            assets/Glance/iceshatter.png
            assets/Glance/light_cloud.png
            assets/Glance/light.png
            assets/Glance/medium_gray_cloud.png
            assets/Glance/moon4.png
            assets/Glance/na.png
            assets/Glance/shatter.png
            assets/Glance/small_gray_cloud.png
            assets/Glance/smoke.png
            assets/Glance/snowflake_light.png
            assets/Glance/snowflake.png
            assets/Glance/sun.png
            assets/Glance/transparency_cloud.png
            assets/Glance/two_gray_cloud.png
            assets/Glance/two_gray_clouds.png
            assets/Glance/two_light_clouds.png
            assets/Glance/wind.png
            assets/general_settings.png
        QML_FILES
            qml/AreaFlick.qml
            qml/DayItem.qml
            qml/Main.qml
)
target_link_libraries(
        Main PRIVATE
        Qt6::Core
        Qt6::Widgets
        Qt6::Gui
        Qt6::Network
        Qt6::Charts
        Qt6::Xml
        Qt6::Quick
        Qt6::QuickWidgets
        Qt6::Qml
        Qt6::QuickControls2
)
target_link_libraries(nomweather PRIVATE Mainplugin)

install(TARGETS nomweather
        DESTINATION bin
        )
