pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
function _init()
 poke(0x5f2c,3) // set resolution to 64x64
 x=30
 show_hitbox=-1
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
        sprites={36},
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
  if (p.state=="fighting" or p.state=="deflecting") and p.deflectdelay>0 then
    p.state="deflecting"
    p.deflectdelay-=1
  end
  t+=1
  animate(p)
  update_enemies()
  update_player()
  update_fx()
end

function _draw()
  spr(p.sprites[p.state].sprites[p.frame+1],
      p.x,p.y,1,1,(p.flip=="t"),false)
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
  print(p.frame+1,0,0,7)
  print(p.state,0,10,7)
  print(t,0,20,7)
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
          p.deflectdelay=4
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
          c=5+flr(rnd(3)),
          update=gravity_update,
          ttl=100
        })
    end
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

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000dd000000dd00000000000000000000000000000000000000dd0000000000000000000000000000000000000000000000000000000000000000000
00700700000df0000f0df0000f0dd000000dd000000dd000000dd0f00f0df0000000000000000000000000000000000000000000000000000000000000000000
000770000044440000aaaaf000adfa00000df000000df0f000adfa0000aaaaf00000000000000000000000000000000000000000000000000000000000000000
0007700000f88f00000aa000000aa0f00faaaaf00faaaa000f0aa000000aa0000000000000000000000000000000000000000000000000000000000000000000
0070070000f99f000009400000094000000aa000000aa000000aa000000940000000000000000000000000000000000000000000000000000000000000000000
00000000000aa0000009040000090400000904000009040000090400000904000000000000000000000000000000000000000000000000000000000000000000
00000000000660000090004000900040009000400090004000900040009000400000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000dd00000000000000000000000000000000000000dd000000dd0000000000000000000000dd0000000000000000000000000000000000000000000
00000000000df0000000000000dd00440000000000000000000df000000df000000dd000000df000000df0000006650000000000000000000000000000000000
00000000004444000000000000dfa4000000000000000000000aa000000aa000000df000000aa000000aa0000000000000000000000000000000000000000000
0000000000f88f000000000000aaa000f000000000000000000aa000000aa000000aa000000aa000000aa0000000000000000000000000000000000000000000
000000000f0990f00000000000f09000000000000000000000094000000aa000000aa000000aa000000aa0000000000000000000000000000000000000000000
00000000000aaa60000000000000900000000000000000000009400000094000000aa00000094000000940000000000000000000000000000000000000000000
00000000006000000000000000009000000000000000000000094000000940000009400000094000000940000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000094000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000dd0000000000000000000000dd00000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000f0df000000dd0000000dd0f0f0df00000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000aaaaf0000df0000000df0a00aaaaf000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000aa0000faaaaf000faaaa0000aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000094000000aa0000000aa000009400000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000009040000094400000094400009040000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000090004000990040000990040090004000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000dd000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000dd000000dd0000000000000000000000dd000000df000000dd0000000000000000000000000000000000000000000000000000000000000000000
00000000000df000000df000000dd000000dd000000df000000aa000000df000000dd000000dd000000000000000000000000000000000000000000000000000
00000000000aa000000aa000000df000000df000000aa000000aa000000aa000000df000000df000000000000000000000000000000000000000000000000000
00000000000aa000000aa000000aa000000aa000000aa00000099000000aa000000aa000000aa000000000000000000000000000000000000000000000000000
000000000009440000094000000aa000000aa000000999000004090000099000000aa000000aa000000000000000000000000000000000000000000000000000
00000000000900000099040000994000000990000004000000400090004409000044900000044000000000000000000000000000000000000000000000000000
00000000009000000000040000004000000400000040000000000000000009000000900000090000000000000000000000000000000000000000000000000000
