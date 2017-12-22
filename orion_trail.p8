pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
plx_layers = {}
stars = {}
stars_colors = {7,6}

function _init()
  car = {}
  car.x=70
  car.y=80
  car.sprs = {}
  car.sprs.top = {1,2,3,4}
  car.sprs.bot = {17,18,19,20}
  car.bump_timer=0  
  car.ant_sprs = {5,6,7,8,8,7,6,5}
  car.ant_frame = 1
  car.t=0
  car.ant_step=8
  car.dust = {}
  car.dust.colors = {13,6,7}
  car.dust.particles = {}
  t=0
  create_plx_layer(0,70,16,1,-.25,64,2)  
  create_plx_layer(0,72,16,1,-.5,80,13)

  for i=0,flr(rnd(15)) do
    local star = {}
    star.x=rnd(128)
    star.y=rnd(75)
    star.r=flr(rnd(1))+1
    star.c=stars_colors[flr(rnd(#stars_colors))+1]
    add(stars,star)
  end
end

function _update()
  t+=0.01
  car.t=(car.t+1)%car.ant_step
  if (car.t==0) then
      car.ant_frame=(car.ant_frame+1)%#car.ant_sprs
  end
  if flr(t)%1==0 then
    create_dust_particles()
  end
  foreach(car.dust.particles, update_dust_particle)
  foreach(plx_layers,update_plx)
end

function _draw()
  cls()
  
  rectfill(0,77,128,128,1)
    
  for star in all(stars) do
   pset(star.x, star.y, star.c)
  end
  
  circfill(35,35,10,6)
  circfill(37,35,10,7)

  
  foreach(plx_layers,draw_plx)

  rect(0,0,127,127,7)

  pal(13,5)
  draw_car()
  pal()
end

function draw_car()
  for i=1,#car.sprs.top do
    spr(car.sprs.top[i],
        car.x+(8*i),
        car.y-(sin(t%100)))
  end
  for i=1,#car.sprs.bot do
    spr(car.sprs.bot[i],
        car.x+(8*i),
        car.y+8-(sin(t%100)))
  end
  for i=1,6 do
    circfill(car.x+10+4*i,
             car.y+11-(sin(t%100))+sin(.5-i/5+t*10)/2,1,7)

  end 
  -- draw antenna
  spr(car.ant_sprs[car.ant_frame+1],
      car.x+28,
      car.y-4-(sin(t%100)))

  -- draw trailing dust
  foreach(car.dust.particles,
          draw_dust_particle)
  
end

function create_plx_layer(x,y,w,h,spd,sp,c)
  local layer = {}
  layer.x=x
  layer.y=y
  layer.w=w
  layer.h=h
  layer.spd=spd
  layer.sp=sp
  layer.c=c
  add(plx_layers,layer)
end

function update_plx(plx_layer)
  plx_layer.x-=plx_layer.spd
  if plx_layer.x>=plx_layer.w*8 then
    plx_layer.x=-plx_layer.w*8
  end
end

function draw_plx(plx_layer)
  pal(13,plx_layer.c)
  spr(plx_layer.sp,
      plx_layer.x,
      plx_layer.y,
      plx_layer.w,
      plx_layer.h)
  spr(plx_layer.sp,
      plx_layer.x-8*plx_layer.w,
      plx_layer.y,
      plx_layer.w,
      plx_layer.h)
  spr(plx_layer.sp,
      plx_layer.x+8*plx_layer.w,
      plx_layer.y,
      plx_layer.w,
      plx_layer.h)
  pal()
end

function create_dust_particles()
  for i=1,rnd(flr(5)) do
    local part = {}
    part.x=car.x+rnd(10)+15
    part.y=car.y+15
    part.c=car.dust.colors[flr(rnd(#car.dust.colors))+1]
    part.r=rnd(2)
    part.dx=rnd(4)
    part.dy=-(rnd(2))
    part.t=0
    add(car.dust.particles, part)
  end
end

function update_dust_particle(part)
  part.x+=part.dx
  part.y+=part.dy
  part.t+=1
  if part.dx > 0 then
    part.dx+=.1
  end
  if part.dy < 0 then
    part.dy+=.1
  end
  if part.t%30==0 then
    part.r-=1
  end
  if part.r<0 then
    del(car.dust.particles, part)
  end
end

function draw_dust_particle(part)
  circfill(part.x,part.y,
           part.r,part.c)
end


__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000070000007770000077770000777770000000000000000000000000000000000000000000000000000000000
00077000000000066666666666666666600000000076000007667000076667007666667000000000000000000000000000000000000000000000000000000000
000770000000006ddddddd6dddddddddd60000000007600000765700076656707665667000000000000000000000000000000000000000000000000000000000
00700700000006dd77777d6d777dd777dd6000000007760000076670007666707666667000000000000000000000000000000000000000000000000000000000
0000000000006ddd77777d6d777dd777ddd600000000077000007770000777700777770000000000000000000000000000000000000000000000000000000000
000000000006dddddddddd6ddddddddddddd60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000666666666666666666666666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000555555555555555555555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000005dddddddddddddddddddddd500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000005dddddddddddddddddddd5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000555555555555555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000dddd0000000000000000000000000000000000000000000000000000000000000000000000000000dddd000000000000000000000000000000000000000
0000dddddddd0000000000000dd000000000000000000000000dd0000000000000000000000000000000ddddddd0000000000000000dd0000000000000000000
0dddddddddddd000000000dddddd0dd0000000dd000000dd00dddddd000000dd000000dd000000dd0ddddddddddd0dd0000000dd00dddddd000000dd000000d0
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000d0000dd00000000000000000000dd0000000000000000d000000000000000000000000000000000dd00000000000000000000000000
00dd0000000000000000dd0000ddd0000d00000000dd0000dd000d000000000000dd000000000000000d000000d000d00000dd00000000000000dd0d00000000
0ddd0000000dd000000ddd0000dddd000d00000000dd0000dd00dd000000dd0000ddd0dd00000d0000ddd0000dd000d00d00dd000000d000000ddd0d000d0000
0ddd000000dddd000000000000d00000000dd000000d0000000dd0000000d00000d0d00000000d000dd0dd000dd000000d00dd00000ddd00000ddd0d00dd0000
