## NOMWeather

NOMWeather (not open maemo weather) fetches weather data from Open-Meteo.com (FOSS Weather API) and uses IP-API.com for lat/lon discovery via network.

- Supports most locations on the planet
- Temperature in celcius or fahrenheit
- 7-day forecast 
- Optional wind data (km/h) and precipitation
- Qt 5.15, CMake, CCache
- QtWidgets & QtQuick

The application is called **not** open maemo weather because during development people kept referring to OMWeather (a legacy maemo application).

![https://i.imgur.com/AwqiVGy.jpg](https://i.imgur.com/AwqiVGy.jpg)

### Repository

On Maemo Leste, `nomweather` is availabe as a package in the repository:

```bash
sudo apt install -y nomweather
```

It registers a startup item and can be launched from the menu.

### Compile

You can install build-dependencies using:

```text
sudo apt build-dep nomweather
```

And install additional run-time dependencies using:

```text
sudo apt install qml-module-qtcharts
```

The following command assumes you satisfy the Qt5 depedencies neccesary:

```text
cmake -Bbuild . -DCMAKE_BUILD_TYPE=Debug
make -Cbuild -j2
./build/bin/nomweather
```

### Notes

- Would be nice to support desktop widgets (like OMWeather). Currently unclear how to do this in a preferably Qt-oriented manner.
- When supporting desktop widgets, probably best to encapsulate this app's business logic (fetching of API data) in a daemon so both GUI (QtQuick) and the widgets can use that.
- This application works fine on desktop too (e.g: Ubuntu), the fonts are a bit big though.
- There is a config file located at `~/.config/nomweather/settings.json` where it saves user preferences.
- Currently only supports landscape mode
- Loading the graph takes 100ms on droid4, should be fine on n900 too.
- This application was made fast and 'shortcuts' were taken in the QML code.
- Possible to-do: QML theming
