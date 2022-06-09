#!/bin/bash

# --duration Duration in minutes for timer
# --notes Location of notes on ultrawide PDF
# --presenter-screen screen to use for presenter overview (next slide, notes)
# --presentation-screen screen to use for presentation (fullscreen slide)
pdfpc --duration=15 --presenter-screen=eDP-1 --presentation-screen=DP-1 surf.pdf
