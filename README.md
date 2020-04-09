# Discrete Scroll

[![Downloads](https://img.shields.io/github/downloads/emreyolcu/discrete-scroll/total.svg)](https://github.com/emreyolcu/discrete-scroll/releases)

Fix for OS X's scroll wheel problem

jdahlq: Also reverse the scroll direction in order to keep the "natural" direction for traackpad only on MacOS.
jdahlq: Also re-map right shift/cmd to up/down when they are pressed and released. This helps for 60% keyboards.

## Installation

You may download the binary
[here](https://github.com/emreyolcu/discrete-scroll/releases/download/v0.1.1/DiscreteScroll.zip). It
runs in the background and allows you to scroll 3 lines with each tick of the
wheel.

It needs to be run each time you boot. If you want this to be automatic you
may go to `System Preferences > Users & Groups > Login Items` and add
`DiscreteScroll` to the list. If you want to undo the effect you may launch
Activity Monitor, search for `DiscreteScroll` and force it to quit.
