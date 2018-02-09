# homework-3-case-study

Name: Alexis Ward

PennKey: aleward

# Assignment Description

For this assignment, you will re-create various animations demonstrating a combination of toolbox functions and the rendering techniques you've already learned. The motivation for this is to help you become more familiar with toolbox functions as well as give you experience in producing a desired aesthetic.

Below are multiple examples of periodic animations with assigned point values. You are required to complete EITHER:
* One intermediate animation and one hard animation
* Three intermediate animations
* One Duck-Level-hard animation (at the very bottom)

You have three options for implementing these:
* Rasterizer, like homework 1
* Raymarcher / implicit surfaces, like homework 2
* Shadertoy (probably the easiest)

You can also implement different scenes with different methods.

If you'd like to implement any animations that are not listed below, you can make a _private_ post on Piazza and we will decide if they are appropriate for the assignment, and their difficulty classification. Check [/r/loadingicon](https://www.reddit.com/r/loadingicon) on Reddit for inspiration.

*Extra Credit*: you can earn extra credit by creating interesting twists e.g. materials and animations that are not in the original reference. Since we are grading reference matching, additional features must be toggleable, either by a GUI option in your webgl site or by a #define statement in your Shadertoy code. This must be described in your writeup. Additionally, some of the references have some attributes that are exceptionally difficult, and do not need to be implemented for full credit; we will note what these are and they can count for extra credit.

# Submission

You must submit a writeup for this assignment by 11:59 PM on Thursday, Feb. 8th to canvas *as a .pdf or .txt*. If your projects are hosted on Github you should copy your writeup to a readme.

Writeups must include, for each scene:
* A link to the online implementation : [here](https://aleward.github.io/case-study-aleward/)
* A link to the reference animation :
<img src="http://i.imgur.com/0kvtMLE.gif" width="400px" />

* *Detailed* description of techniques used to emulate the reference, for both motion and rendering:

I shaped the duck using SDFs with the base code from HW2. I utilized several IQ functions as a foundation for my shapes, and transformed them (primarily with sin functions) for both aesthetic and motion. I colored the individual duck components based on the final signed distance for each pixel (determined by the four booleans I set up, which are checked each SDF iteration). I then colored outlines based on lambert-induced shading.


# Evaluation

Each intermediate scene is worth 1/3 credit. Difficult scenes are 2/3 credit. Duck-level scenes are worth 100% credit.
Extra credit is at grader discretion and cannot exceed 20 points.

*If we cannot view your work online it will receive no credit.*

All shaders will be graded by this scheme:
* 65% Reference matching: does this show understanding of the motion, colors, and rendering techniques required to create the animation? This does not have to be pixel-perfect for full credit.
* 20% Writeup completeness
* 15% Performance considerations: motion should be fluid, ideally no less than 30 FPS at Shadertoy-resolution on a gaming laptop. If your shader (without EC) is seriously under-performant there will be a point penalty.

# References: Intermediate Difficulty

## Sweet Swing
<img src="Images/sweetSwing.gif" width="400px" />

#### Extra credit:
- Convincing materials, rendering, textures

## Cut Cube
<img src="https://i.imgur.com/sZa2PPI.gif" width="400px" />

## Speedy Spin OR Speedy Cube
<img src="https://i.imgur.com/AI00mHu.gif" width="400px" />
<img src="https://i.imgur.com/Ltm5xjD.gif" width="400px" />

#### Notes:
- Motion blur is required, *not* extra credit

## Paw Metaballs
<img src="https://assets0.ello.co/uploads/asset/attachment/5159868/ello-optimized-99a5cfbf.gif" width="400px" />

#### Notes:
- Smooth blending during separation and joining of blobs is required

## Tri-Colored Cube
<img src="https://i.redd.it/e8dcpl3rw32z.gif" width="400px" />

## Spindle of Death
<img src="https://media.giphy.com/media/26DN7fdyFRqfBjqMw/giphy.gif" width="400px" />

# References: Hard Difficulty

## Electron Orbitals
<img src="http://i.imgur.com/MNw0Vrm.gif" width="400px" />

## Rainbow Step Cube
<img src="https://78.media.tumblr.com/a5fc5d607e40fe345f5ba6e10fbb21a3/tumblr_or5m8jLTtd1r65ii5o1_500.gif" width="400px" />

#### Notes:
- Height variation is required in the extrustions

## Bubbling Beaker
<img src="https://d13yacurqjgara.cloudfront.net/users/318273/screenshots/2029648/verve_lab_dribbble.gif" width="400px" />

## Chocolate-Loving Shark
<img src="https://i.imgur.com/ClgFpAW.gif" width="400px" />

#### Notes:
- Soft shadows required

#### Extra Credit:
- Depth of field (screenspace, IQ has examples)

## GameCube Loading Screen
<img src="Images/gameCubeLogo.gif" width="400px" />

#### Notes:
- No text required

# Reference: Duck Level Difficulty
<img src="http://i.imgur.com/0kvtMLE.gif" width="400px" />

#### Specifications:
_good luck, duck!_
- Modelling the duck
- Head Bob
- Tail Wag
- Match the movement of the feet
- Shading of the duck
- Fake shadows as circles

