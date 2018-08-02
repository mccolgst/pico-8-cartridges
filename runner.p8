pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
function _init()
 poke(0x5f2c,3) // set resolution to 64x64
 x=30
 show_hitbox=-1
 saber_colors={12,7,6}
 saber_cache_colors={13,2,1}
 saber_cache={}
 p={
    t=0,
    x=30,
    y=30,
    frame=0,
    state="idle",
    flip="f",
    kickdelay=0,
    deflectdelay=0,
    health=3,
    hbox={
      running={
        f={xmod=3,ymod=2,w=2,h=6},
        t={xmod=3,ymod=2,w=2,h=6}
      },
      idle={
        f={xmod=3,ymod=2,w=2,h=6},
        t={xmod=3,ymod=2,w=2,h=6}
      },
      kicking={
        f={xmod=5,ymod=2,w=4,h=3},
        t={xmod=3,ymod=2,w=-4,h=3}
      },
      fighting={
        f={xmod=0,ymod=1,w=7,h=7},
        t={xmod=0,ymod=1,w=7,h=7}        
      },
      deflecting={
        f={xmod=0,ymod=1,w=7,h=7},
        t={xmod=0,ymod=1,w=7,h=7}        
      },
    },
    sprites={
      running={
        step=2,
        sprites={49,50,51,52,53,54,55,56,57}
      },
      idle={
        step=5,
        sprites={23,24,25,26},
      },
      fighting={
        step=5,
        sprites={2,3,4,5,6,7},
      },
      kicking={
        step=1,
        sprites={19},
      },
      deflecting={
        step=1,
        sprites={39,40,41},
      }
    }
   }
 t=0
 enemies={}
 enemy_sprs={
   knife=27
 }
 fx={}
end

function _update()
  rectfill(0,0,64,64,1)
  if btn(0) then
    p.x-=.5
    p.state="running"
    p.flip="t"
  elseif btn(1) then
    p.x+=.5
    p.state="running"
    p.flip="f"
  elseif btnp(3) then
    show_hitbox*=-1
  elseif p.state=="running" then
    p.state="idle"
    p.frame=0
  elseif btnp(4) and p.state != "fighting" then
    p.state="fighting"
    p.frame=0
  elseif btnp(4) and p.state == "fighting" then
    p.state="idle"
    p.frame=0
  elseif not btnp(5) and p.kickdelay<=0 and p.state=="kicking" then
    p.state="idle"
    p.frame=0
  elseif not btnp(5) and p.state=="kicking" and p.kickdelay>0 then
    p.kickdelay-=1
  elseif btnp(5) then
    p.state="kicking"
    p.kickdelay=4
  end
  if p.state=="deflecting" or p.state=="fighting" and (p.deflectdelay>0) then
    --p.deflectdelay-then=1
    p.state="deflecting"
    p.deflectdelay-=1
  end
  if p.state=="deflecting" and p.deflectdelay<=0 then
    p.state="idle"
    p.frame=0
  end
 
  t+=1
  animate(p)
  update_enemies()
  update_player()
  update_fx()
end

function _draw()
  for item in all(saber_cache) do
    pset(item[1],item[2],saber_cache_colors[1+flr(rnd(#saber_cache_colors))])
    item[3]-=1
    if item[3]<=0 then
      del(saber_cache,item)
    end
  end
  --saber_cache = {}
  spr(p.sprites[p.state].sprites[p.frame+1],
      p.x,p.y,1,1,(p.flip=="t"),false)
  -- sparkly lightsaber fx
  for i=p.x,p.x+7 do
    for j=p.y,p.y+7 do
      if pget(i,j) == 12 or pget(i,j) == 7 or pget(i,j) == 6 then
        pset(i,j,saber_colors[1+flr(rnd(3))])
      end
    end
  end
  -- saber cache fx
  for i=p.x,p.x+7 do
    for j=p.y,p.y+7 do
      if pget(i,j) == 12 or pget(i,j) == 7 or pget(i,j) == 6 then
        add(saber_cache,{i,j,7})
      end
    end
  end

  for enemy in all(enemies) do
    spr(enemy_sprs[enemy.type],
        enemy.x, enemy.y, 1,1,(enemy.dx>1),false)
    -- draw enemy hitbox in red
    if show_hitbox then
      rect(enemy.x+enemy.hbox.xmod,enemy.y+enemy.hbox.ymod,
          enemy.x+enemy.hbox.xmod+enemy.hbox.w,
          enemy.y+enemy.hbox.ymod+enemy.hbox.h,8)
    end
  end
  -- draw player hitbox in red
  if show_hitbox<1 then
    rect(p.x+p.hbox[p.state][p.flip].xmod,p.y+p.hbox[p.state][p.flip].ymod,
        p.x+p.hbox[p.state][p.flip].xmod+p.hbox[p.state][p.flip].w,
        p.y+p.hbox[p.state][p.flip].ymod+p.hbox[p.state][p.flip].h,8)
  end
  -- draw fx
  for f in all(fx) do
    pset(f.x,f.y,f.c)
  end
  -- debug
  --[[
  print(p.frame+1,0,0,7)
  print(p.state,0,10,7)
  print(t,0,20,7)
  print(p.deflectdelay,0,24,7)
  --]]
end

function animate(obj)
  -- animation
  obj.t=(obj.t+1)%obj.sprites[obj.state].step
  if (obj.t==0) then
    obj.frame=(obj.frame+1)%#obj.sprites[obj.state].sprites
  end
end

function update_enemies()
  -- check if new enemies should be created
  if t%100 == 0 then
    add(enemies,{x=100,y=32,dx=-1,
                 dy=0,type="knife",t=0,
                 hbox={xmod=3,ymod=2,w=2,h=0}})
  end

  for enemy in all(enemies) do
    enemy.x+=enemy.dx
    enemy.y+=enemy.dy
    enemy.t+=1
    --if collides_with_player(enemy) then
    if check_collision(
      {x=p.x+p.hbox[p.state][p.flip].xmod,
       y=p.y+p.hbox[p.state][p.flip].ymod,
       w=p.hbox[p.state][p.flip].w,
       h=p.hbox[p.state][p.flip].h},
      {x=enemy.x+enemy.hbox.xmod,
       y=enemy.y+enemy.hbox.ymod,
       w=enemy.hbox.w,
       h=enemy.hbox.h}
    ) then
      if enemy.type == "knife" then
        if p.state=="fighting" then
          -- enemy knife dies!
          p.frame=4
          p.deflectdelay=7
          enemy_die(enemy)
        else
          p.health-=1
        end
      end
    end
    if enemy.t>1000 then
      del(enemies,enemy)
    end
  end
end

function update_player()
end

function enemy_die(enemy)
  if enemy.type=="knife" then
    -- do some cool fx where the knife explodes into the 3 px
    -- moving random directions
    for i=4,7+rnd(4) do
      add(fx,
        {
          x=enemy.x,y=enemy.y,
          dx=rnd(3),
          dy=rnd(3)*-1,
          c=8+flr(rnd(3)),
          update=gravity_update,
          ttl=100
        })
    end
    add(enemies,{x=enemy.x,y=32,dx=rnd(5),
                 dy=0,type="knife",t=0,
                 hbox={xmod=3,ymod=2,w=2,h=0}})
    del(enemies,enemy)
  end
end

function collides_with_player(enemy)
  return false
end

function update_fx()
  for f in all(fx) do
    f.update(f)
    f.ttl-=1
    if f.ttl<=0 then
      del(fx,f)
    end
  end
end

function gravity_update(f)
  f.dx*=0.9
  f.dy+=0.2
  f.dy*=1.01
  f.x+=f.dx
  f.y+=f.dy
end

function check_collision(thing1, thing2)
  if thing1.x <= thing2.x+thing2.w and
     thing1.x+thing1.w >= thing2.x and
     thing1.y+thing1.h >= thing2.y and
     thing1.y <= thing2.y+thing2.h and
     thing1.y+thing1.h >= thing2.y then     
    return true
  end
  return false
end

function indexof(array, item)
  for i=1,#array do
    if item == array[i] then
      return i
    end
  end
  return false
end

__gfx__
0000000000000000000000c00000007000000070000000c0000000c0000000c00000000000000000000000000000000000000000000000000000000000000000
00000000000dd000000dd0c0000000c0000000c0000000c0000000c0000dd0c00000000000000000000000000000000000000000000000000000000000000000
00700700000df0000f0df0c00f0dd0c0000dd0c0000dd0c0000dd0c00f0df0c00000000000000000000000000000000000000000000000000000000000000000
000770000044440000aaaaf000adfac0000df0c0000df0f000adfaf000aaaaf00000000000000000000000000000000000000000000000000000000000000000
0007700000f88f00000aa000000aa0f00faaaaf00faaaa000f0aa000000aa0000000000000000000000000000000000000000000000000000000000000000000
0070070000f99f000009400000094000000aa000000aa000000aa000000940000000000000000000000000000000000000000000000000000000000000000000
00000000000aa0000009040000090400000904000009040000090400000904000000000000000000000000000000000000000000000000000000000000000000
00000000000660000090004000900040009000400090004000900040009000400000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000dd00000000000000000000000000000000000000dd000000dd0000000000000000000000dd0000000000000000000000000000000000000000000
00000000000df0000000000000dd00440000000000000000000df000000df000000dd000000df000000df0000006650000000000000000000000000000000000
00000000004444000000000000dfa4000000000000000000000aa00000aaa000000df000000aa000000aa0000000000000000000000000000000000000000000
0000000000f88f000000000000aaa000f00000000000000000faa0000f0aa000000aa000000aa000000aa0000000000000000000000000000000000000000000
000000000f0990f00000000000f090000000000000000000000c400000caa000000aa00000fcccc000fcccc00000000000000000000000000000000000000000
00000000000aaa60000000000000900000000000000000000009c000000c400000fcccc000094000000940000000000000000000000000000000000000000000
00000000006000000000000000009000000000000000000000094c000009c0000009400000094000000940000000000000000000000000000000000000000000
000000000000000000000000000000000000c0000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000000
0000000000000000000dd000000000000000ccc0000dd0000000000000000c000000000000000000000000000000000000000000000000000000000000000000
00000000000000000f0df000000dd0000dd0cccc0f0df000000000000dd0c0000dd0cccc0dd0c000000000000000000000000000000000000000000000000000
000000000000000000aaaaf0000df0000df0accc00aaaaf0000000000df0a0000df0a0000df0ac00000000000000000000000000000000000000000000000000
0000000000000000000aa0000faaaaf0aaaa00cc000aa00000000000aaaa0000aaaa0000aaaa00c0000000000000000000000000000000000000000000000000
000000000000000000094000000aa000faa0000c0009400000000000faa00000faa00000faa0000c000000000000000000000000000000000000000000000000
00000000000000000009040000094400094400000009040000000000094400000944000009440000000000000000000000000000000000000000000000000000
00000000000000000090004000990040990040000090004000000000990040009900400099004000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000ddc00000000000000000000000000000000000000000000000000000000000000000000000000
00000000000dd000000dd0000000000000000000000dd0c0000df0c0000dd0c00000000000000000000000000000000000000000000000000000000000000000
00000000000df000000df000000dd000000dd000000df0c0000aa00c000df0c0000dd000000dd000000000000000000000000000000000000000000000000000
00000000000aa000000aa000000df000000df000000aa0c0000aa000000aa0c0000df000000df000000000000000000000000000000000000000000000000000
000000000f0aa000000aa000000aa000000aa0c0000aa0c000099000000aa0c0000aa00c000aa000000000000000000000000000000000000000000000000000
0000000000c9440000f94000000aa000000aac00000999000004090000099000000aa0c0000aa000000000000000000000000000000000000000000000000000
00000000000c0000009c0400009ccc000009c00000040000004000900044090000449c000004ccc0000000000000000000000000000000000000000000000000
000000000090c0000000c40000004000000400000040000000000000000009000000900000090000000000000000000000000000000000000000000000000000
