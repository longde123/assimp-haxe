# assimp-haxe
Haxe porting of Assimp https://github.com/assimp/assimp

This port is being written trying to stick as much as possible close to the C version in order to:

minimize maintenance to keep it in sync with the original
minimize differences for people used to dev/work with Assimp


If you have a format or a feature which is not yet supported, you can use the original assimp (or the lwjgl one) to load the mesh you have and save it in assimp binary format (.assbin). Once done, you can load it with this port.

need https://github.com/hamaluik/haxe-glm


Do not hesitate to offer any help: pushes (any thing, it doesn’t matter), testing, website, wiki, etc

