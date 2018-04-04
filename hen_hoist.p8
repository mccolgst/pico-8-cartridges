pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
gravity = 0.2
x_speed = 0.5
player = {x=64,
          y=64,
          sprites={
            jumping={step=2,
                     sprites={2,3,4,5}},
            standing={step=5,
                      sprites={33,34,35,36}},
            running={step=3,
                     sprites={18,19,20,21,22}},
          },
          state="standing",
          step=4,
          frame=0,
          flipx=false,
          t=0,
          jumping=false,
          dy=0,dx=0,
          w=8,h=8,
}
feather_fx = {}
dust_fx = {}
cam={x=0,y=0}
branches = {{x=50,y=30,w=6,h=3, short=true, leaves={{x=10,y=30,w=8,h=8,bounce=false,}}},
             --{x=50,y=50,w=6,h=3, leaves={{x=20,y=50,w=8,h=8,bounce=true}}},
             {x=60,y=80,w=6,h=3, short=true, leaves={{x=30,y=80,w=8,h=8,bounce=false}}}}
tree_seg_height=2
tree = {}
const_acorn_timer=20*2
acorn_timer=const_acorn_timer
acorns = {}
acorn_pals = {{7,8}, {13,2}, {5,1}}
dust_colors = {7,1,6,5}
t=0

function _init()
  add(tree, {x=rnd(20),y=128})
  for i=1,256*tree_seg_height do
    add(tree, {x=30+rnd(20),y=tree[#tree].y-tree_seg_height})
  end
end

-- if player is within a certain threshold of last branch,
-- create more branches
-- clean up old branches
-- player dies if falls too far?


function _update()
  --animate(player)
  update_player()
  update_branches()
  update_feather_fx()
  if player.y<90 then
    cam.y=player.y-84
  end
  camera(cam.x,cam.y)
  more_branches()
  update_tree()
  update_acorns()
  update_dust_fx()
  t+=1
end

function _draw()
  cls()
  -- background
  rectfill(cam.x,cam.y,cam.x+128,cam.y+128,12)

  draw_tree()
  animate(player)
  draw_feather_fx()
  draw_branches()
  draw_dust_fx()
  draw_sun()
  draw_acorns()
  outline_spr(player.sprites[player.state].sprites[player.frame+1],
      player.x,
      player.y,
      1,1,1,player.flipx)
  --pset(player.x,player.y,8)
  pset(cam.x,cam.y,8)

end

function animate(obj)
  -- animation
  obj.t=(obj.t+1)%obj.sprites[obj.state].step
  if (obj.t==0) then
    obj.frame=(obj.frame+1)%#obj.sprites[obj.state].sprites
  end
end

function update_player()
  if btnp(4) and player.state != "jumping" then
    player.dy-=10
    player.state="jumping"
    player.frame=0
    create_dust_fx(player.x, player.y, false)
    create_dust_fx(player.x, player.y, false)
    create_dust_fx(player.x, player.y, false)
  end
  if btn(0) then
    player.dx-=x_speed
    player.flipx=false
    if player.state != "jumping" then player.state="running" end

  elseif btn(1) then
    player.dx+=x_speed
    player.flipx=true
    if player.state != "jumping" then player.state="running" end
  end

  if btn(3) and player.state=="jumping" then
    if player.dy<5 then player.dy+=1 end
    create_dust_fx(player.x, player.y, true)
  end

  --animate(player)
  if player.dy<-10 then
        create_dust_fx(player.x, player.y, true)
        create_dust_fx(player.x, player.y, true)
        create_dust_fx(player.x, player.y, false)  
  end

  -- dy decay and gravity
  player.dy=player.dy*0.9
  player.dy+=gravity

  -- dx decay
  player.dx*=0.8
  if abs(player.dx)<0.3 then
    player.dx=0
  end

  -- hit ground
  if player.y+player.dy>120 then
    player.y=120
    player.dy=0
    player.state="standing"
  end

  -- check if hit branch
  for branch in all(branches) do
    --[[
    if abs((player.y+8+player.dy)-(branch.y))<3 and
       player.x>branch.x-4 and
       player.x<branch.x+20 then
      if branch.bounce then
        player.dy-=20
        create_dust_fx(player.x, player.y, false)
        create_dust_fx(player.x, player.y, false)
        create_dust_fx(player.x, player.y, false)

      elseif player.dy>0 then
        player.y=branch.y-8
        player.dy=0
        if player.state=="jumping" then 
          create_dust_fx(player.x, player.y, false)
          create_dust_fx(player.x, player.y, false)
          create_dust_fx(player.x, player.y, false)
          player.state="standing"
        end
      end
    end
    --]]
    for leaf in all(branch.leaves) do
      if check_collision(player, leaf) then

        if leaf.bounce then
          player.dy-=20
        elseif player.dy>0 then
          player.y=leaf.y-8
          player.dy=0
          if player.state=="jumping" then 
            create_dust_fx(player.x, player.y, false)
            create_dust_fx(player.x, player.y, false)
            create_dust_fx(player.x, player.y, false)
            player.state="standing"
          end
        end
      end
    end
  end

  if player.dy==0 and player.dx==0 and player.state != "standing" then
    player.state="standing"
    player.frame=0
  end

  if player.dx != 0 and player.state != "running" and player.state != "jumping" then
    player.state="running"
    player.frame=0
  end

  if player.state=="jumping" then
    create_feather_fx()
  end

  if player.dy>0 then
    player.state="jumping"
  end

  -- move player
  player.y+=player.dy
  player.x+=player.dx

end

function create_feather_fx()
  if flr(rnd(6)) ==0 then
    local newf = {
      x=player.x+rnd(3),
      y=player.y+rnd(3),
      t=flr(rnd(60))
    }
    add(feather_fx,newf)
  end
end

function update_feather_fx()
  for fx in all(feather_fx) do
    fx.t+=1
    fx.x=fx.x+cos((fx.t%60/60))
    fx.y+=0.5
    if fx.t>30*5 then
      del(feather_fx, fx)
    end
  end
end

function draw_feather_fx()
  for fx in all(feather_fx) do
    pset(fx.x,fx.y,7)
    pset(fx.x+1,fx.y,7)
    if cos((fx.t%60/60)) > 0 then
      pset(fx.x-1,fx.y-1,7)
    else
      pset(fx.x+2,fx.y-1,7)

    end
  end
end

function outline_spr(sprite, x, y, w, h, c, flip_x)
  for i=1,15 do
    pal(i,c)
  end
  for i=-1,1 do
    for j=-1,1 do
      spr(sprite, x+i, y+j, w, h, flip_x)
    end
  end
  pal()
  spr(sprite, x, y, w, h, flip_x)
end

function draw_branches()
  outline = 1
  local sprite = 64
  for branch in all(branches) do
    if #branch.leaves<1 then
      printh("PROBLEM HERE.."..branch.x.." "..branch.y.." branch.short:"..tostr(branch.short))
      rect(branch.x,branch.y,branch.x+branch.w*8,branch.y+branch.h*8,8)

    end
    
    --printh("branch.x:"..branch.x.." branch.y:"..branch.y.." branch.short:"..tostr(branch.short).." branch.flipx:"..tostr(branch.flipx))
    --if branch.bounce then color = 11 else color = 3 end
    if branch.short then sprite = 70 end
    if branch.flipx then
      pal(4,2)
      pal(9,4)
      pal(10,9)
    end
    spr(sprite,branch.x,branch.y,branch.w,branch.h,branch.flipx)
    pal()
    for leaf in all(branch.leaves) do
      printh("leaf.x:"..leaf.x.." leaf.y:"..leaf.y)
      local sprite = 59
      if leaf.bounce then
        sprite = 60
      end
      rect(leaf.x,leaf.y,leaf.x+8,leaf.y+8,8)
      outline_spr(sprite,leaf.x,leaf.y,1,1,1,false)
    end
    --outline_spr(59,branch.x,branch.y,1,1,1,false)

    --[[
    line(branch.x,branch.y-1,branch.x+20,branch.y-1,outline)

    line(branch.x,branch.y,branch.x+20,branch.y,color)
    line(branch.x+3,branch.y+1,branch.x+17,branch.y+1,color)
    line(branch.x+5,branch.y+2,branch.x+15,branch.y+2,color)
    
    --bottom
    line(branch.x+5,branch.y+2,branch.x+15,branch.y+2,outline)

    --corners
    line(branch.x+5,branch.y+2,branch.x-1,branch.y-1,outline)
    line(branch.x+15,branch.y+2,branch.x+21,branch.y-1,outline)
    --]]
  end
end

function draw_tree()
  for i=1,#tree do
    rectfill(tree[i].x,tree[i].y,tree[i].x+40,tree[i].y+15,4)
    rectfill(tree[i].x,tree[i].y,tree[i].x+10,tree[i].y+8,2)
    rectfill(tree[i].x+30,tree[i].y,tree[i].x+40,tree[i].y+12,9)
  end
end

function update_tree()
  if abs(tree[#tree].y) - abs(player.y) < 128*tree_seg_height then
    for i=0,100 do
      del(tree, tree[1])
      add(tree, {x=30+rnd(20),y=tree[#tree].y-tree_seg_height})
    end
  end
end

function update_branches()
  for branch in all(branches) do
  end
end

function obj_on_screen(obj)
  if obj.y > cam.y and obj.y < cam.y+128 then 
    return true
  else
    return false end
end

function more_branches()
  if abs(branches[#branches].y) - abs(player.y) < 200 then
    printh("more branches "..branches[#branches].y.." playery:"..player.y)
    for i=1,10 do
      local branch = {}
      branch.leaves = {}
      branch.x=24+rnd(24)
      branch.short = false
      branch.flipx = false
      branch.w = 6
      branch.h = 3
      branch.y=branches[#branches].y-(i*5)

      if #branch.leaves<1 then printh("PROBLEM HERE IN MAKING BEGIN.."..branch.x.." "..branch.y.." branch.short:"..tostr(branch.short)) end

      if branch.x<90 and branch.x>30 then
        branch.short=true
        branch.w=2
        branch.h=2
      end
      if branch.x<64 then
        -- invert
        branch.flipx=true
        --branch.x-=branch.w*8
      end
      --if branch.x<16 then branch.x+=16 end
      --if branch.x>80 then branch.x-=30 end
      --branch.bounce=flr(rnd(6))==0
      if branch.short then
        for j=1,3 do
          local leaf = {}
          leaf.bounce=flr(rnd(6))==0
          local xmod=rnd(3)
          if flr(rnd(2))==0 then xmod*=-1 end
          local xpos = branch.x+(8*2)+xmod
          local ymod=rnd(3)
          if flr(rnd(2))==0 then ymod*=-1 end
          local ypos = branch.y+(8*2)+ymod
          if flr(rnd(2))==0 then ypos*=-1 end
          --local xpos=branch.x+8
          --local ypos=branch.y+(8*2)
          leaf.x=xpos
          leaf.y=ypos
          leaf.w=8
          leaf.h=8
          if branch.flipx then leaf.x-=branch.w*8 end

          add(branch.leaves,leaf)
        end
      else
        --[[
        for j=1,1+flr(rnd(6)) do
          local leaf = {}
          leaf.bounce=flr(rnd(6))==0
          local xpos = branch.x+(8*5)+rnd(8)
          --if flr(rnd(2))==0 then xpos*=-1 end
          local ypos = branch.y+rnd(8)
          --if flr(rnd(2))==0 then ypos*=-1 end
          leaf.x=xpos
          leaf.y=ypos
          leaf.w=8
          leaf.h=8
          add(branch.leaves,leaf)
        end
        for j=1,1+flr(rnd(6)) do
          local leaf = {}
          leaf.bounce=flr(rnd(6))==0
          local xpos = branch.x+(8*4)+rnd(8)
          --if flr(rnd(2))==0 then xpos*=-1 end
          local ypos = branch.y+(8*3)+rnd(8)
          --if flr(rnd(2))==0 then ypos*=-1 end
          leaf.x=xpos
          leaf.y=ypos
          leaf.w=8
          leaf.h=8
          add(branch.leaves,leaf)
        end
        --]]
      end
      add(branches,branch)
      if #branch.leaves<1 then printh("PROBLEM HERE IN MAKING.."..branch.x.." "..branch.y.." branch.short:"..tostr(branch.short)) end

    end
  end
end

function update_acorns()
  acorn_timer-=1
  if acorn_timer<=0 then
    acorn_timer=const_acorn_timer
    local acorn = {}
    acorn.x=rnd(128)
    acorn.y=cam.y-200
    acorn.t=0
    add(acorns, acorn)
  end
  for acorn in all(acorns) do
    acorn.y+=3
    acorn.t+=1
    if acorn.t%flr(rnd(5))==0 then create_dust_fx(acorn.x, acorn.y, true) end

    if acorn.y > (player.y+200) then
      del(acorns, acorn)
    end
  end
end

function draw_acorns()
  local acorn_step = 10
  for acorn in all(acorns) do
    outline_spr(58,
      acorn.x,
      acorn.y,
      1,1,1,false)

    if acorn.t<45 and acorn.y<cam.y then
      -- do outline manually cus we gotta do manual pal swaps
      for i=1,15 do
        pal(i,1)
      end
      for i=-1,1 do
        for j=-1,1 do
          spr(57, acorn.x+i+rnd(1), cam.y+j+rnd(1), 1, 1, false)
        end
      end
      pal()
      -- end outline

      if acorn.t>=acorn_step*#acorn_pals then acorn.t=0 end

      pal(7, acorn_pals[flr(acorn.t/acorn_step)+1][1])
      pal(8, acorn_pals[flr(acorn.t/acorn_step)+1][2])
      spr(57,
        acorn.x+rnd(1),
        cam.y+rnd(1),
        1,1,false)
      pal()
    end
  end
end

function create_dust_fx(x,y,is_acorn_dust)
  for i=1,10 do
    local dust= {
      t=0,
      r=flr(rnd(2)),
      dy=rnd(3),
      dx=rnd(3),
      is_acorn_dust=is_acorn_dust,
      c=dust_colors[flr(rnd(#dust_colors))+1]
    }
    local mody = rnd(2)
    local modx = rnd(2)
    if flr(rnd(2)) == 0 then
      mody*=-1
    end
    if flr(rnd(2)) == 0 then
      modx*=-1
    end
    if flr(rnd(2)) == 0 then
      dust.dy*=-1
    end
    if flr(rnd(2)) == 0 then
      dust.dx*=-1
    end
    dust.x=x+4+modx
    dust.y=y+mody
    if not is_acorn_dust then dust.y+=9 end
    add(dust_fx, dust)
  end
end

function update_dust_fx()
  for dust in all(dust_fx) do
    dust.t+=1
    if not dust.is_acorn_dust then
      dust.x+=dust.dx
      dust.dy+=gravity
      dust.dx*=0.9
      dust.dy*=0.7
      dust.y+=dust.dy
    else
      dust.y+=dust.dy
    end
    if dust.t%5==0 then dust.r*=.5 end
    if dust.t>60 or dust.r<0.5 then del(dust_fx,dust) end
  end
end

function draw_dust_fx()
  for dust in all(dust_fx) do
    circfill(dust.x, dust.y, dust.r,
             dust.c)
  end
end

function find_in_table(in_table, item)
  for i=1,#in_table do
    if in_table[i] == item then return i end
  end
  return false
end

function draw_sun()
  -- draw a radial pattern that moves around and stuff or something i dono
  p1={x=cam.x+110, y=cam.y+15}
  --line(cos(t/60)*5+p1.x,sin(t/60)*5+p1.y,cos(t/60)*10+p1.x,sin(t/60)*10+p1.y,7)
  for i=0,6 do
    local pos = t%120/120
    local mod = 12
    if flr(pos*10) % 2 == 0 then mod = 10+rnd(6) end
    line(cos(pos+(i*(120/6)/120))*8+p1.x,
         sin(pos+(i*(120/6)/120))*8+p1.y,
         cos(pos+(i*(120/6)/120))*mod+p1.x,
         sin(pos+(i*(120/6)/120))*mod+p1.y,7)
  end
  for i=0,6 do
    local pos = (t+10)%120/120
    local mod = 10
    if flr(pos*10) % 2 == 0 then mod = 10+rnd(4) end
    line(cos(pos+(i*(120/6)/120))*6+p1.x,
         sin(pos+(i*(120/6)/120))*6+p1.y,
         cos(pos+(i*(120/6)/120))*mod+p1.x,
         sin(pos+(i*(120/6)/120))*mod+p1.y,10)
  end
  for i=0,6 do
    local pos = (t+5)%120/120
    local mod = 8
    if flr(pos*10) % 2 == 0 then mod = 10+rnd(2) end
    line(cos(pos+(i*(120/6)/120))*4+p1.x,
         sin(pos+(i*(120/6)/120))*4+p1.y,
         cos(pos+(i*(120/6)/120))*mod+p1.x,
         sin(pos+(i*(120/6)/120))*mod+p1.y,9)
  end

  circfill(cam.x+110,cam.y+15,11,7)
  circfill(cam.x+110,cam.y+15,10,10)

  local score = flr(abs(cam.y)/10)
  local digits=score
  local modx=0
  while flr(digits/10) > 0 do
    modx+=2
    digits=flr(digits/10)
  end

  for i=-1,1 do
    for j=-1,1 do
      print(score, cam.x+109+i-modx, cam.y+13+j,1)
    end
  end
  print(score,cam.x+109-modx,cam.y+13,7)
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
0000000008800000000000000088000000000d000088000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000004170000008800d00041700000880d7d00417000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700087000074170d7d000870d07417077d000870d0700000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000777dd77087777d70077d7d708777d770077d7d700000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000077777d707777d77007777d70777d777007777d700000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000777dd700777d7700077dd70077777700077dd7000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000007777000077770000777700007777000077770000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000009090000090900000909000009090000090900000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000088000000088000000880000088000000000000000088000088000000000000000880000008800000000000008800000000000000000000000000000
00000000417000000417000004170000417000000088000000417000417000000000000004170000041700000000000041700000000000000000000000000000
00000000087000700087000700870000087000070417000000087007087000070000000000870000008700070000000008700007000000000000000000000000
000000000777dd7000777dd7007700070777dd770087000700077dd707777dd70000000000770007007776670000000000777667000000000000000000000000
00000000077777d00077777d00777dd7077777d700777d770077777d0777777d0000000007777dd7007777760000000000777776000000000000000000000000
000000000777dd7000777dd70077777d0077dd77007777d700777dd700777dd7000000000777777d007776670000000000777667000000000000000000000000
00000000007777000097777000077dd7000797700077dd9700097770000777700000000000777dd7000777900000000000077770000000000000000000000000
00000000009090000000090000009090000000090009000000000900009009000000000000009090000900000000000000900900000000000000000000000000
00000000088000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000417000000880000000000000088000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000087000074170000708800000417000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000777dd770877dd7747700007087000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077777d7077777d70877dd770777dd770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000777dd700777dd70077777d7077777d70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000777700007777000777dd700777dd700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000009090000090900000909000009090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000900000bbbb0000aaaa00000000000000000000000000
00000000000000000000000000000000000000000000000000000000055555550ddddddd07777777000090000b3b3bb00ababaa0000000000000000000000000
00000000000000000000000000000000000000000000000000000000055515550ddd2ddd07778777004449003333b3bbbbbbabaa000000000000000000000000
00000000000000000000000000000000000000000000000000000000055515550ddd2ddd0777877704444990333b3b3bbbbababa000000000000000000000000
000000000000000000000000000000000000000000000000000000000055555000ddddd00077777000999a00333333b3bbbbbbab000000000000000000000000
0000000000000000000000000000000000000000000000000000000000051500000d2d000007870000999a0033333b3bbbbbbaba000000000000000000000000
00000000000000000000000000000000000000000000000000000000000050000000d000000070000099aa00033333300bbbbbb0000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000009a0000033330000bbbb00000000000000000000000000
000000000000000000000000000000000000000000000a9099a00000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000a940499a0000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000aa940014a9a000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000a94400a0149a000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000aa94aaaa901499a00000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000aaaaa9a49400149a00000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000aa994944441000149a0000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000aaa99444411100000149a0000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000aaaa994941110000000000149a000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000aa9994944100000000000000014a000000000000000000000000000000000000000000000000000000000000000000000000
00aaaaaaa0000000000000000aaa9a44444100000000000000000144900000000000000000000000000000000000000000000000000000000000000000000000
099a999a9aaaaaaaaaaaaaaaa9a94941111000000000000000000019a00000000000000000000000000000000000000000000000000000000000000000000000
0449944949a999a99a99a994944911000000000000000000000000149a0000000000000000000000000000000000000000000000000000000000000000000000
011111444449494444949a44411000000000000000000000000000014aa000000000000000000000000000000000000000000000000000000000000000000000
0000001111111111144494a11000000000000000000000000000000014a900000000000000000000000000000000000000000000000000000000000000000000
0000000000000000011149aa00000000000000000000000000000000149aa0000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004999a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000014499aaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000144994a99a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000114944494000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000001111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
