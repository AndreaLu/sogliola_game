function v3Copy(v) { // creates a new vector copy of v
   var w = array_create(3)
   w[@0] = v[0]
   w[@1] = v[1]
   w[@2] = v[2]
   return w
}
function v3Eq(v,w) {
   return w[0] == v[0] && w[1] == v[1] && w[2] == v[2]
}
// puts the vector v into w
function v3SetIP(v,w) { // w <- v
   w[@0] = v[0]
   w[@1] = v[1]
   w[@2] = v[2]
}
// Puts into w a version of v scaled by a and returns it
function v3ScaleIP(a,v,w) {
	w[@0] = v[0]*a;
	w[@1] = v[1]*a;
	w[@2] = v[2]*a;
	return w;
}
// Returns a version of v scaled by a
function v3Scale(a,v) {
	return [a*v[0],a*v[1],a*v[2]]
}
// Puts v-w into z and returns it
function v3SubIP(v,w,z) {
	z[@0] = v[0]-w[0];
	z[@1] = v[1]-w[1];
	z[@2] = v[2]-w[2];
	return z;
}
// Returns v-w
function v3Sub(v,w) {
	return [v[0]-w[0],v[1]-w[1],v[2]-w[2]];
}
// Puts v+w into z and returns it
function v3SumIP(v,w,z) {
	z[@0] = v[0]+w[0];
	z[@1] = v[1]+w[1];
	z[@2] = v[2]+w[2];
	return z;
}
// Returns v+w
function v3Sum(v,w) {
	return [v[0]+w[0],v[1]+w[1],v[2]+w[2]];
}
function v3LerpIP(v,w,a,z) {
   gml_pragma("forceinline")
   a = 1-clamp(a,0,1)
   z[@0] = v[0]*a + w[0]*(1-a);
	z[@1] = v[1]*a + w[1]*(1-a);
	z[@2] = v[2]*a + w[2]*(1-a);
}
// Puts a*v + b*w into z and returns it
function v3LC2IP(v,w,a,b,z) {
	z[@0] = v[0]*a + w[0]*b;
	z[@1] = v[1]*a + w[1]*b;
	z[@2] = v[2]*a + w[2]*b;
	return z;
}
function v3LC3IP(v0,v1,v2,a,b,c,z) {
	z[@0] = v0[0]*a + v1[0]*b + v2[0]*c;
	z[@1] = v0[1]*a + v1[1]*b + v2[1]*c;
	z[@2] = v0[2]*a + v1[2]*b + v2[2]*c;
	return z;
}
function v3LC4IP(v0,v1,v2,v3,a,b,c,d,z) {
	z[@0] = v0[0]*a + v1[0]*b + v2[0]*c + v3[0]*d;
	z[@1] = v0[1]*a + v1[1]*b + v2[1]*c + v3[1]*d;
	z[@2] = v0[2]*a + v1[2]*b + v2[2]*c + v3[2]*d;
	return z;
}

function v3Set(v,_x,_y,_z) { // v <- x,y,z
	v[@0] = _x;
	v[@1] = _y;
	v[@2] = _z;
}

// Returns the length of vector v
function v3Length(v) {
	return sqrt(v[0]*v[0] + v[1]*v[1] + v[2]*v[2]);
}
// Returns the dot product of two vectors v and w
function v3Dot(v,w) {
	return v[0]*w[0] + v[1]*w[1] + v[2]*w[2];
}
// Puts v cross w into z and returns it
function v3CrossIP(v,w,z) {
	z[@0] = v[1]*w[2]-v[2]*w[1];
	z[@1] = v[2]*w[0]-v[0]*w[2];
	z[@2] = v[0]*w[1]-v[1]*w[0];
	return z;
}
// Returns v cross w
function v3Cross(v,w) {
	return [
		v[1]*w[2]-v[2]*w[1],
		v[2]*w[0]-v[0]*w[2],
		v[0]*w[1]-v[1]*w[0],
	];
}
// Puts into w the normalized version of vector v
function v3NormalizeIP(v,w) {
	var l = 1/sqrt(v[0]*v[0] + v[1]*v[1] + v[2]*v[2]);
	w[@0] = v[0]*l;
	w[@1] = v[1]*l;
	w[@2] = v[2]*l;
	return w;
}
function v3String(v) {
	return string_format(v[0],10,5) + "," + string_format(v[1],10,5) + "," + string_format(v[2],10,5)
}
// Returns a normalized version of v
function v3Normalize(v) {
	var l = 1/sqrt(v[0]*v[0] + v[1]*v[1] + v[2]*v[2]);
	return [v[0]*l,v[1]*l,v[2]*l];
}
// Returns a camera orinetation matrix
function matBuildLookat(from,to,up) {
	return matrix_build_lookat(from[0],from[1],from[2], to[0],to[1],to[2], up[0],up[1],up[2])
}
// Returns a matrix that rotates vectors around a given axis by a given angle
function matBuildRot(axis,angle) {
	static tmp = [0,0,0]
	gml_pragma("forceinline")
	var C = cos(angle), S = sin(angle), t = 1-C
	var md = 1/sqrt(axis[0]*axis[0] + 
	              axis[1]*axis[1] + 
				  axis[2]*axis[2])
	tmp[@0] = axis[0]*md
	tmp[@1] = axis[1]*md
	tmp[@2] = axis[2]*md
	var ux = tmp[0], uy = tmp[1], uz = tmp[2];
	var txx = t*ux*ux, txy = t*ux*uy, txz = t*ux*uz, tyz = t*uy*uz, tyy=t*uy*uy, tzz = t*uz*uz;
	return  ([    txx+C, txy-S*uz, txz+S*uy, 0,
	           txy+S*uz,    tyy+C, tyz-S*ux, 0,
	           txz-S*uy, tyz+S*ux,    tzz+C, 0,
	                  0,        0,        0, 1])
}
function matBuild(pos, rot, scale) {
	return matrix_build(pos[0],pos[1],pos[2], rot[0],rot[1],rot[2], scale[0],scale[1],scale[2])
}


function mat3IPInvert(argument0) {

	var mat = argument0
	var a00 = mat[0],
	    a01 = mat[1],
	    a02 = mat[2],
	    a10 = mat[3],
	    a11 = mat[4],
	    a12 = mat[5],
	    a20 = mat[6],
	    a21 = mat[7],
	    a22 = mat[8],
	    det = a00*a11*a22+a10*a21*a02+a20*a01*a12
	        -a00*a21*a12-a20*a11*a02-a10*a01*a22;
	if (det == 0) {
		return undefined;
	}
	else {
		mat[@8] = (a00*a11-a01*a10)/det;
		mat[@0] = (a11*a22-a12*a21)/det;
		mat[@1] = (a02*a21-a01*a22)/det;
		mat[@2] = (a01*a12-a02*a11)/det;
		mat[@3] = (a12*a20-a10*a22)/det;
		mat[@4] = (a00*a22-a02*a20)/det;
		mat[@5] = (a02*a10-a00*a12)/det;
		mat[@6] = (a10*a21-a11*a20)/det;
		mat[@7] = (a01*a20-a00*a21)/det;
	}
}



function matBuildCBM(forwardB, rightB, upB) {
	// Creates the matrix that transforms base A into base B
	var af = global.FORWARD, ar = global.RIGHT, au = global.UP
	var bf = forwardB, br = rightB, bu = upB
	var A0 = [af[0], ar[0], au[0],
	          af[1], ar[1], au[1],
		      af[2], ar[2], au[2]]
	mat3IPInvert(A0)
	var t0 = vec3Mat3( [bf[0], br[0], bu[0]], A0 ) // t00,t10,t20
	var t1 = vec3Mat3( [bf[1], br[1], bu[1]], A0 ) // t01,t11,t21
	var t2 = vec3Mat3( [bf[2], br[2], bu[2]], A0 ) // t02,t12,t22
	return [t0[0], t1[0], t2[0], 0,
		    t0[1], t1[1], t2[1], 0,
			t0[2], t1[2], t2[2], 0,
			    0,     0,     0, 1]
}


function vec3Mat3(v, m) {
	var result = array_create(3,0)
	var vector=v, matrix=m;
	result[@0] = vector[0]*matrix[0] + vector[1]*matrix[3] + vector[2]*matrix[6]
	result[@1] = vector[0]*matrix[1] + vector[1]*matrix[4] + vector[2]*matrix[7]
	result[@2] = vector[0]*matrix[2] + vector[1]*matrix[5] + vector[2]*matrix[8]
	return result
}


// Loads a 3DC mesh file (collision mesh) and returns the mesh. The mesh is just an array of real numbers
// which are the x,y,z components of each vertex of each triangle in the mesh
function mesh3DCLoad(fname) {
	var _x0,_y0,_z0,_x1,_y1,_z1,_x2,_y2,_z2,_x3,_y3,_z3,d;
	var buffer = buffer_load(fname);
	var numTriangles = buffer_read(buffer,buffer_u32);
	var triangles = array_create(numTriangles);
	
	for(var i=0; i<numTriangles; i++) {
		_x0 = buffer_read(buffer,buffer_f32); _y0 = buffer_read(buffer,buffer_f32); _z0 = buffer_read(buffer,buffer_f32);
		_x1 = buffer_read(buffer,buffer_f32); _y1 = buffer_read(buffer,buffer_f32); _z1 = buffer_read(buffer,buffer_f32);
		_x2 = buffer_read(buffer,buffer_f32); _y2 = buffer_read(buffer,buffer_f32); _z2 = buffer_read(buffer,buffer_f32);
		_x3 = buffer_read(buffer,buffer_f32); _y3 = buffer_read(buffer,buffer_f32); _z3 = buffer_read(buffer,buffer_f32);
		d = buffer_read(buffer,buffer_f32);
		triangles[@i] = [
		/* v0 */ [_x0,_y0,_z0],
		/* v1 */ [_x1,_y1,_z1],
		/* v2 */ [_x2,_y2,_z2],
		/* n  */ [_x3,_y3,_z3],
		/* d  */ d
		];
	}
	return triangles;
}
// Frees the memory used by a 3DC mesh
function mesh3DCDelete(mesh) {
	var numTriangles = array_length(mesh);
	for( var i=0; i<numTriangles; i++ ) {
		var triangle = mesh[i];
		array_delete(triangle[0],0,array_length(triangle[0]));
		array_delete(triangle[1],0,array_length(triangle[1]));
		array_delete(triangle[2],0,array_length(triangle[2]));
		array_delete(triangle[3],0,array_length(triangle[3]));
		array_delete(triangle,0,array_length(triangle));
	}
	array_delete( mesh,0,numTriangles );
}
// Loads a 3DG mesh (graphics mesh) and returns it.
function mesh3DGLoad(fname) {
	var _x,_y,_z
	vertex_format_begin();
	vertex_format_add_position_3d();
	vertex_format_add_color();
	vertex_format_add_texcoord();
	vertex_format_add_normal();
	var vertexBufferFormat = vertex_format_end();
	var buffer = buffer_load(fname)
	//var vertexBuffer = vertex_create_buffer_from_buffer(buffer,vertexBufferFormat)
	//vertex_format_delete(vertexBufferFormat)
	var vertexBuffer = vertex_create_buffer()
	vertex_begin(vertexBuffer,vertexBufferFormat)
	var numTriangles = buffer_read(buffer,buffer_u32);
	repeat(numTriangles*3) {
		// read position
		_x = buffer_read(buffer,buffer_f32);
		_y = buffer_read(buffer,buffer_f32);
		_z = buffer_read(buffer,buffer_f32);
		vertex_position_3d(vertexBuffer,_x,_y,_z);
		
		// read color
		buffer_read(buffer,buffer_f32);
		buffer_read(buffer,buffer_f32);
		buffer_read(buffer,buffer_f32);
		vertex_color(vertexBuffer,c_white,1);
		
		// read texcoord
		var u = buffer_read(buffer,buffer_f32);
		var v = 1-buffer_read(buffer,buffer_f32);
		vertex_texcoord(vertexBuffer,u,v);

		// read normal
		_x = buffer_read(buffer,buffer_f32);
		_y = buffer_read(buffer,buffer_f32);
		_z = buffer_read(buffer,buffer_f32);
		vertex_normal(vertexBuffer,_x,_y,_z);
	}
	vertex_end(vertexBuffer);
   vertex_freeze(vertexBuffer)
	return vertexBuffer;
}
// Frees the memory used by a 3DG mesh
function mesh3DGDelete(mesh) {
	vertex_delete_buffer(mesh)
}
// Casts the given ray from the given point and see if it collides with the given 3DC Mesh
// it returns a real number which is the distance to the intersection point or undefined
// if there is no intersection
rcNormal = [0,0,0]
function rayCast(P,r,mesh) {
	var Q = [0,0,0];
	var numTriangles = array_length(mesh)
	var negCnt = 0;
	var result = undefined;
	for(var i=0; i<numTriangles; i++) {
		// Does P land on the same plane as the triangle?
		var triangle = mesh[i];
		var t = (triangle[4] - v3Dot(triangle[3],P))/v3Dot(triangle[3],r);
		if( t < 0 ){
			negCnt+=1
			continue;
		}
		v3SumIP(P,v3Scale(t,r),Q);
		var s1 = sign(v3Dot(v3Cross( v3Sub(triangle[1],triangle[0]), v3Sub(Q,triangle[0]) ), triangle[3]))
		var s2 = sign(v3Dot(v3Cross( v3Sub(triangle[2],triangle[1]), v3Sub(Q,triangle[1]) ), triangle[3]))
		if( s1 != s2 ) continue;
		if( sign(v3Dot(v3Cross( v3Sub(triangle[0],triangle[2]), v3Sub(Q,triangle[2]) ), triangle[3])) == s1 ) {
			if( is_undefined(result) ) {
				result = t;
				v3Set(global.rcNormal,triangle[3][0],triangle[3][1],triangle[3][2])
			}
			else if(t < result) {
				result = min(result,t);
				v3Set(global.rcNormal,triangle[3][0],triangle[3][1],triangle[3][2])
			}
		}
	}
	return result;
}

// puts into z the slerp between v and w with coefficient t 
function v3SlerpIP(v,w,t,z) {
   static tmp = [0,0,0]
   var dot = v3Dot(v,w) // dot = sum(v0[i] * v1[i] for i in range(len(v0)))
   dot = clamp(dot,-1,1) // dot = min(max(dot, -1.0), 1.0) 
   // Calculate the angle between the vectors
   var theta = arccos(dot) * t //  theta = math.acos(dot) * t

   // Orthogonal vector to v0
   v3LC2IP(w,v,1,-dot,tmp) // relative_vec = [v1[i] - dot * v0[i] for i in range(len(v0))]
   v3NormalizeIP(tmp,tmp)
   //norm = math.sqrt(sum(x * x for x in relative_vec))
   //relative_vec = [x / norm for x in relative_vec]

   // Perform the slerp
   v3LC2IP(v,tmp,cos(theta),sin(theta),z)
   //result = [v0[i] * math.cos(theta) + relative_vec[i] * math.sin(theta) for i in range(len(v0))]
}

function mat2quat(m) {
    var trace = m[0] + m[5] + m[10]
    var s,qx,qy,qz,qw
    if trace > 0 {
        s = sqrt(trace + 1.0) * 2  # s = 4 * qw
        qw = 0.25 * s
        qx = (m[9] - m[6]) / s
        qy = (m[2] - m[8]) / s
        qz = (m[4] - m[1]) / s
    } else if (m[0] > m[5] and m[0] > m[10]) {
        s = sqrt(1.0 + m[0] - m[5] - m[10]) * 2 
        qw = (m[9] - m[6]) / s
        qx = 0.25 * s
        qy = (m[1] + m[4]) / s
        qz = (m[2] + m[8]) / s
    } else if (m[5] > m[10]) {
        s = sqrt(1.0 + m[5] - m[0] - m[10]) * 2
        qw = (m[2] - m[8]) / s
        qx = (m[1] + m[4]) / s
        qy = 0.25 * s
        qz = (m[6] + m[9]) / s
    } else {
        s = sqrt(1.0 + m[10] - m[0] - m[5]) * 2
        qw = (m[4] - m[1]) / s
        qx = (m[2] + m[8]) / s
        qy = (m[6] + m[9]) / s
        qz = 0.25 * s
    }
    return [qw, qx, qy, qz]
}

function quat2mat(q) {
    var qw = q[0]
    var qx = q[1]
    var qy = q[2]
    var qz = q[3]
    
    var m = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    m[@15] = 1
    
    m[@0] = 1 - 2 * (qy * qy + qz * qz)
    m[@1] = 2 * (qx * qy - qz * qw)
    m[@2] = 2 * (qx * qz + qy * qw)
    
    m[@4] = 2 * (qx * qy + qz * qw)
    m[@5] = 1 - 2 * (qx * qx + qz * qz)
    m[@6] = 2 * (qy * qz - qx * qw)
    
    m[@8] = 2 * (qx * qz - qy * qw)
    m[@9] = 2 * (qy * qz + qx * qw)
    m[@10] = 1 - 2 * (qx * qx + qy * qy)
    
    return m
}


function quatSlerp(q1, q2, t) {
    var dot = q1[0]*q2[0] + q1[1]*q2[1] + q1[2]*q2[2] + q1[3]*q2[3]

    if dot < 0 {
        q2 = [-q2[0], -q2[1], -q2[2], -q2[3]]
        dot = -dot
    }
    
    if( dot > 0.9995 ) {
        var result = [q1[0] + t*(q2[0] - q1[0]),
                  q1[1] + t*(q2[1] - q1[1]),
                  q1[2] + t*(q2[2] - q1[2]),
                  q1[3] + t*(q2[3] - q1[3])]
        var result_norm = sqrt(result[0]*result[0] + result[1]*result[1] + result[2]*result[2] + result[3]*result[3])
        return [result[0]/result_norm, result[1]/result_norm, result[2]/result_norm, result[3]/result_norm]
    }
    var theta_0 = arccos(dot)
    var sin_theta_0 = sqrt(1.0 - dot*dot)
    var theta = theta_0 * t
    var sin_theta = sin(theta)
    var sin_theta_1 = sin(theta_0 - theta)
    
    var s0 = sin_theta_1 / sin_theta_0
    var s1 = sin_theta / sin_theta_0
    
    return [s0*q1[0] + s1*q2[0], s0*q1[1] + s1*q2[1], s0*q1[2] + s1*q2[2], s0*q1[3] + s1*q2[3]]
}

function worldToScreenIP(xx,yy,zz,view_mat,proj_mat,v) {
	/// @param xx
	/// @param yy
	/// @param zz
	/// @param view_mat
	/// @param proj_mat
	/*
		Transforms a 3D world-space coordinate to a 2D window-space coordinate. Returns an array of the following format:
		[xx, yy]
		Returns [-1, -1] if the 3D point is not in view
	
		Script created by TheSnidr
		www.thesnidr.com
	*/

	if (proj_mat[15] == 0) {   //This is a perspective projection
		var w = view_mat[2] * xx + view_mat[6] * yy + view_mat[10] * zz + view_mat[14];
		// If you try to convert the camera's "from" position to screen space, you will
		// end up dividing by zero (please don't do that)
		//if (w <= 0) return [-1, -1];
		if (w == 0) return [-1, -1];
		var cx = proj_mat[8] + proj_mat[0] * (view_mat[0] * xx + view_mat[4] * yy + view_mat[8] * zz + view_mat[12]) / w;
		var cy = proj_mat[9] + proj_mat[5] * (view_mat[1] * xx + view_mat[5] * yy + view_mat[9] * zz + view_mat[13]) / w;
	} else {    //This is an ortho projection
		var cx = proj_mat[12] + proj_mat[0] * (view_mat[0] * xx + view_mat[4] * yy + view_mat[8]  * zz + view_mat[12]);
		var cy = proj_mat[13] + proj_mat[5] * (view_mat[1] * xx + view_mat[5] * yy + view_mat[9]  * zz + view_mat[13]);
	}

	v[@0] = (0.5 + 0.5 * cx) * getW()
	v[@1] = (0.5 - 0.5 * cy) * getH()
}