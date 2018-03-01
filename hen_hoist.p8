pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
gravity = 0.2
x_speed = 0.5
player = {x=64,
          y=64,
          sprites={
            jumping={step=4,
                     sprites={1,2,3,4}},
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
          dy=0,dx=0}
feather_fx = {}
cam={x=0,y=0}
platforms = {{x=5,y=30,bounce=false},
             {x=50,y=50,bounce=true},
             {x=90,y=80,bounce=false}}
tree_seg_height=2
tree = {}

function _init()
  add(tree, {x=rnd(20),y=128})
  printh("#tree "..#tree.." tree[#tree].y:"..tree[#tree].y)
  for i=1,256*tree_seg_height do
    add(tree, {x=30+rnd(20),y=tree[#tree].y-tree_seg_height})
  end
end

-- if player is within a certain threshold of last platform,
-- create more platforms
-- clean up old platforms
-- player dies if falls too far?


function _update()
  --animate(player)
  update_player()
  update_platforms()
  update_feather_fx()
  if player.y<90 then
    cam.y=player.y-84
  end
  camera(cam.x,cam.y)
  more_platforms()
  update_tree()
end

function _draw()
  cls()
  -- background
  rectfill(cam.x,cam.y,cam.x+128,cam.y+128,12)
  circfill(cam.x+110,cam.y+10,11,7)
  circfill(cam.x+110,cam.y+10,10,10)
  draw_tree()
  animate(player)
  draw_feather_fx()
  draw_platforms()
  outline_spr(player.sprites[player.state].sprites[player.frame+1],
      player.x,
      player.y,
      1,1,player.flipx)
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
  if btn(4) and player.state != "jumping" then
    player.dy-=10
    player.state="jumping"
    player.frame=0
  end
  if btn(0) then
    player.dx-=x_speed
    player.flipx=false

  elseif btn(1) then
    player.dx+=x_speed
    player.flipx=true
  end

  --animate(player)

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
  end

  -- check if hit platform
  for platform in all(platforms) do
    if abs((player.y+8+player.dy)-(platform.y))<2 and
       player.x>platform.x-4 and
       player.x<platform.x+20+4 then
      if platform.bounce then
        player.dy-=10
      else
        player.y=platform.y-8
        player.dy=0
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

  if player.state=="jumping" and player.dy>0 then
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

function outline_spr(sprite, x, y, w, h, flip_x)
  for i=1,15 do
    pal(i,1)
  end
  for i=-1,1 do
    for j=-1,1 do
      spr(sprite, x+i, y+j, w, h, flip_x)
    end
  end
  pal()
  spr(sprite, x, y, w, h, flip_x)
end

function draw_platforms()
  outline = 1
  for platform in all(platforms) do
    if platform.bounce then color = 11 else color = 3 end
    line(platform.x,platform.y-1,platform.x+20,platform.y-1,outline)

    line(platform.x,platform.y,platform.x+20,platform.y,color)
    line(platform.x+3,platform.y+1,platform.x+17,platform.y+1,color)
    line(platform.x+5,platform.y+2,platform.x+15,platform.y+2,color)
    
    --bottom
    line(platform.x+5,platform.y+2,platform.x+15,platform.y+2,outline)

    --corners
    line(platform.x+5,platform.y+2,platform.x-1,platform.y-1,outline)
    line(platform.x+15,platform.y+2,platform.x+21,platform.y-1,outline)
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
  printh("MORE TREE "..tree[1].y.." player.y:"..player.y)

  if abs(tree[#tree].y) - abs(player.y) < 128*tree_seg_height then
    del(tree, tree[1])
    add(tree, {x=30+rnd(20),y=tree[#tree].y-tree_seg_height})
  end
end

function update_platforms()
  for platform in all(platforms) do
  end
end

function obj_on_screen(obj)
  if obj.y > cam.y and obj.y < cam.y+128 then 
    return true
  else
    return false end
end

function more_platforms()
  if abs(platforms[#platforms].y) - abs(player.y) < 200 then
    printh("MORE PLATFORMS "..platforms[#platforms].y.." playery:"..player.y)
    for i=1,10 do
      local platform = {}
      platform.x=rnd(120)
      if platform.x<20 then platform.x+=20 end
      if platform.x>80 then platform.x-=30 end
      platform.y=platforms[#platforms].y-(i*5)
      platform.bounce=flr(rnd(2))==0
      add(platforms,platform)
    end
  end
end

__gfx__
00000000088000000000000008800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000004170000008800d004170000008800d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700087000074170d7d008700d074170d7d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000777dd77087777d70777d7d7087777d70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000077777d707777d77077777d707777d770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000777dd700777d7700777dd700777d7700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000007777000077770000777700007777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000009090000090900000909000009090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
