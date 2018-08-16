pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
poke(0x5f2c,3) -- set resolution to 64x64

chars = '0123456789'
charnums = {}
for i=1,#chars do
  charnums[sub(chars, i, i)] = i
end
 
function chartonum(c)
  return charnums[c] or 0
end
-- todo combo system omg freal ( for slashing? build up foes one side then slash them down)
-- jump attack
-- jump defend from above
-- powerups
function _init()
 mode=0
 x=30
 score=0
 score_multiplier=0
 score_multiplier_timer=0
 combo=0
 combo_fx={w=0,h=0}
 show_hitbox=-1
 saber_colors={12,7,6}
 laser_colors={8,7,14}
 saber_cache_colors={13,2,1}
 laser_fx_colors={12,7,6,12,6,1,2,1,13,1,1}
 saber_cache={}
 numbers = {
  {8*10, 8*2},
  {8*11, 8*2},
  {8*12, 8*2},
  {8*13, 8*2},
  {8*14, 8*2},
  {8*15, 8*2},
  {8*10, 8*3},
  {8*11, 8*3},
  {8*12, 8*3},
  {8*13, 8*3},
 }
 p={
    t=0,
    x=30,
    dx=0,
    y=32,
    frame=0,
    state="idle",
    flip="f",
    kickdelay=0,
    deflectdelay=0,
    health=3,
    total_health=3,
    hbox={
      running={
        f={xmod=3,ymod=1,w=2,h=6},
        t={xmod=3,ymod=1,w=2,h=6}
      },
      idle={
        f={xmod=3,ymod=1,w=2,h=6},
        t={xmod=3,ymod=1,w=2,h=6}
      },
      kicking={
        f={xmod=4,ymod=1,w=6,h=3},
        t={xmod=-3,ymod=1,w=6,h=3}
      },
      fighting={
        f={xmod=0,ymod=1,w=7,h=7},
        t={xmod=0,ymod=1,w=7,h=7}        
      },
      deflecting={
        f={xmod=0,ymod=1,w=7,h=7},
        t={xmod=0,ymod=1,w=7,h=7}        
      },
      dash={
        f={xmod=0,ymod=1,w=64,h=7},
        t={xmod=-64,ymod=1,w=64,h=7}
      }
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
      },
      dash={step=5,
        sprites={9,10,11,12,13,14,15,28,29}  
      }
    }
   }
 t=0
 enemies={}
 enemy_sprs={
    laser=27,
    stormtrooper={
      state="walking",
      sprites={
        walking={
          step=6,
          --sprites={80,81,82,83,84,85,86,87,88,89}
          --sprites={112,113,114,115}
          sprites={96,97,98,99,100,101,102,103}
        },
        dying={
          step=2,
          sprites={122,106,122,107,108,109}
        }
      }
    }
 }
 delays = {}
 fx={}
end

function _update()
  t+=1
  --printh("t:"..t)
  if mode == 0 then  -- title
    if btnp(4) then
      _init()
      mode+=1
    end
  elseif mode == 2 then -- endgame screen
    if btnp(4) then
      _init()
    end
  elseif mode == 1 then
    if not btn(0) or not btn(1) then
      p.dx=0
    end
    if btn(0) then
      p.dx=-.5
      p.state="running"
      p.flip="t"
    elseif btn(1) then
      p.dx=.5
      p.state="running"
      p.flip="f"
    elseif btnp(3) then
      show_hitbox*=-1
    elseif p.state=="running" then
      p.state="idle"
      p.frame=0
    elseif btn(4) and btn(5) and p.state != "dash" and combo>=10 then
      -- do the slash attack thing
      p.state="dash"
      score_multiplier=combo/10
      score_multiplier_timer=60*(combo/2)
      p.frame=0
      combo=0
      -- do cool fx
      if p.flip == "f" then
        newpx = min(p.x+40, 56)
      else
        newpx = max(p.x-40, 0)
      end
      -- kill all enemies in path
      delay(dash_fx,{startx=p.x,finishx=newpx,y=p.y},.5)
    elseif btnp(4) and p.state != "fighting" then
      p.state="fighting"
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
    if p.state=="dash" and p.frame>2 then
      if p.flip == "f" then
        newpx = min(p.x+40, 56)
      else
        newpx = max(p.x-40, 0)
      end
      p.x=newpx

    end
    if p.state=="dash" and p.frame>=#p.sprites.dash.sprites-1 then
      p.state="idle"
      p.frame=0
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
    p.x+=p.dx
   
    t+=1
    animate(p)
    update_enemies()
    update_player()
    update_fx()
    update_delays()
    combo_fx_update()
  end
  if p.health < 0 then
    mode=2
  end
end

function _draw()
  rectfill(0,0,64,64,1)

  if mode==0 then
    print("set fire to the", 2, 10,7)
    print("empire", 20, 20, 7)
    print("press z to start", 0, 55, 7)
  elseif mode == 2 then
    print("you set fire to ", 2, 10, 7)
    print("the empire!", 7, 18, 7)
    print("score: "..score, 15, 33, 7)
    print("press z", 15, 48, 7)
    print("to restart", 12, 55, 7)
  elseif mode == 1 then
    for item in all(saber_cache) do
      pset(item[1],item[2],saber_cache_colors[1+flr(rnd(#saber_cache_colors))])
      item[3]-=1
      if item[3]<=0 then
        del(saber_cache,item)
      end
    end

    for enemy in all(enemies) do
      if enemy.type=="laser" then
        spr(enemy_sprs[enemy.type],
            enemy.x, enemy.y, 1,1,(enemy.dx>1),false)
        --sparkly laser fx
        for i=enemy.x,enemy.x+7 do
          for j=enemy.y,enemy.y+7 do
            if pget(i,j) == 8 or pget(i,j) == 7 or pget(i,j) == 14 then
              pset(i,j,laser_colors[1+flr(rnd(3))])
            end
          end
        end
      else
        palt(0, false)
        palt(1, true)
        spr(enemy.sprites[enemy.state].sprites[enemy.frame+1],
            enemy.x,enemy.y,1,1,(enemy.flip=="t"),false)
        palt()
      end
      -- draw enemy hitbox in red
      if show_hitbox<1 then
        rect(enemy.x+enemy.hbox.xmod,enemy.y+enemy.hbox.ymod,
            enemy.x+enemy.hbox.xmod+enemy.hbox.w,
            enemy.y+enemy.hbox.ymod+enemy.hbox.h,8)
      end
    end
    -- draw fx
    for f in all(fx) do
      pset(f.x,f.y,f.c)
    end
    -- debug
    --print(p.x,0,0.7)
    --print(p.frame+1,0,0,7)
    --print(p.state,0,10,7)
    --print(t,0,20,7)
    --print(p.deflectdelay,0,24,7)
    -- draw player hitbox in red
    if show_hitbox<1 then
      rect(p.x+p.hbox[p.state][p.flip].xmod,
           p.y+p.hbox[p.state][p.flip].ymod,
           p.x+p.hbox[p.state][p.flip].xmod+p.hbox[p.state][p.flip].w,
           p.y+p.hbox[p.state][p.flip].ymod+p.hbox[p.state][p.flip].h,8)
    end

   -- end debug

    -- draw player
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
    --print("health: "..p.health,2,2,7)
    -- health
    for i=1,p.total_health do
      spr(162, 9*i+10, 0)
    end
    for i=1,p.health do
      spr(161, 9*i+10, 0)
    end
    --print("combo: "..combo,2,8,7)
    if #tostr(combo) <= 1 then
      sspr(numbers[combo+1][1],numbers[combo+1][2],8,8,
          25,10,16+combo_fx.w,16+combo_fx.h)
    else
      for i=1, #tostr(combo) do
        local c = sub(combo,i,i)
        --printh("combo:"..combo.." c:"..c.." tonum:"..chartonum(c))
        sspr(numbers[chartonum(c)][1],numbers[chartonum(c)][2],8,8,
          10+(i*10),10,16+combo_fx.w,16+combo_fx.h)
      end
    end
    -- printing score
    local digits=score
    local modx=0
    while flr(digits/10) > 0 do
      modx+=2
      digits=flr(digits/10)
    end

    for i=-1,1 do
      for j=-1,1 do
        print(score, 30+i-modx, 50+j,2)
      end
    end
    print(score,30-modx,50,7)

    if score_multiplier > 0 and score_multiplier_timer > 0 then
      spr(0,21,56)
      for i=-1,1 do
        for j=-1,1 do
          print(score_multiplier, 30+i, 58+j,2)
        end
      end
      print(score_multiplier,30,58,9)

      print(score_multiplier_timer,0,0,9)
    end
    -- print helper if combo > 10
    if combo >= 10 then
      for i=-1,1 do
        for j=-1,1 do
          print("z+x dash", 16+i, 44+j, 2)
        end
      end
      print("z+x dash", 16, 44, 7)

    end

    -- sparkly bois
    
  end
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
  if t%200 == 0 then

    if flr(rnd(2)) == 0 then
      add(enemies,{x=100,y=32,dx=-1,
                   dy=0,type="laser",t=0,
                   hbox={xmod=3,ymod=2,w=2,h=0},
                   reflected=false})
    else
      add(enemies,{x=-40,y=32,dx=1,
                   dy=0,type="laser",t=0,
                   hbox={xmod=3,ymod=2,w=2,h=0},
                   reflected=false})
    end

  elseif t%60 == 0 then
    if flr(rnd(2)) == 0 then
    new_enemy={x=64,y=32,dx=-0.1, state="walking",
               dy=0,type="stormtrooper",t=0,frame=0,
               hbox={xmod=2,ymod=0,w=3,h=8}}
    else
      new_enemy={x=0,y=32,dx=0.1, state="walking",
                 dy=0,type="stormtrooper",t=0,frame=0,
                 flip="t",
                 hbox={xmod=2,ymod=0,w=3,h=8}}
    end
    new_enemy.sprites = enemy_sprs[new_enemy.type].sprites
    new_enemy.step = enemy_sprs[new_enemy.type].step
    new_enemy.about_to_die=false
    add(enemies,new_enemy)    
  end

  for enemy in all(enemies) do
    enemy.x+=enemy.dx
    enemy.y+=enemy.dy
    enemy.t+=1
    if enemy.type=="stormtrooper" then
      animate(enemy)
    end
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
      if enemy.type == "stormtrooper" and not enemy.about_to_die and p.state == "dash" then
        enemy.about_to_die=true
        delay(enemy_die, enemy, .75)
        delay(set_enemy_dying, enemy, .25)
        delay(explody_fx, enemy, .55)
        score+=flr(100 + (score_multiplier * 100))
        combo_add()

        --enemy_die(enemy)
      elseif enemy.type == "stormtrooper" and not enemy.about_to_die and p.state == "kicking" then
        enemy.about_to_die=true
        delay(enemy_die, enemy, .25)
        delay(explody_fx, enemy, .05)
        score+=flr(125 + (score_multiplier * 125))
        combo_add()
      end
      if enemy.type == "laser" then
        if p.state=="fighting" then
          -- enemy laser dies!
          p.frame=4
          p.deflectdelay=7
          enemy_die(enemy)
          score+=flr(50 + (score_multiplier * 50))
        elseif p.state=="dash" then
          enemy_die(enemy)
        else
          enemy_die(enemy)
          p.health-=1
        end
      end
    end
    if enemy.type == "laser" and enemy.reflected == true then
      for enemy2 in all(enemies) do
        if enemy2.type == "stormtrooper" and check_collision(
            {x=enemy.x+enemy.hbox.xmod,
             y=enemy.y+enemy.hbox.ymod,
             w=enemy.hbox.w,
             h=enemy.hbox.h},
            {x=enemy2.x+enemy2.hbox.xmod,
             y=enemy2.y+enemy2.hbox.ymod,
             w=enemy2.hbox.w,
             h=enemy2.hbox.h}) then
             del(enemies, enemy)
             explody_fx(enemy2)
             enemy_die(enemy2)
             score+=flr(200 + (score_multiplier * 200))
             combo_add()
        end
      end
    end
    if enemy.x<-100 or enemy.x>100 then
      del(enemies,enemy)
    end
  end
end

function update_player()
  if score_multiplier_timer > 0 then
    score_multiplier_timer-=1
  else
    score_multiplier=0
  end
end

function enemy_die(enemy)
  if enemy.type=="laser" then
    -- do some cool fx where the laser explodes into the 3 px
    -- moving random directions
    explody_fx(enemy)
    add(enemies,{x=enemy.x,y=32,dx=enemy.dx*-2,
                 dy=0,type="laser",t=0,
                 reflected=true,
                 about_to_die=false,
                 hbox={xmod=3,ymod=2,w=2,h=0}})
  end
  del(enemies,enemy)
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

function laser_update(f)
  f.c=laser_fx_colors[1+flr(rnd(#laser_fx_colors))]
  f.y+=f.dy
  f.x+=f.dx*flr(rnd(1))
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

function explody_fx(enemy)
  for i=4,7+rnd(4) do
    add(fx,
      {
        x=enemy.x,y=enemy.y,
        dx=(2+rnd(3)),
        dy=rnd(3)*-1,
        c=8+flr(rnd(3)),
        update=gravity_update,
        ttl=100,
      })
  end
end
function dash_fx(obj)
  local beginx=obj.startx
  obj.startx = flr(obj.startx)
  obj.finishx = flr(obj.finishx)
  printh("new dashfx ttl: "..min(obj.beginx,obj.finishx)*15)
  while obj.startx != obj.finishx do
    --printh("startx:"..obj.startx.." finishx:"..obj.finishx)
    for k=2,8 do
      add(fx,
        {
          x=obj.startx,y=obj.y+k,
          dy=rnd(1)*-1,
          dx=flr(rnd(2))*flr(rnd(2)),
          c=laser_fx_colors[1+flr(rnd(#laser_fx_colors))],
          update=laser_update,
          ttl=rnd(5)*rnd(2)+min(obj.beginx,obj.finishx)
        }
      )      
    end
    if obj.startx<obj.finishx then
      obj.startx+=1
    else
      obj.startx-=1
    end
  end
  --[[
  printh(startx,finishx,y)
  for k=2,8 do
    for i=startx,finishx+8 do
      add(fx,
        {
          x=i,y=y+k,
          dy=rnd(1)*-1,
          dx=sin(i/5)/5,
          c=laser_fx_colors[1+flr(rnd(#laser_fx_colors))],
          update=laser_update,
          ttl=i/5
        }
      )
    end
  end
  --]]
end

function delay(orig_fun, orig_obj, ttl)
  add(delays, 
      {
        ttl=ttl*30,
        f=orig_fun,
        obj=orig_obj
       }
  )
end
function update_delays()
  for delay in all(delays) do
    delay.ttl-=1
    if delay.ttl<=0 then
      delay.f(delay.obj)
      del(delays, delay)
    end
  end
end

function set_enemy_dying(enemy)
  enemy.state="dying"
  frame=0
end

function combo_add()
  combo+=1
  combo_fx.w=flr(4+rnd(10))
  combo_fx.h=flr(4+rnd(10))
end

function combo_fx_update()
  if combo_fx.w>0 then
    combo_fx.w-=2
  else
    combo_fx.w=0
  end
  if combo_fx.h>0 then
    combo_fx.h-=2
  else
    combo_fx.h=0
  end
end

__gfx__
0000000000000000000000c00000000000000000000000c0000000c0000000c000000000000000c00000000c0000000000000000000000000000000000000000
00000000000dd000000dd0c0000000c0000000c0000000c0000000c0000dd0c000000000000dd0c000000ccc00000c0000000000000000000000000000000000
00220220000df0000f0df0c00f0dd0c0000dd0c0000dd0c0000dd0c00f0df0c0000000000f0df0c0000ddccc000ddcc0000dd000000000000000000000000000
002929200044440000aaaaf000adfac0000df0c0000df0f000adfaf000aaaaf00000000000aaaaf00aadffc0000dfcc00f0df0f000000dd000000dd000000dd0
0002920000f88f00000aa000000aa0f00faaaaf00faaaa000f0aa000000aa00000000000000aa000f0aaa00000aaaccccccaaaa0cccfadfacccfadfacccfadfa
0029292000f99f000009400000094000000aa000000aa000000aa00000094000000000000009400000940000009fcccc0cccc00000000aaf00000aaf00000aaf
00220220000aa0000009040000090400000904000009040000090400000904000000000000090400009040000049000000cccc0000004aa000004aa000004aa0
000000000006600000900040009000400090004000900040009000400090004000000000009000400904000004490000040c9000000400900004009000040090
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000dd00000000000000000000000000000000000000dd000000dd0000000000000000000000dd0000000000000000000000000000000000000000000
00000000000df0000000000000dd00440000000000000000000df000000df000000dd000000df000000df0000000000000000000000000000000000000000000
00000000004444000000000000dfa4000000000000000000000aa00000aaa000000df000000aa000000aa0000000000000000dd000000dd00000000000000000
0000000000f88f000000000000aaa000000000000000000000faa0000f0aa000000aa000000aa000000aa00000088800cccfadfacccfadfa0000000000000000
000000000f0990f00000000000f090000000000000000000000c400000caa000000aa00000fcccc000fcccc00000000000000aaf00000aaf0000000000000000
00000000000aaa60000000000000900000000000000000000009c000000c400000fcccc000094000000940000000000000004aa000004aa00000000000000000
00000000006000000000000000009000000000000000000000094c000009c0000009400000094000000940000000000000040090000400900000000000000000
000000000000000000000000000000000000c0000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000000
0000000000000000000dd000000000000000ccc0000dd0000000000000000c000000000000000000022222000222200002222200022222000222220002222200
00000000000000000f0df000000dd0000dd0cccc0f0df000000000000dd0c0000dd0cccc0dd0c000027772000277200002777200027772000272720002777200
000000000000000000aaaaf0000df0000df0accc00aaaaf0000000000df0a0000df0a0000df0ac00027272000227200002227200022272000272720002722200
0000000000000000000aa0000faaaaf0aaaa00cc000aa00000000000aaaa0000aaaa0000aaaa00c0027272000027200002777200022772000277720002777200
000000000000000000094000000aa000faa0000c0009400000000000faa00000faa00000faa0000c027272000227220002722200022272000222720002227200
00000000000000000009040000094400094400000009040000000000094400000944000009440000027772000277720002777200027772000002720002777200
00000000000000000090004000990040990040000090004000000000990040009900400099004000022222000222220002222200022222000002220002222200
000000000000000000000000000000000000000000000000000ddc00000000000000000000000000000000000000000000000000000000000000000000000000
00000000000dd000000dd0000000000000000000000dd0c0000df0c0000dd0c00000000000000000022200000222220002222200022222000000000000000000
00000000000df000000df000000dd000000dd000000df0c0000aa00c000df0c0000dd000000dd000027200000277720002777200027772000000000000000000
00000000000aa000000aa000000df000000df000000aa0c0000aa0f0000aa0c0000df000000df000027222000222720002727200027272000000000000000000
000000000f0aa000000aa000000aa000000aa0c0000aafc000099a00000aafc0000aa00c000aa000027772000002720002777200027772000000000000000000
0000000000c9440000f94000000aa000000aac00000999000004090000099000000aa0c0000aa000027272000002720002727200022272000000000000000000
00000000000c0000009c0400009ccc000009c00000040000004000900044090000449c000004ccc0027772000002720002777200000272000000000000000000
000000000090c0000000c40000004000000400000040000000000000000009000000900000090000022222000002220002222200000222000000000000000000
00066000000000000000000011176111111111111117611111176111111761111117611111111111000000000000000000000000000000000000000000000000
00006000000000000000000011107111111761111110711111107111111071111110711111176111000000000000000000000000000000000000000000000000
0006600000000000000000001d55011111107111111771111d550111111771111d55011111107111000000000000000000000000000000000000000000000000
06066000000000000000000011177111111771111d5501111117711111d550111117711111177111000000000000000000000000000000000000000000000000
0005656000000000000000001110711111d55011111671111115711117707111111571111d550111000000000000000000000000000000000000000000000000
00000500000000000000000016610111111671111110011117700111111501111770011111167111000000000000000000000000000000000000000000000000
00056500000000000000000011117111111001111171611111116111111161111111611111100111000000000000000000000000000000000000000000000000
00056000000000000000000011117111111671111711611111116111111161111111611111167111000000000000000000000000000000000000000000000000
11176111111761111117611111176111111111111117611111176111111761111117611111111111000000000000000011111111000000001111111100000000
11107111111071111110711111107111111761111110711111107111111071111110711111176111000000000000000011117711000000001111771100000000
111771111d550111111771111d55011111107111111771111d550111111771111d55011111107111000000000000000011110711000000001111071100000000
1d5501111117711111d5501111177111111771111d5501111117711111d550111117711111177111000000000000000011117711000000001111771100000000
1116711111107111166071111110711111d55011111671111115711117707111111571111d550111000000000000000011117711000000001111771100000000
11100111166101111111011116610111111671111110011117700111111501111770011111167111000000000000000011177111000000001177111100000000
11617111111171111111711111117111111001111171611111116111111161111111611111100111000000000000000011100111000000001100111100000000
16117111111171111111711111117111111671111711611111116111111161111111611111167111000000000000000011175111000000001175111100000000
11177111111111111111111111177111111771111111111111111111111111110000000000000000111111111111111111111111111111110000000000000000
11107111111771111117711111107111111071111117711111177111111771110000000000000000111771111117711111117711111117710000000000000000
11177111111071111110711111177111111771111110711111107111111071110000000000000000111071111110711111110711111110710000000000000000
11177111111771111117711111177111111771111117711111177111111771110000000000000000111771111117711111117711111117710000000000000000
11177111111771111117711111100111111001111117711111177111111771110000000000000000111771111117711111117711111117710000000000000000
11100111111771111110011111517111111571111110011111100111117001110000000000000000111771111177111117711111771111110000000000000000
11715511111001111117111115111711115177111115711111171111117151110000000000000000111001111100111110011111001111110000000000000000
17111111111751111115711111111171115111111115711111175111111115110000000000000000111751111175111117511111751111110000000000000000
11177111111111111117711111111111111111111117711111177111111111110000000000000000111111110000000000000000000000000000000000000000
11107111111771111110711111177111111771111110711111107111111771110000000000000000111111110000000000000000000000000000000000000000
11177111111071111117711111107111111071111117711111177111111071110000000000000000111111110000000000000000000000000000000000000000
11177111111771111117711111177111111771111117711111177111111771110000000000000000111111110000000000000000000000000000000000000000
11177111111771111117711111177111111771111117711111177111111771110000000000000000111111110000000000000000000000000000000000000000
11775111111771111155711111177111111771111115511111155111111751110000000000000000111111110000000000000000000000000000000000000000
17115511111751111511771111157111111751111151711111517111111577110000000000000000111111110000000000000000000000000000000000000000
11111111111571111111111111175111111171111111171111117711111511110000000000000000111111110000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02222200022220000222220002222200022222000222220002220000022222000222220002222200000000000000000000000000000000000000000000000000
02777200027720000277720002777200027272000277720002720000027772000277720002777200000000000000000000000000000000000000000000000000
02727200022720000222720002227200027272000272220002722200022272000272720002727200000000000000000000000000000000000000000000000000
02727200002720000277720002277200027772000277720002777200000272000277720002777200000000000000000000000000000000000000000000000000
02727200022722000272220002227200022272000222720002727200000272000272720002227200000000000000000000000000000000000000000000000000
02777200027772000277720002777200000272000277720002777200000272000277720000027200000000000000000000000000000000000000000000000000
02222200022222000222220002222200000222000222220002222200000222000222220000022200000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077007700770077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000788778877007700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000788888877000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000788888877000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000078888700700007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000007887000070070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000770000007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
