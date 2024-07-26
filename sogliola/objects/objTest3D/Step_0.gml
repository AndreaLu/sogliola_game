theta = current_time/1000
forward = [-cos(theta),sin(theta),0]
up = [0,0,1]
right = v3Cross(forward,up)


up2 = [1,0,0]
forward2 = [0,-cos(theta),sin(theta)]
right2 = v3Cross(forward2,up2)

mat = matrix_multiply(
   matBuildCBM(
      global.FORWARD,global.RIGHT,global.UP,
      forward,right,up
   ),
   matBuild(
      [-3,0,sin(theta)],
      [0,0,0],[1,1,1]
   )
)
quat = mat2quat(
   matBuildCBM(
      global.FORWARD,global.RIGHT,global.UP,
      forward,right,up
   )
)
p = window_mouse_get_x() / window_get_width()

mat2 = matrix_multiply(

   matBuildCBM(
      global.FORWARD,global.RIGHT,global.UP,
      forward2,right2,up2
   ),
   matBuild(
      [3,0,sin(theta)],
      [0,0,0],[1,1,1]
   )
)
quat2 = mat2quat(
   matBuildCBM(
      global.FORWARD,global.RIGHT,global.UP,
      forward2,right2,up2
   )
)

mat3 = matrix_multiply(
   quat2mat(quatSlerp(quat,quat2,p)),
      matBuild(
      [-3+6*p,0,sin(theta)],
      [0,0,0],[1,1,1]
   )
)

