var x0 = room_width/2
var y0 = room_height/2


draw_arrow(x0,y0,x0+forward[0]*30, y0+forward[1]*30,5)
draw_arrow(x0,y0,x0+right[0]*30, y0+right[1]*30,5)


draw_line(0,100,p*getW(),100)


draw_circle(x,y,10,true)