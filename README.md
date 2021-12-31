# QBCPS Turn Based Game Server

This is the server component of a generic system to operate
turn-based games.

The server is agnostic as to the game itself -- games are defined
in plugins that implement the `Game` protocol, defined in the
[tbgs-shared](https://github.com/sbeitzel/tbgs-shared) library.
