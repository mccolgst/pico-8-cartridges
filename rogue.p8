pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
function _init()
  pressbuff=-1
  t=0
  p={
    x=1,
    y=1,
    dx=0,  -- delta x
    dy=0,  -- delta y
    s={1,2},  -- list of sprites
    si=1,  -- sprite index
    dest={}
  }
  movement={
    {-1,0},
    {1,0},
    {0,-1},
    {0,1}
  }
  mode=check_inputs
end

function _update60()
  t+=0.03
  p.si=t%#p.s+1
  mode()
end

function _draw()
  cls()
  map(0,0,0,0,15,15)
  spr(p.si,p.x*8,p.y*8)
end

function get_press()
  for i=0,#movement-1 do
    if btnp(i) then
      return i
    end
  end
  return -1
end

function check_inputs()
  if pressbuff==-1 then
    pressbuff=get_press()
  else
    move_player(p,movement[pressbuff+1])
    pressbuff=-1
  end
end

function move_player(player,dxdy)
  dest=mget(player.x+dxdy[1],player.y+dxdy[2])
  if fget(dest,0) then
    if fget(dest,1) then
      mset(
	player.x+dxdy[1],
	player.y+dxdy[2],
	dest-1
      )
    end
  else
    player.dest={player.x+dxdy[1],player.y+dxdy[2]}
    player.dx=dxdy[1]
    player.dy=dxdy[2]
    mode=animate_player
  end
end

function animate_player()
  if pressbuff==-1 then
    pressbuff=get_press()
  end
  funx = min
  funy = min
  if p.dx<1 then
    funx = max
  end
  if p.dy<1 then
    funy = max
  end
  p.x = funx(p.x+p.dx/8,p.dest[1])
  p.y = funy(p.y+p.dy/8,p.dest[2])

  if p.x==p.dest[1] and p.y==p.dest[2] then
    mode=check_inputs
  end
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066666660
00000000066666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000060000060
00000000600000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000060000060
00000000606060600666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000060000060
00000000600000606000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000060000060
00000000606660606000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000060000060
00000000600000606066606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066666660
00000000066666006666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000900000909999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009009009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009009009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000900a009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009009009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009009009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000900000909999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000100000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0f0f0f0f0f0000000f0f0f0f0f0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0000000f0000000f000000000f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0000000f0f0f0f0f000000000f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0000000f00000012000000000f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f120f0f0f0000000f000000000f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f000000120000000f000000000f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0f0f0f0f0f0f0f0f0f120f0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000f000000000f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000f000000000f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000f000000000f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000f0f0f0f0f0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
