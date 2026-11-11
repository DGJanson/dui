# DUI

Davids UI library.

This holds some convenience procedures for using raylib and odin. Mostly based on UI, not necessarily heavy graphics stuff.

Only works with **monospace** fonts. This will likely NOT change.

Some procs may use the context.temp_allocator for simple allocs, without freeing. We assume the procs will be used in a program that uses a (draw) loop that does free the temp_allocator.

It is very much a first version, not much yet.

Components as of now:

- layout: has some convenience procs for handling raylib Rects
- textarea: a textarea component. Use it for longish stretches of text. Supports wrapping. Create it once with an allocator (and delete later). This does all calcs. The draw function will then simply draw without need for allocations.
- textbox: a first version of a user editable text component
- style: a first version of a struct with some style defaults. Not set in stone yet
