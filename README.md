# g2swift

The g2swift package is ment as a demonstrator of alternative technologies, that could be used to generate Swift wrappers around GLib/GObject based libraries. 

The package does not aim at replacing the gir2swift, but goes for more experimental approach. Idealy, parts of the `g2swift` that will be considered stable enought should be incorporated into the `gir2swift`.

**The `g2swift` design philosophy is.** :
 * The code must be readable and clean.
 * Prefer less dependencies.
 * Get data from `.gir` files, C api using SourceKit and at most 1 `.yaml` configuration file.
 * The API data will be collected into a SQLite database which will be the destination of parsin and the sole source for generation.

**Aim of this repository is NOT to** :
 * Replace gir2swift.
 * Generate the full wrapper.

Any code contributions or ideas are welcome.

# Usage

Since this repository is a collection of tools, this section will describe various use cases this package can be used to do.

## Debugging SourceKitten
SourceKit will dump additional information to the stdout if ENV contains `SOURCEKIT_LOGGING=3`.

## SourceKit configuration
In case that this package is executed on linux, you need to set the ENV varibale `LINUX_SOURCEKIT_LIB_PATH=` to contain the path to the directory, where `libsourcekitdInProc.so` is stored. DO NOT move the `libsourcekitdInProc.so` or maky symbolic links. If you do so, SourceKit will report an error.

## The `sourcekit` mode
In SourceKit mode, the program will query sourcekit for information about specified module. In order to provide a clearer image of what happens, there is a feature which recursively iterates through the date and prints all items with specified SourceKit kind.

## The DIAGNOSTIC macro
If you set the DIAGNOSTIC macro `-Xswiftc -DDIAGNOSTIC`, you will unlock additional features desribed in following section.

# The DIAGNOSTIC usage

The DIAGNOTIC macro unlocks additional features, that are mainly used for debugging etc. I thought that it would be a shame not to publish them too, since a lot of useful code is implemented there.

## --generate-module-definition flag
If `--generate-module-definition` is set, the program will query the SourceKit. The result will then be searched, and the program will print a Module Response definition, that will parse the module.
