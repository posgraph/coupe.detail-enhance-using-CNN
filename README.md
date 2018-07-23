# Introduction
This project uses a Convolutional Neural Network (CNN) to improve a color contrast and detail of images.
It is implemented based on the source code of SRCNN [1]. It uses local Laplacian filter [2] for generating dataset.

## How to use it
Requirement: Matlab <br>
Tested OS: Ubuntu 14.04<br>
Installation procedure:<br>

1. use generateSet.m for generating a training dataset
2. use genSRCNN.m for producing color enhanced images

## About Coupe Project
Project ‘COUPE’ aims to develop software that evaluates and improves the quality of images and videos based on big visual data. To achieve the goal, we extract sharpness, color, composition features from images and develop technologies for restoring and improving by using it. In addition, personalization technology through user preference analysis is under study.

Please checkout out other Coupe repositories in our Posgraph github organization.

## Coupe Project
* [Coupe Website](http://coupe.postech.ac.kr/)
* [POSTECH CG Lab.](http://cg.postech.ac.kr/)

## Reference
* Paris et al., "Local Laplacian Filters: Edge-aware Image Processing with a Laplacian Pyramid", In proc. SIGGRAPH 2011.
* Dong et al., "Image Super-Resolution Using Deep Convolutional Networks", In proc. ECCV 2014.
