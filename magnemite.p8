pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
function _init()
  t=0
  cam = {x=0,dx=0,y=0,dy=0}
  circs = {}
  parts = {}
  thundershock_colors={0,9,7,10}
  mystery=true
  player = {
   dx=0,
   dy=0,
   x=64,
   y=64,
   t=0,
   step=10,
   flipx=false,
   moving=false,
   sprites={
     head={
           frame=0,
           sprites={7,8,9,10},
          },
     arm={pos={
           l={
            x=64-8,
            y=64,
            dx=0,
            dy=0
           },
           r={
            x=64+8,
            y=64,
            dx=0,
            dy=0,
           },
         },
          sprites={36,38}},
     hat=21
   }
  }
end

function _update()
  camera()
  t+=1
  update_player()
  update_fx()
  if flr(rnd(2))==0 then
    cam.dx*=-1
  end
  if flr(rnd(2))==0 then
    cam.dy*=-1
  end
  if cam.dx>0 then
    cam.dx-=1
  end
  if cam.dy>0 then
    cam.dy-=1
  end
  cam.x+=cam.dx
  cam.y+=cam.dy
  
  camera(cam.dx,cam.dy)
end

function _draw()
  draw_player()
  draw_fx()
end

function update_player()
  player.t+=1
  -- controls
  if btn(0) or btn(1) or
     btn(2) or btn(3) then
    player.moving=true
  else
    player.moving=false   
  end

  if btn(0) then 
    player.dx-=1
  elseif btn(1) then
    player.dx+=1
  end
  
  if btn(2) then
    player.dy-=1
  elseif btn(3) then
    player.dy+=1
  end
  
  if btn(4) then
    thundershock()
    mystery=false
  end

  -- animation
  player.t=(player.t+1)%player.step
  if (player.t==0) then
    player.sprites.head.frame=(player.sprites.head.frame+1)%#player.sprites.head.sprites
  end
  
  if player.dx>0 then
    player.flipx=true
  else
    player.flipx=false
  end
  
  -- for each arm, change dxdy if neede
  local larm = player.sprites.arm.pos.l
  if abs(player.x-8-larm.x)<8 then
    larm.x=player.x-8
  end
  if abs(player.y-larm.y)<16 then
    larm.y=player.y
  end

  if larm.x<player.x-8 then
    larm.dx+=1
  elseif larm.x>player.x-8 then
    larm.dx-=1
  end
  if larm.y<player.y then
    larm.dy+=1
  elseif larm.y>player.y then
    larm.dy-=1
  end
  
  local rarm = player.sprites.arm.pos.r
  if abs(player.x+8-rarm.x)<8 then
    rarm.x=player.x+8
  end
  if abs(player.y-rarm.y)<8 then
    rarm.y=player.y
  end

  if rarm.x<player.x+8 then
    rarm.dx+=1
  elseif rarm.x>player.x+8 then
    rarm.dx-=1
  end
  if rarm.y<player.y then
    rarm.dy+=1
  elseif rarm.y>player.y then
    rarm.dy-=1
  end

  if abs(player.x+8-rarm.x)<4 then
    rarm.x=player.x+8
  end
  if abs(player.y-rarm.y)<4 then
    rarm.y=player.y
  end


  player.sprites.arm.pos.l.x+=larm.dx
  player.sprites.arm.pos.l.y+=larm.dy

  player.sprites.arm.pos.r.x+=rarm.dx
  player.sprites.arm.pos.r.y+=rarm.dy
  
  player.sprites.arm.pos.l.dx*=0.85
  player.sprites.arm.pos.l.dy*=0.85
  
  player.sprites.arm.pos.r.dx*=0.85
  player.sprites.arm.pos.r.dy*=0.85

  player.x+=player.dx
  player.y+=player.dy

  player.dx*=0.85
  player.dy*=0.85
end

function draw_player()
  cls()
  pal()
  rectfill(-128,-128,256,256,1)
  if mystery then
    for i=0,15 do
      pal(i,12)
    end
  else
    pal()
  end
  
  -- draw head
  local head_frame=1
  if player.moving then
    head_frame=2
  end
  
  --spr(player.sprites.head.sprites[head_frame],
  --    player.x,player.y,
  --    1,1,
  --    player.flipx)
  
  ymod = cos(t/60)*2
  ymod2 = cos((t+15)/45)*2
  
  printh(t/100)
  -- draw arms
  --[[
  spr(player.sprites.arm.sprites[1],
      --player.x-9,
      --player.y)
      player.sprites.arm.pos.l.x,
      player.sprites.arm.pos.l.y+ymod)
     
  spr(player.sprites.arm.sprites[2],
      player.sprites.arm.pos.r.x,
      player.sprites.arm.pos.r.y+ymod2)
     
  -- draw screw head
  spr(player.sprites.hat,
      player.x,
      player.y-8)
  --]]
  --
  sspr(8*6+(8*head_frame),0,8,8,
       player.x,
       player.y,
       16,16,
       player.flipx)
  
  -- draw arms
  sspr(8*4,8*2,
       8,8,
       --player.sprites.arm[1],
      player.sprites.arm.pos.l.x-10,
      player.sprites.arm.pos.l.y+ymod,
     
       16,16)
  sspr(8*6,8*2,
       8,8,
       --player.sprites.arm[1],
       player.sprites.arm.pos.r.x+10,
       player.sprites.arm.pos.r.y+ymod2,
       16,16)
  -- draw screw hat
  sspr(8*5,8,
  				 8,8,
       player.x,
       player.y-16,
       16,16)
  --]]
end


function thundershock()
  cam.dx=flr(rnd(10))
  cam.dy=flr(rnd(10))
  for i=1,flr(rnd(3))+1 do
    local newcirc = {}
    local newx=rnd(5)
    local newy=rnd(5)
    newcirc.ttl=30
    newcirc.x=player.x
    newcirc.y=player.y
    newcirc.dr=rnd(15)
    if flr(rnd(2))==0 then
      newx*=-1
    end
    if flr(rnd(2))==0 then
      newy*=-1
    end
    newcirc.x+=newx
    newcirc.y+=newy 
    newcirc.r=rnd(20)
    add(circs,newcirc)
  end
  for i=1,60 do
    local newpart = {}
    newpart.ttl=60
    newpart.x=player.x+rnd(16)
    newpart.y=player.y+rnd(16)
    newpart.dx=rnd(10)
    newpart.dy=rnd(10)
    if flr(rnd(2))==0 then
      newpart.dx*=-1
    end
    if flr(rnd(2))==0 then
      newpart.dy*=-1
    end
    add(parts,newpart)
  end
end

function update_fx()
  for c in all(circs) do
    c.r+=c.dr
    c.ttl-=1
    if c.ttl<0 then
      del(circs,c)
    end
  end
  for p in all(parts) do
    p.x+=p.dx
    p.y+=p.dy
    p.ttl-=1
    if p.ttl<0 then
      del(parts,p)
    end
  end
end

function draw_fx()
  for c in all(circs) do
    local clr = thundershock_colors[flr(rnd(#thundershock_colors))+1]
    circ(c.x,c.y,c.r,clr)
  end
  for p in all(parts) do
    local clr = thundershock_colors[flr(rnd(#thundershock_colors))+1]
    pset(p.x,p.y,clr)
  end
end
__gfx__
00000000006666000000000000000000000000000000000000000000007766000077660000666600006666000000000000000000000000000000000000000000
0000000006555660000000000000000000000000000000000000000007ddd6600766666006666660066666600000000000000000000000000000000000000000
007007006577756600000000000000000000000000000000000000007d777d6677ddd66666666666666666660000000000000000000000000000000000000000
000770006570756600000000000000000000000000000000000000007d757d667d757d6666666666667076660000000000000000000000000000000000000000
000770006577756600000000000000000000000000000000000000007d777d666d777d6666666666667776660000000000000000000000000000000000000000
00700700665556660000000000000000000000000000000000000000666666666666666666666666666666660000000000000000000000000000000000000000
00000000066666600000000000000000000000000000000000000000065665600656656006566560065665600000000000000000000000000000000000000000
00000000006666000000000000000000000000000000000000000000006666000066660000666600006666000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000066650000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000006500000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000005500000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000077660000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000ee666000755566000666cc0000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000022666607577756606666110000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000667575756566000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000667577756566000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000cc666606666666506666ee0000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000011555000656655000555220000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000066550000000000000000000000000000000000000000000000000000000000000000000000000000000000
