from re import X
import numpy as np
import sys

"""
This script converts a wavefront obj model into a 3dc/3dg model.

============ Input Format ==================
the wavefront obj model must contain a single object and the format must be that of
faces with position/uv/normal, which is the default export of blender.

============= 3DC Binary Format ==============
The 3dc model type is only used for collision purposes so it does not contain UV data. 
The binary format is simple: the first four bytes are an integer with the number of 
triangles encoded in the file, let's call it N. It is followed by N*9 floats that determine each
triangle vertex position in this order:
N * { V0x, V0y, V0z, V1x, V1y, V1z, V2x, V2y, V2z }
The three vertices of each triangle are sorted such that you can compute the normal by doing
normalize((V2-V0) x (v1-v0)) and it will be pointing in the same direction as the one
coming from the wavefront obj data, which should be pointing towards the outside of the 3D shape.

============ 3DG Binary Format ==============
The 3dg model is for graphics purposes and so, for each vertex, it contains the raw data
x,y,z,u,v,nx,ny,nz.
The 3dg model format does not include the initial number of vertices so that it can be
directly imported as a vertex buffer
"""

def floatToBytes(f) -> bytes:
    import struct
    return bytearray(struct.pack("f",f))

# User parameters
INPUT_FNAME = sys.argv[1]

# Constant dedfinitions
WHITE = (1,1,1)
MODE_3DC = 0
MODE_3DG = 1

statsUndef = True
statsX = []
statsY = []
statsZ = []
def convert(fname,mode):
    global statsUndef, statsX, statsY, statsZ
    out = open(fname + "." + ("3dc","3dg")[mode],"wb")
    # Extract all data from input file
    vertices,uvs,normals,faces = [],[],[],[]
    triangles = []
    for line in open(fname).readlines():
        line = [l.replace("\n","") for l in line.split(" ")]
        if line[0] == "v":
            x,y,z = (float(line[1]),float(line[2]),float(line[3]))
            vertices.append( (x,y,z) )
            if statsUndef:
                statsUndef = False
                statsX.append(x)
                statsX.append(x)
                statsY.append(y)
                statsY.append(y)
                statsZ.append(z)
                statsZ.append(z)
            else:
                statsX[0] = min(statsX[0],x)
                statsY[0] = min(statsY[0],y)
                statsZ[0] = min(statsZ[0],z)
                statsX[1] = max(statsX[1],x)
                statsY[1] = max(statsY[1],y)
                statsZ[1] = max(statsZ[1],z)
            

        if line[0] == "vt":
            uvs.append( (float(line[1]),float(line[2]))  )
        if line[0] == "vn":
            normals.append( (float(line[1]),float(line[2]),float(line[3])) )
        if line[0] == "f":
            # Each face is a collection of three vertices
            # each vertex is a tuple of three integer indices
            # vertex index / uv index / normal index
            # these indices refer to the vertices, uvs and normals lists.
            faces.append( (
                tuple(int(i)-1 for i in line[1].split("/")), 
                tuple(int(i)-1 for i in line[2].split("/")),
                tuple(int(i)-1 for i in line[3].split("/"))
            ) )

    print("Size: %f,%f,%f" % (statsX[1]-statsX[0], statsY[1]-statsY[0], statsZ[1]-statsZ[0]))
    print("X: <%f,%f>\nY: <%f,%f>\nZ: <%f,%f>" % (statsX[0],statsX[1],statsY[0],statsY[1],statsZ[0],statsZ[1]))
    # Write output binary file
    print( f"found {len(faces)} triangles" )
    out.write(int.to_bytes(len(faces),4,'little'))
    for face in faces:
        (v0,uv0,n0),(v1,uv1,n1),(v2,uv2,n2) = face
        if mode == MODE_3DC:
            normal = np.cross(np.subtract(vertices[v1],vertices[v0]),np.subtract(vertices[v2],vertices[v0]))
            normal = np.divide(normal,np.sqrt(np.dot(normal,normal)))
            tris = (vertices[v0], vertices[v1], vertices[v2], tuple(normal), (float(np.dot(normal,vertices[v0])),)) 
        else:
            tris = (
                vertices[v0], WHITE, uvs[uv0], normals[n0],
                vertices[v1], WHITE, uvs[uv1], normals[n1],
                vertices[v2], WHITE, uvs[uv2], normals[n2],
            )
        for element in tris:
            for component in element:
                out.write(floatToBytes(component))

if __name__ == "__main__":
    convert(INPUT_FNAME,MODE_3DG)
    convert(INPUT_FNAME,MODE_3DC)