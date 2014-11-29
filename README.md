![Project Logo](https://raw.githubusercontent.com/alexkaessner/HotSphere/master/Graphics/_Exports/Logo.png)

HotSphere
=======

HotSphere is a students project during the project weeks in the first semester at the [University of Applied Sciences Potsdam](http://www.fh-potsdam.de).  You can find the project documentation [here](https://incom.org/projekt/5165).

The HotSphere is a controller device for a computer, that captures an analog signal of a small ball and converts it to digital coordinates.  
We build the controller and created a game for it, that uses the coordinates of the ball to control a hotwire game. 

## The Controller
We used a big plastic sphere as case. Inside the sphere is a webcam that looks down to the bottom of the case. On the bottom is a small ball. The cam recognizes the movement of the small ball using OpenCV (for processing). This works best if the case is white inside and the ball black (or vice versa). Because it’s dark inside a non-transparent sphere (after spray) we included some LED’s inside the sphere to produce a regular light. The cam is connected to a Mac or PC using USB. Because USB has too less power, we used a normal power point to supply the LED’s.
If you use cheap materials you can build this controller for a few bucks. A cheap webcam is quite sufficient here.

![Blueprint](https://raw.githubusercontent.com/alexkaessner/HotSphere/master/Graphics/Photos/blueprint.png)
![Controller](https://raw.githubusercontent.com/alexkaessner/HotSphere/master/Graphics/Photos/controller.jpg)
![Controller inside](https://raw.githubusercontent.com/alexkaessner/HotSphere/master/Graphics/Photos/controller-inside.jpg)
![Controller final](https://raw.githubusercontent.com/alexkaessner/HotSphere/master/Graphics/Photos/controller-final.jpg)

##The Game
We’ve developed a game to use the controller. This game is a remake of the classic hot wire game. You have to control the player pin through a randomly generated level. If you touch the edge you loose, but don’t worry you can try the exact same level again. If you reach the end you start the next and harder level.  
We created an algorithm that truly randomizes each level based on the difficulty. So even the same level will look always different if you start a new game.

![Controller final](https://raw.githubusercontent.com/alexkaessner/HotSphere/master/Graphics/Photos/level.png)

##Setup (or what you need)
- [Processing](https://processing.org) *(we used v2.2.1 during development)*
- [OpenCV for Processing](https://github.com/atduskgreg/opencv-processing) *(we used v0.4.5 during development)*

The project includes several test units. The *most interesting* tests are:

- **CameraCheck** - shows all recognized webcams in the log and shows a window with the live preview of one cam
![CameraCheck](https://raw.githubusercontent.com/alexkaessner/HotSphere/master/Graphics/Photos/Screenshots/CameraCheck.png)
- **ImageFiltering** by [Jordi Tost](https://github.com/jorditost) *(requires [controlP5](http://www.sojamo.de/libraries/controlP5/))*
![ImageFiltering](https://raw.githubusercontent.com/alexkaessner/HotSphere/master/Graphics/Photos/Screenshots/ImageFiltering.png)