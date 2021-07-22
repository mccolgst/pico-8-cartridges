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
  message=-1
  msgs={
    {x=3,y=3,msg={"you can do it!"}},
    {x=11,y=3,msg={"do what now?"}},
    {x=6,y=4,msg={"how in the hell", "did i get here?"}}
  }
  windows={}
  dialogue={}
  npcs={}
  mobs={}

  add_npc(6,4,{50,49})
  add_mob(10,8)
end

function _update60()
  t+=1
  mode()
end

function _draw()
  cls()
  map(0,0,0,0,15,15)
  spr(get_frame(p.s),p.x*8,p.y*8)
  for npc in all(npcs) do
    spr(get_frame(npc.s),npc.x*8,npc.y*8)
  end
  for mob in all(mobs) do
    spr(get_frame(mob.s),mob.x*8,mob.y*8)
  end
  for window in all(windows) do
    draw_window(window)
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

function get_frame(animation)
  return animation[flr(t/15)%#animation+1]
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
    -- it's a tablet, do a message
    txt=find_msg(objx,objy)
    message=add_window(
      40,
      40,
      #txt[1]*4+4,
      10,
      txt,
      60
    )
    --mode=make_window
  elseif sp==49 or sp==50 then
    -- it's an npc, make a window
    txt=find_msg(objx,objy)
    dialogue=add_window(
      objx*8+8,
      objy*8-(#txt*6+6),
      #txt[1]*4+4,
      #txt*6+6,
      txt
    )
    mode=wait_for_input
  end
  if sp == 33 then return end
  mset(objx,objy,dest-1)
end

function add_window(x,y,w,h,msg,ttl)
  local window={
    x=x,
    y=y,
    w=w,
    h=h,
    msg=msg,
    ttl=ttl,
    t=0
  }
  add(windows,window)
  return window
end

function add_mob(x,y)
  local mob={
    x=x,
    y=y,
    s={64,65,66,67}
  }
  add(mobs,mob)
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

function add_npc(x,y,s)
  local npc={
    x=x,
    y=y,
    s=s,
    si=1,
  }
  add(npcs,npc)
  return npc
end

function rectfill2(x,y,w,h,c)
  rectfill(x,y,x+w,y+h,c)
end

function draw_window(window)
  local x,y,w,h,msg,ttl=window.x,window.y,window.w,window.h,window.msg,window.ttl
  if min(window.t,1)<1 then
    -- fancy open textbox animation
    x=max(((window.x+window.w)/2)-(window.t*10),window.x)
    w=min((window.x)+(window.t*10),window.w)
    window.t+=0.3
  end
  clip(x-6,y-6,w+6,h+6)
  rectfill2(x-5,y-5,w+5,h+5,7)
  rectfill2(x-4,y-4,w+2,h+2,0)
  for m in all(msg) do
    for i=-1,1 do
      for k=-1,1 do
        print(m,x+i,y+k,7)
      end
    end
    print(m,x,y,0)
    y+=8

  end
  if ttl then
    window.ttl-=1
    if ttl<=3 then
      window.w=w/2
      window.x+=w/4
      if flr(w)<=0 then
	message=-1
	del(windows,window)
      end
    end
  end
  clip()
end

function wait_for_input()
  pressbuff=get_press()
  if pressbuff==4 then
    dialogue.ttl=0
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000066660000a9990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000060000600a00009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000065555600a76669000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000060000600a00009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000060555600907669000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000066666600999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000006600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000060060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006666000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000060000600060606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000600000060000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000600000060600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000066666000066660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006006000060060000600600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00600600060000600600006006000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06000060066006600660066006600660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06600660060000600606606006000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06066060000660000006600000066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00066000000660000000000000066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000100000300000000000000000000000000000303000000000000000000000000000003030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
