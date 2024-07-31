import bpy
import os
import json
import mathutils
from math import sqrt,asin,pi
import ctypes  # An included library with Python install.   
import socket
import json
import time
import threading


# This script, when executed inside blender, extracts the data within 
# the collection "Export", when it is present, to a json file for game maker.
# Additionally, if the variable startServer is True, it will connect to 
# the game maker game debug server and update in real time this info
# In GM, the global variable "global.Blender" will hold all the information
startDebugServer = True
storeData = True

# find blender.json filename in the "datafiles" directory for game maker
blend_file_path = bpy.data.filepath
blend_dir = os.path.dirname(bpy.path.abspath(blend_file_path))
fname = os.path.join(blend_dir,"..","blender.json")

# Debug message function
def message(msg):
    ctypes.windll.user32.MessageBoxW(0, str(msg), "Blender", 1)

def getData(collection_name):
    # Replace 'CollectionName' with the name of your collection
    blend_file_path = bpy.data.filepath
    blend_dir = os.path.dirname(bpy.path.abspath(blend_file_path))
    fname = os.path.join(blend_dir, 'blender.json')

    # Get the collection by name
    collection = bpy.data.collections.get(collection_name)
    out_fname = output_file_path = os.path.join(blend_dir, 'data.json')
    if collection is not None:
        data = {
        }
        print(f"Contents of collection '{collection_name}':")
        for obj in collection.objects:
            # -----------------------------------------------------------------
            # Extracting cameras
            # -----------------------------------------------------------------
            if obj.type == "CAMERA": 
                
                # Calculate the FOV
                w = obj.data.sensor_width
                h = obj.data.sensor_height
                f = obj.data.lens
                l = sqrt(w*w/4 + f*f)
                fovX = asin(w/(2*l))*2
                l = sqrt(h*h/4 + f*f)
                fovY = asin(h/(2*l))*2
                
                # Calculate the UP vector
                from_vector = obj.location
                forward_vector = mathutils.Vector((0.0, 0.0, -1.0))
                # Transform the local forward vector to world coordinates
                world_forward_vector = obj.matrix_world.to_3x3() @ forward_vector
                to_vector = from_vector + world_forward_vector
                up_vector = mathutils.Vector((0.0, 0.0, 1.0))
                # Transform the local up vector to world coordinates
                up = obj.matrix_world.to_3x3() @ up_vector
                data[obj.name] = {
                    "From":list(from_vector),
                    "To":list(to_vector),
                    "Up":[-up.x,-up.y,up.z],
                    "FovX":fovX,
                    "FovY":fovY
                }

            # -----------------------------------------------------------------
            # Extracting meshes
            # -----------------------------------------------------------------
            if obj.type == "MESH":
                rot = obj.rotation_euler
                rot = [-rot.x*180/pi,-rot.y*180/pi,-rot.z*180/pi]
                
                matrix_world = obj.matrix_world
                local_x = matrix_world.col[0].to_3d().normalized()
                local_y = matrix_world.col[1].to_3d().normalized()
                local_z = matrix_world.col[2].to_3d().normalized()
                
                data[obj.name] = {
                    "Position": list(obj.location),
                    "Rotation": rot,
                    "Transform":{
                        "i":list(local_x),
                        "j":list(local_y),
                        "k":list(local_z)
                    }
                }
    else:
        message(f"Collection '{collection_name}' not found.")
    return data

def sendData(scene):
    json_data = json.dumps(getData("Export"))
    sock.sendall(json_data.encode('utf-8'))

def saveData():
    data = getData("Export")
    with open(fname,"w") as fout:
        fout.write(json.dumps(data,indent=3))

if storeData:
    saveData()


if startDebugServer:
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect(("localhost", 2233))
    bpy.app.handlers.depsgraph_update_post.append(sendData)