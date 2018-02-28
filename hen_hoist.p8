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
                     sprites={18,19,20,21}},
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
platforms = {}
pal(6,13)

function _init()
  for i=1,10 do
    local platform = {}
    platform.x=rnd(80)+rnd(40)
    platform.y=rnd(20)-(i*30)+128
    platform.bounce=flr(rnd(2))==0
    add(platforms,platform)
  end
end

function _update()
  --animate(player)
  update_player()
  update_platforms()
  update_feather_fx()
  if player.y<90 then
    cam.y=player.y-84
  end
  camera(cam.x,cam.y)
end

function _draw()
  cls()
  -- background
  rectfill(cam.x,cam.y,cam.x+128,cam.y+128,12)
  animate(player)
  draw_feather_fx()
  draw_platforms()
  outline_spr(player.sprites[player.state].sprites[player.frame+1],
      player.x,
      player.y,
      1,1,player.flipx)
  --pset(player.x,player.y,8)
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
    printh("JUMP GO")
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
        printh("HIT PLATFORM")
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

  printh("playerstate:"..player.state.." playerx:"..player.x.." playery:"..player.y.." playerdy: "..player.dy)
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
  for platform in all(platforms) do
    if platform.bounce then color = 2 else color = 1 end
    line(platform.x,platform.y,platform.x+20,platform.y,color)
    line(platform.x+3,platform.y+1,platform.x+17,platform.y+1,color)
    line(platform.x+5,platform.y+1,platform.x+15,platform.y+2,color)
  end
end

function update_platforms()
  for platform in all(platforms) do
    printh("x:"..platform.x.." y:"..platform.y)
  end
end

__gfx__
00000000088000000000000008800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000417000000880060041700000088006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700087000074170676008700607417067600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000077766770877776707776767087777670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000077777670777767707777767077776770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700077766700777677007776670077767700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000007777000077770000777700007777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000009090000090900000909000009090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000088000000008800000880000088000000088000008800000000000000000000000000000000000000000000000000000000000000000000000000000
00000000417000000041700004170000417000000417000041700000000000000000000000000000000000000000000000000000000000000000000000000000
00000000087000700008700700870000087000070087000708700007000000000000000000000000000000000000000000000000000000000000000000000000
00000000077766700007766700770007007766770077766700777667000000000000000000000000000000000000000000000000000000000000000000000000
00000000077777600077777607777667007777670077777600777776000000000000000000000000000000000000000000000000000000000000000000000000
00000000077766700077766707777776000766770077766700777667000000000000000000000000000000000000000000000000000000000000000000000000
00000000007777000007777000777667000797700007779000077770000000000000000000000000000000000000000000000000000000000000000000000000
00000000009090000090090000009090000000090009000000900900000000000000000000000000000000000000000000000000000000000000000000000000
00000000088000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000417000000880000000000000088000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000087000074170000708800000417000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077766770877667747700007087000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077777670777776708776677077766770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077766700777667007777767077777670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000007777000077770007776670077766700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000009090000090900000909000009090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
