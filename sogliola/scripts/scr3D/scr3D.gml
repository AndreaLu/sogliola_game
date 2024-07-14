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

function v3Set(v,_x,_y,_z) {
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
		v[0]*w[2]-v[2]*w[0],
		v[0]*w[1]-v[1]*w[0],
	];
}
// Normalizes vector v and returns it
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