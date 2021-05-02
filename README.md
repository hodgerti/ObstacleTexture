### Obstacle Textures

#### About

Obstacle textures are a method of 2D collision that use no physics at all. This works by first packing a texture full of obstacle posistions one time before the application runs or right as it starts. Then, inside a particle shader (AKA a data shader), the world position of a particle is compared with the texture to see if it is intersecting with an obstacle. 

### Pros

- Comparatively priceless physics collisions.

### Cons

- Less precise collisions in the visual sense.
- No interaction possible with the rest of the physics system.


#### How to Use

This repo includes a godot 3.2.2 project file that is a tested and working demonstration of the concept of obstacle textures.

It also includes a standalone windows 10 64 bit excutable in the exports folder.
