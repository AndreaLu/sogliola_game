import bpy
import json
import os
import math
from mathutils import Vector

# Specify the output file path
# D:\cloud\projects\sogliole\game\sogliola\datafiles
output_file_path = bpy.path.abspath("D:/cloud/projects/sogliole/game/sogliola/datafiles/camera.json")

# Function to get the look-at point
def get_look_at_point(camera, distance=10.0):
    # Get the camera's forward direction
    forward = camera.matrix_world.to_3x3() @ Vector((0.0, 0.0, -1.0))
    forward.normalize()
    
    # Calculate the look-at point
    look_at_point = camera.location + (forward * distance)
    return look_at_point

# Function to get camera properties
def get_camera_data(camera):
    # Calculate the field of view (FOV)

    fov = 2 * math.atan((camera.data.sensor_width / 2) / camera.data.lens)
    #v_fov = 2 * math.atan((camera.data.sensor_height / 2) / camera.data.lens)
    fov = math.degrees(fov)
    
    fov_degrees = math.degrees(fov)
    scene = bpy.context.scene
    render = scene.render
    w = render.resolution_x
    h = render.resolution_y
    
    # Calculate the look-at point
    look_at_point = get_look_at_point(camera)

    cam_data = {
        "location": list(camera.location),
        "lens": camera.data.lens,
        "sensor_width": w,
        "sensor_height": h,
        "clip_start": camera.data.clip_start,
        "clip_end": camera.data.clip_end,
        "fov": fov,
        "to": list(look_at_point)
    }
    return cam_data

# Get the active camera
camera = bpy.context.scene.camera

if camera:
    # Get camera data
    cam = get_camera_data(camera)

    # Write to JSON file
    with open(output_file_path, 'w') as outfile:
        outfile.write( str( cam["location"][0] ) + "\n")
        outfile.write( str( cam["location"][1] ) + "\n")
        outfile.write( str( cam["location"][2] ) + "\n")
        outfile.write( str( cam["to"][0] ) + "\n")
        outfile.write( str( cam["to"][1] ) + "\n")
        outfile.write( str( cam["to"][2] ) + "\n")
        outfile.write( str( cam["fov"] ) + "\n")
        outfile.write( str( cam["sensor_width"] ) + "\n")
        outfile.write( str( cam["sensor_height"] ) + "\n")
    print(f"Camera data has been exported to {output_file_path}")
else:
    print("No active camera found in the scene.")
