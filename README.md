# Roguelike
An ambitious mod for Titanfall 2's campaign. You're welcome to contribute &amp; playtest - however this mod is far from finished and misses a lot of content.
# Contributing
You're welcome to contribute to this mod by making a Pull Request. Wether it is a new item, or a gameplay mechanic, but it may get denied, even if the implementation is perfect. However, some things are still missing from the mod and I will very much appreiciate any help in the following things:

## Items

MAKE MORE ITEMS! Anything you wish! Just add them in!

## Tutorial

A basic tutorial should be made in the gauntlet to explain how Roguelike is played.

## Guidelines

Please make sure things stay moddable. Other people should be able to make additional content for this without overriding a single file. Also, please document your things. I will soon do so myself, but I wasn't expecting to make development of this project public. 

# Notes
## Dependencies

As of now, HUDRevamp (along with it's dependencies) is required for this mod to function. This is because we use `BasicImageBar` to create some parts of the HUD. Eventually, I would like to move basic_image_bar.gnut to the Roguelike mod, but as of now this is impossible because registering a custom script twice causes an engine error. This will, however later be done.
