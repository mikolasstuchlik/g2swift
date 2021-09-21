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
