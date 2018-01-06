pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
player = {}

function _init()
  mode=2
 
  player.x = 128/2
  player.y = 128/2
  player.w = 8
  player.h = 8
  player.frame = 1
  player.dx = 0
  player.dy = 0
  player.v = .08
  player.f = false
  player.t = 0
  player.aiming = false
  player.aimer = {}
  player.aimer.x = player.x + 4
  player.aimer.y = player.y + 4
  player.bullets = {}
  player.bullet_speed = 2
  player.max_speed = 1.5
  player.sprites = {37, 32, 33, 34, 35, 36}
  player.step = 5
  player.batteries = 0
  player.health=100
  player.max_health=100
  player.money=100
  player_inv = {
   {name="gas",total=98,cost=20},
   {name="food",total=1234,cost=2},
   {name="tires",total=0,cost=40}
  }
  
  car = {}
  car.x=70
  car.y=70
  car.w=32
  car.h=16
  car.sprs = {}
  car.sprs.top = {1,2,3,4}
  car.sprs.bot = {17,18,19,20}
  car.bump_timer=0  
  car.ant_sprs = {5,6,7,8,8,7,6,5}
  car.ant_frame = 1
  car.t=0
  car.ant_step=8
  car.dust = {}
  car.dust.colors = {13,6,7}
  car.dust.particles = {}
  car.health=45
  car.max_health=100
  car.driving_time = 0

  if mode == 0 then
    driving_init()
  elseif mode == 1 then
    player_sel_init()
  elseif mode == 2 then
    scavenge_init()
  end

end

function _update()
 
 if mode==0 then
   driving_update()
 elseif mode==1 then
   player_sel_update()
 elseif mode==2 then
 	 scavenge_update()
 end
end

function _draw()
  cls()
  if mode==0 then
    driving_draw()
  elseif mode==1 then
    player_sel_draw()
  elseif mode==2 then
    scavenge_draw()
  end
end



-->8
-- start with one player
-- add selectable players later
-- which can add modifiers to gameplay
-- make it so there are >1 players later?

function player_sel_init()

 store_money = 200
 index = 1
 index_y = 28
 store_inv = {
   {name="gas",total=10,cost=20},
   {name="food",total=100,cost=2},
   {name="tires",total=4,cost=40}
 }
end

function player_sel_update()
  if btnp(2) and index > 1 then
    index-=1
  elseif btnp(3) and index < #store_inv then
    index+=1
  end
  if btnp(5) then
    player.money,
    store_money,
    player_inv,
    store_inv = xchange_item(index,
    player.money,
    store_money,
    player_inv,
    store_inv)
  elseif btnp(4) then
    store_money,
    player.money,
    store_inv,
    player_inv = xchange_item(index,
    store_money,
    player.money,
    store_inv,
    player_inv)
  end
  --if index_y < 28 + (index-1*8)  then
  --  index_y+=1
  --end
end

function player_sel_draw()
  print("store inventory:", 10,10,7)
  for i=1,#store_inv do
    if i==index then
      rectfill(0,(i*10)+18,128,(i*10)+18+8,5)
    end
    print(store_inv[i].name,10,i*10+20,7)
    print("$"..store_inv[i].cost,30,i*10+20,7)
    print("stock:"..store_inv[i].total,50,i*10+20,7)

  end
  print("your inventory:",10,70,7)
  print("money: $"..player.money,10,80,7)

  for i=1,#player_inv do
    print(player_inv[i].name,10,i*10+80,7)
    print("stock:"..player_inv[i].total,50,i*10+80,7)

  end

  print("arrows + z/x",128-45,128-10,7)
end

function xchange_item(index,
				            	buyer_money,
				            	seller_money,
				            	buyer_inv,
				            	seller_inv)
  if buyer_money >= seller_inv[index].cost
     and seller_inv[index].total>=1 then
    buyer_money-=seller_inv[index].cost
    seller_money+=buyer_inv[index].cost
    buyer_inv[index].total+=1
    seller_inv[index].total-=1  
  end
  return buyer_money,
         seller_money,
         buyer_inv,
         seller_inv
end

-->8
function driving_init()
  plx_layers = {}
  stars = {}
  stars_colors = {7,6}
  driving = true

  next_checkpoint = 200
  car.total_distance = 4
  t=0
  create_plx_layer(0,60,16,1,-.25,64,2)  
  create_plx_layer(0,62,16,1,-.5,80,13)

  for i=0,flr(rnd(15)) do
    local star = {}
    star.x=rnd(128)
    star.y=rnd(65)
    star.r=1
    star.c=stars_colors[flr(rnd(#stars_colors))+1]
    add(stars,star)
  end
end

function driving_update()
  t+=0.01
  car.t=(car.t+1)%car.ant_step
  if (car.t==0) then
      car.ant_frame=(car.ant_frame+1)%#car.ant_sprs
  end
  if flr(t)%1==0 then
    create_dust_particles()
  end
  foreach(car.dust.particles, update_dust_particle)
  foreach(plx_layers,update_plx)
  if driving == true then
    car.driving_time+=1
    if car.driving_time%(30*1)==0 then
      car.health-=1
      next_checkpoint-=1
      car.total_distance+=1
      player_inv[1].total-=1
      player_inv[2].total-=10
    end
  end

end

function driving_draw()
  
  -- draw ground
  rectfill(0,67,128,128,1)
    
  for star in all(stars) do
   pset(star.x, star.y, star.c)
  end
  
  -- draw moon
  circfill(25,25,10,6)
  circfill(27,25,10,7)

  -- draw parralax scrollers
  foreach(plx_layers,draw_plx)

  rect(0,0,127,127,7)

  --
  draw_hud()

  pal(13,5)
  draw_car(true)
  pal()
end

function draw_hud()
  rectfill(0,89,128,128,7)
  rectfill(1,90,126,126,5)
  print("vehicle:", 5, 94, 6)
  draw_bar(car.health, car.max_health, 35, 6, 40, 93)
  print("health:", 5, 102, 6)
  draw_bar(player.health, player.max_health, 35, 6, 40, 93+8)

  print("gas: ",5,110,6)
  print(player_inv[1].total.."l",
        69-offset_x(player_inv[1].total),
        110, 6)
  print("food: ", 5, 118, 6)
  
  
  print(player_inv[2].total.."kg",
        65-offset_x(player_inv[2].total),
        118, 6)


  print("next chkpnt", 80, 94, 6)
  print(next_checkpoint.."km",
        115-offset_x(next_checkpoint), 102, 6)
  print("total: ", 80, 110, 6)
  print(car.total_distance.."km",
        115-offset_x(car.total_distance), 118, 6)

end

function draw_bar(val,max,len,height,x,y)
  local color = 3
  --background of bar
  rectfill(x, y, x+len, y+height,6)
  -- progress bar
  local progress = (val / max) * len
  if val / max <= .5 then
    color = 9
  elseif val / max <= .25 then
    color = 8
  end
  rectfill(x+1, y+1, x+progress-1, y+height-1, color)
end

function offset_x(number)
  -- calc modx to move score according to # of digits
  local digits=number
  local modx=0
  while flr(digits/10) > 0 do
    modx+=4
    digits=flr(digits/10)
  end
  return modx
end

function draw_car(moving)
  for i=1,#car.sprs.top do
    spr(car.sprs.top[i],
        car.x+(8*i),
        car.y-(sin(t%100)))
  end
  for i=1,#car.sprs.bot do
    spr(car.sprs.bot[i],
        car.x+(8*i),
        car.y+8-(sin(t%100)))
  end
  for i=1,6 do
    if moving then
    		circfill(car.x+10+4*i,
      		       car.y+11-(sin(t%100))+sin(.5-i/5+t*10)/2,1,7)
    else
    		circfill(car.x+10+4*i,
      		       car.y+11,1,7)
    end
  end 
  -- draw antenna
  spr(car.ant_sprs[car.ant_frame+1],
      car.x+28,
      car.y-4-(sin(t%100)))

  -- draw trailing dust
  if moving then
    foreach(car.dust.particles,
            draw_dust_particle)
  end
end

function create_plx_layer(x,y,w,h,spd,sp,c)
  local layer = {}
  layer.x=x
  layer.y=y
  layer.w=w
  layer.h=h
  layer.spd=spd
  layer.sp=sp
  layer.c=c
  add(plx_layers,layer)
end

function update_plx(plx_layer)
  plx_layer.x-=plx_layer.spd
  if plx_layer.x>=plx_layer.w*8 then
    plx_layer.x=-plx_layer.w*8
  end
end

function draw_plx(plx_layer)
  pal(13,plx_layer.c)
  spr(plx_layer.sp,
      plx_layer.x,
      plx_layer.y,
      plx_layer.w,
      plx_layer.h)
  spr(plx_layer.sp,
      plx_layer.x-8*plx_layer.w,
      plx_layer.y,
      plx_layer.w,
      plx_layer.h)
  spr(plx_layer.sp,
      plx_layer.x+8*plx_layer.w,
      plx_layer.y,
      plx_layer.w,
      plx_layer.h)
  pal()
end

function create_dust_particles()
  for i=1,rnd(flr(5)) do
    local part = {}
    part.x=car.x+rnd(10)+15
    part.y=car.y+15
    part.c=car.dust.colors[flr(rnd(#car.dust.colors))+1]
    part.r=rnd(2)
    part.dx=rnd(4)
    part.dy=-(rnd(2))
    part.t=0
    add(car.dust.particles, part)
  end
end

function update_dust_particle(part)
  part.x+=part.dx
  part.y+=part.dy
  part.t+=1
  if part.dx > 0 then
    part.dx+=.1
  end
  if part.dy < 0 then
    part.dy+=.1
  end
  if part.t%30==0 then
    part.r-=1
  end
  if part.r<0 then
    del(car.dust.particles, part)
  end
end

function draw_dust_particle(part)
  circfill(part.x,part.y,
           part.r,part.c)
end
-->8
-- scavenging stage

function scavenge_init()
  plx_layers = {}
  create_plx_layer(0,34,16,1,0,64,2)  

  enemy_speed = .5
  power = 50 
  car.x = 20
  car.y = 80

  enemies = {}
  screen_xwidth = 300
  player.x = 128/2
  player.y = 128/2
  cam = {}
  cam.x = 0
  power = 50
  cam.speed = .5
  cam.dx = 0
  batteries = {
  }
  rocks = {}
  rock_sprite = 9
  create_rocks()
  create_enemy()
	t=0

end

function scavenge_update()
  t+=1

  car.t=(car.t+1)%car.ant_step
  if (car.t==0) then
      car.ant_frame=(car.ant_frame+1)%#car.ant_sprs
  end

  if t%30==0 then power-=1 end
  player_update()
  update_enemies()
  if player.x>60 and player.x < screen_xwidth then
    cam.x=player.x-60
  end

  camera(cam.x,0)

end

function scavenge_draw()

  cls()
  --palt(0, false)
  rectfill(cam.x,0,cam.x+128,128,1)
  rectfill(cam.x,0,cam.x+128,40,0)
  circfill(cam.x+20+1,20,9,6)
  circfill(cam.x+20+0,20,9,6)
  circfill(cam.x+20,20,8,7)

  -- draw parralax scrollers
  plx_layers[1].x=cam.x
  foreach(plx_layers,draw_plx)
  
  --spr(spaceship.s,
  --      spaceship.x,
  --      spaceship.y,
  --      spaceship.w/8,
  --      spaceship.h/8)
  draw_car(false)
  
  for rock in all(rocks) do
    spr(rock_sprite, rock.x, rock.y)
  end
  draw_player()
  draw_enemies()
  draw_scavenge_ui()

end

function player_update()
  player.aimer.x = player.x+4
  player.aimer.y = player.y+4
  if btn(0) then 
    player.dx-=player.v
    player.f = true
  end
  if btn(1) then
    player.dx+=player.v
    player.f = false
  end
  if btn(2) then player.dy-=player.v end
  if btn(3) then player.dy+=player.v end
  if btn(4) then 
    -- enter fire phase
    player.aiming = true
  end
  if not btn(0) and not btn(1) then
    if player.dx < 0 then
      player.dx += player.v
    else
      player.dx -= player.v
    end
    if abs(player.dx) < 1 then
      player.dx = 0
    end
  end
  if not btn(2) and not btn(3) then
    if player.dy < 0 then
      player.dy += player.v
    else
      player.dy -= player.v
    end
    if abs(player.dy) < 1 then
      player.dy = 0
    end
  end
  if player.aiming then
    player.dx=0
    player.dy=0
    if btn(0) then 
      player.aimer.x=player.x+4-15
      player.f = true
    end
    if btn(1) then
      player.aimer.x=player.x+4+15
      player.f = false
    end
    if btn(2) then player.aimer.y=player.y+4-15 end
    if btn(3) then player.aimer.y=player.y+4+15 end
    if not btn(4) then
      -- fire!!!!!
      player_fire(btn(0), btn(1), btn(2), btn(3))
      player.aiming = false
    end
  end
  for bullet in all(player.bullets) do
    bullet.x += bullet.dx
    bullet.y += bullet.dy
    for enemy in all(enemies) do
      if check_collision(enemy, bullet) then
        del(player.bullets, bullet)
        del(enemies, enemy)
        create_enemy()
      end
    end
    for rock in all(rocks) do
      if check_collision(bullet, rock) then
        del(player.bullets, bullet)
      end
    end
  end
  for rock in all(rocks) do
    if check_collision({x=player.x+player.dx,
                        y=player.y+player.dy,
                        h=player.h, w=player.w}, rock) then
      player.dx=0
      player.dy=0
    end
  end
  if check_collision(player, car) then
    power += player.batteries*10
    if power > 100 then power = 100 end
    player.batteries = 0

  end
  if abs(player.dx) > player.max_speed then
    if player.dx < 0 then 
      player.dx = -player.max_speed
    else
      player.dx = player.max_speed
    end
  end
  if abs(player.dy) > player.max_speed then
    if player.dy < 0 then 
      player.dy = -player.max_speed
    else
      player.dy = player.max_speed
    end
  end
  if player.dx != 0 or player.dy != 0 then
    player.t=(player.t+1)%player.step
    if (player.t==0) then
      player.frame=(player.frame+1)%#player.sprites
    end
  else
    player.frame=0
  end
  for battery in all(batteries) do
    if player.batteries <=2 then
      if check_collision(player, battery) then
        del(batteries, battery)
        player.batteries+=1
      end
    end
  end
  if player.x>screen_xwidth+60 then
    player.x=screen_xwidth+60
  end
  player.x+=player.dx

  if player.y+player.dy > 32 and player.y+player.dy < 120 then
    player.y+=player.dy
  end
end

function create_rocks()
  for i=0,8 do
    rock = {}
    rock.y=rnd(128-32)+36
    rock.x=50+rnd(screen_xwidth - 50)
    rock.w=8
    rock.h=8
    while check_collision(rock, player) do
      rock.y=rnd(128-32)+32
      rock.x=50+rnd(screen_xwidth - 50)
    end
    for battery in all(batteries) do
      while check_collision(rock, battery) do
        rock.y=rnd(128-32)+32
        rock.x=50+rnd(screen_xwidth - 50)
      end
    end
    add(rocks, rock)
  end
end

function create_enemy()
  enemy = {}
  enemy.t=0
  enemy.x=100+rnd(200)
  enemy.y=150
  enemy.w=8
  enemy.h=8
  enemy.dx=0
  enemy.dy=0
  enemy.speed=enemy_speed
  enemy.shadows = {}
  if rnd(1) < .5 then
    enemy.y *= -1
  end
  add(enemies, enemy)
end

function update_enemies()
  for enemy in all(enemies) do
    enemy.t+=1
    -- enemy movement direction
    if enemy.x < player.x then
      enemy.dx=enemy.speed
    elseif abs(enemy.x - player.x) < 5 then
      enemy.dx=0
    else
      enemy.dx=-enemy.speed
    end
    if enemy.y < player.y then
      enemy.dy=enemy.speed
    elseif abs(enemy.y - player.y) < 5 then
      enemy.dy=0
    else
      enemy.dy=-enemy.speed
    end

    -- enemy can't go through rocks either
    for rock in all(rocks) do
      if check_collision(enemy, rock) then
        enemy.dx*=.5
        enemy.dy*=.5
      end
    end
    enemy.x+=enemy.dx
    enemy.y+=enemy.dy
    if check_collision(enemy, player) then
      del(enemies, enemy)
      create_enemy()
      -- steal energy or something?
      power -= 10
    end
  end
  if enemy.t % 2 == 0 then
    local shadow = {
      x=enemy.x,
      y=enemy.y,
      t=0
    }
    add(enemy.shadows, shadow)
  end

  for shadow in all(enemy.shadows) do
    shadow.t+=1
    if shadow.t > 20 then
      del(enemy.shadows, shadow)
    end
  end
end

function draw_enemies()
  for enemy in all(enemies) do
    pal(2,14)
    pal(7,14)
    --palt(8,true)
    for shadow in all(enemy.shadows) do
      --spr(48, shadow.x, shadow.y, 1, 1, enemy.dx < 0, false)
      -- 'dusty shadows'
      for x1=shadow.x,shadow.x+6 do
        for y1=shadow.y,shadow.y+6 do
          if flr(rnd(20)) == 1 then
            pset(x1,y1,14)
          end
        end
      end
    end
    --palt()
    for i=-1,1 do
      for j=-1,1 do
        spr(48, enemy.x+i, enemy.y+j, 1,1, enemy.dx < 0, false)
      end
    end
    pal()
    spr(48, enemy.x, enemy.y, 1,1, enemy.dx < 0, false)
  end
end

function draw_player()
  if player.aiming then
    circ(player.aimer.x, player.aimer.y, 2, 7)
    line(player.x+4, player.y+4, player.aimer.x, player.aimer.y, 7)
  end
  spr(player.sprites[player.frame+1],
  		player.x,
  		player.y,
  		1,1,
  		player.f,
  		false)
  -- draw bullets
  for bullet in all(player.bullets) do
    circfill(bullet.x, bullet.y, 1, 7)
  end
end

function player_fire(left, right, up, down)
  local bullet = {}
  bullet.x = player.x+4
  bullet.y = player.y+4
  bullet.w = 4
  bullet.h = 4
  bullet.dx = 0
  bullet.dy = 0
  if left then
    bullet.dx=-player.bullet_speed
  elseif right then
    bullet.dx=player.bullet_speed
  end
  if up then
    bullet.dy=-player.bullet_speed
  elseif down then
    bullet.dy=player.bullet_speed
  end
  if bullet.dx != 0 or bullet.dy != 0 then
    add(player.bullets, bullet)
  end
end

function check_collision(thing1, thing2)
  if thing1.x < thing2.x+thing2.w and
     thing1.x+thing1.w > thing2.x and
     thing1.y+thing1.h > thing2.y and
     thing1.y < thing2.y+thing2.h and
     thing1.y+thing1.h > thing2.y then
     
    return true
  end
  return false
end

function create_batteries()
  for i=0,1+flr(rnd(2)) do
    local battery = {}
    battery.x = 128+rnd(screen_xwidth-128)
    battery.y = 40+rnd(88)
    battery.w = 8
    battery.h = 8
    battery.s = 10
    while check_collision(battery, rock) do
      battery.x = 128+ rnd(screen_xwidth)
      battery.y = 40+rnd(78)
    end
    add(batteries, battery)
  end
end

function draw_scavenge_ui()
  print(power.."%", cam.x+17, 0, 7)
  pal(5,7)
  spr(10,cam.x+100, 0)
  spr(10,cam.x+99, -1)
  spr(10,cam.x+99, 0)
  spr(10,cam.x+99, 1)
  spr(10,cam.x+100, -1)
  spr(10,cam.x+100, 0)
  spr(10,cam.x+100, 1)
  spr(10,cam.x+101, -1)
  spr(10,cam.x+101, 0)
  spr(10,cam.x+101, 1)
  pal()
  pal(5,0)
  spr(10,cam.x+100, 0)


  pal(5,7)
  spr(10,cam.x+110, 0)
  spr(10,cam.x+109, -1)
  spr(10,cam.x+109, 0)
  spr(10,cam.x+109, 1)
  spr(10,cam.x+110, -1)
  spr(10,cam.x+110, 0)
  spr(10,cam.x+110, 1)
  spr(10,cam.x+111, -1)
  spr(10,cam.x+111, 0)
  spr(10,cam.x+111, 1)
  pal()
  pal(5,0)
  spr(10,cam.x+110, 0)

  pal(5,7)
  spr(10,cam.x+120, 0)
  spr(10,cam.x+119, -1)
  spr(10,cam.x+119, 0)
  spr(10,cam.x+119, 1)
  spr(10,cam.x+120, -1)
  spr(10,cam.x+120, 0)
  spr(10,cam.x+120, 1)
  spr(10,cam.x+121, -1)
  spr(10,cam.x+121, 0)
  spr(10,cam.x+121, 1)
  pal()
  pal(5,0)
  spr(10,cam.x+120, 0)


  pal()
  if player.batteries > 0 then
    for i=1,player.batteries do
      spr(10,cam.x+90+(i*10), 0)
    end
  end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000eeee0005005000000000000000000000000000000000000000000
00700700000000000000000000000000000000000070000007770000077770000777770000e25225055555500000000000000000000000000000000000000000
0007700000000006666666666666666660000000007600000766700007666700766666700ee22522055555500000000000000000000000000000000000000000
000770000000006555555565555555555600000000076000007657000766567076656670ee222225055555500000000000000000000000000000000000000000
007007000000065577777565777557775560000000077600000766700076667076666670ee222ed2055555500000000000000000000000000000000000000000
000000000000655577777565777557775556000000000770000077700007777007777700ee22ed2d055555500000000000000000000000000000000000000000
000000000006555555555565555555555555600000000000000000000000000000000000e2eedd52055555500000000000000000000000000000000000000000
00000000000666666666666666666666666660000000000000000000000000000000000760000000000000000000000000000000000000000000000000000000
00000000000555555555555555555555555550000000000000000000000000000000007766000000000000000000000000000000000000000000000000000000
00000000000055555555555555555555555500000000000000000000000000000000077666600000000000000000000000000000000000000000000000000000
00000000000005555555555555555555555000000000000000000000000000000000776666660000000000000000000000000000000000000000000000000000
00000000000000555555555555555555550000000000000000000000000000000000766765750000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000767675570000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000766657550000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000766665750000000000000000000000000000000000000000000000000000
0000000000dddd0000dddd00000000000000000000dddd0000000000000000000000766666660000000000000000000000000000000000000000000000000000
00dddd000dd777700dddddd000dddd0000dddd000dddddd000000000000000000000766666660000000000000000000000000000000000000000000000000000
0dddddd00dddddd00dd777700dddddd00dddddd00dd7777000000000000000000000766666660000000000000000000000000000000000000000000000000000
0dd77770dddddddd0dddddd00dd777700dd777700dddddd00000000000000000000c666666661000000000000000000000000000000000000000000000000000
0dddddd00dddddd0dddddddddddddddddddddddddddddddd0000000000000000000c666666661000000000000000000000000000000000000000000000000000
dddddddd0ddddddd0dddddd00dddddd00dddddd00dddddd0000000000000000000c1666666661100000000000000000000000000000000000000000000000000
0dddddd00d0000000dddddd00dddddd00dddddd00dddddd0000000000000000000c1055555501100000000000000000000000000000000000000000000000000
d0000000000000000000000d000000d00d0000d00d0000d000000000000000000c11005555001110000000000000000000000000000000000000000000000000
00222200002222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02222220022222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02277770022777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02222220022222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02222220022222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02222220022222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02020200202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000ddd00000000000000000000000000000000000000000000000d000000000000000000000000000000000000000000000000000000ddd00000000000
00000dddddddd00000000000000dd000000000dd0000000000000000000dd00000000000000d000000000dddd0000000000000000000000000dddd0000000000
0000dddddddddd00000000000ddddd0000000ddd00000000000dd000000dddd00000000000dd00000000ddddddd0000000000000000dd0000dddddd000000000
0ddddddddddddd00000000ddddddddd000000ddd000000dd00dddddd00dddddd000000dd0dddd0dd0ddddddddddd0dd0000000dd00dddddd0ddddddd000000d0
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000d0000dd00000000000000000000dd0000000000000000d000000000000000000000000000000000dd00000000000000000000000000
00dd0000000000000000dd0000ddd0000d00000000dd0000dd000d000000000000dd000000000000000d000000d000d00000dd00000000000000dd0d00000000
0ddd0000000dd000000ddd0000dddd000d00000000dd0000dd00dd000000dd0000ddd0dd00000d0000ddd0000dd000d00d00dd000000d000000ddd0d000d0000
0ddd000000dddd000000000000d00000000dd000000d0000000dd0000000d00000d0d00000000d000dd0dd000dd000000d00dd00000ddd00000ddd0d00dd0000
