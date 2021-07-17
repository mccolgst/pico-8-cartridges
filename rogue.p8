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

  flags={
    wall=0,
    interactable=1
  }

  textbox=-1

  msgs={
    {x=3,y=3,msg="you suck"},
    {x=11,y=3,msg="just kidding"}
  }
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
  --print(pressbuff,100,100,1)
  if textbox!=-1 then
    -- if there's a textbox to display, display it
    local x,y,msg=textbox.x,textbox.y,textbox.msg
    rectfill(x-6,y-6,x+#msg*4+6,y+10+6,7)
    rectfill(x-5,y-5,x+#msg*4+5,y+10+5,0)
    for i=-1,1 do
      for k=-1,1 do
	print(msg,x+i,y+k,7)
      end
    end
      print(msg,x,y,0)
  end
end

function get_press()
  for i=0,5 do
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
    if pressbuff<4 then
      move_player(p,movement[pressbuff+1])
    end  
    pressbuff=-1
  end
end

function move_player(player,dxdy)
  local x,y=player.x+dxdy[1],player.y+dxdy[2]
  dest=mget(x,y)
  if fget(dest,flags.wall) then
    -- it's a wall, but is it interactable?
    if fget(dest,flags.interactable) then
      interact_obj(x,y)
    end
  else
    player.dest={x,y}
    player.dx,player.dy=dxdy[1],dxdy[2]
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

function interact_obj(objx,objy)
  local sp = mget(objx,objy)
  if sp == 34 or sp == 33 then
    -- it's a tablet
    textbox={
      x=40,
      y=40,
      msg=find_msg(objx,objy),
    }
    mode=make_textbox
  end
  if sp == 33 then return end
  mset(objx,objy,dest-1)
end

function make_textbox()
  -- halt game until player presses 4
  pressbuff=get_press()
  if pressbuff==4 then
    textbox=-1
    mode=check_inputs
    return
  end
end

function find_msg(x,y)
  -- find the right message for the coordinates
  for msg in all(msgs) do
    if msg.x==x and msg.y==y then
      return msg.msg
    end
  end
  return -1
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000066660000a9990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000060000600a00009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000065555600a76669000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000060000600a00009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000060555600907669000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000066666600999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000100000300000000000000000000000000000303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0f0f0f0f0f0000000f0f0f0f0f0f0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0303030f0000000f03030303030f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0303030f0f0f0f0f03030303030f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0303220f0303031203032203030f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f120f0f0f0303030f03030303030f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f030303120303030f03030303030f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0f0f0f0f0f0f0f0f0f120f0f0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000f030303030f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000f030303030f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000f030303030f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000f0f0f0f0f0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
