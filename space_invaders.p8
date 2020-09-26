pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

left,right,up,down,fire1,fire2=0,1,2,3,4,5
black,dark_blue,dark_purple,dark_green,brown,dark_gray,light_gray,white,red,orange,yellow,green,blue,indigo,pink,peach=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

PLAYER_SHOT_COOLDOWN = 10
ENEMY_DX = 0.1
ENEMY_ACCEL = 0.1

function update_enemy_group(enemies)
    switch_position = false
    for enemy in all(enemies) do
        if (enemy.x>=128-8 or enemy.x<0) then
            switch_position = true
        end
    end
    if (switch_position) then
        for enemy in all(enemies) do
            if enemy.dx > 0 then enemy.dx += ENEMY_ACCEL else enemy.dx -= ENEMY_ACCEL end
            enemy.dx*=-1
            enemy.y+=4
        end
    end
end

function update_enemy(enemy)
    enemy.x+=enemy.dx
end

function draw_enemy(enemy)
    spr(1,enemy.x,enemy.y)
end

function player_shoot(player)
    player.shot_timer=PLAYER_SHOT_COOLDOWN
    return {
        x=player.x,
        y=player.y-2,
        dx=0,
        dy=-2
    }
end

function update_player(player)
    -- shot cooldown
    if (player.shot_timer<=0) then
        player.shot_timer=0
    else
        player.shot_timer-=1
    end
    -- movement
    if (btn(left)) then player.x-=1 end
    if (btn(right)) then player.x+=1 end

    -- shooting logic
    -- only shoot if they pressed the button
    -- and the shot cooldown is up
    -- and there are less than 2 shots on the board
    if (
        btnp(fire1) and
        player.shot_timer<=0 and
        #player.shots<=1
    ) then
        add(player.shots, player_shoot(player))
    end

    -- update shot positions
    for shot in all(player.shots) do
        shot.x+=shot.dx
        shot.y+=shot.dy
    end

    -- get rid of shots that are out of bounds
    for shot in all(player.shots) do
        if shot.y<0 then del(player.shots, shot) end
    end
end

function draw_player(player)
    circfill(player.x,player.y,player.r,pink)

    for shot in all(player.shots) do
        circfill(shot.x,shot.y,1,green)
    end
end

function _init()
    player = {
        x=124/2,
        y=124,
        r=2,
        shots={},
        update_fn=update_player,
        draw_fn=draw_player,
        shot_timer=0
    }
    things = {player}
    enemies = {
        {x=0, y=0, dx=ENEMY_DX, dy=0, update_fn=update_enemy, draw_fn=draw_enemy},
        {x=20, y=0, dx=ENEMY_DX, dy=0, update_fn=update_enemy, draw_fn=draw_enemy},
        {x=30, y=0, dx=ENEMY_DX, dy=0, update_fn=update_enemy, draw_fn=draw_enemy},
        {x=10, y=0, dx=ENEMY_DX, dy=0, update_fn=update_enemy, draw_fn=draw_enemy},
        {x=40, y=0, dx=ENEMY_DX, dy=0, update_fn=update_enemy, draw_fn=draw_enemy},
        {x=50, y=0, dx=ENEMY_DX, dy=0, update_fn=update_enemy, draw_fn=draw_enemy},
        {x=60, y=0, dx=ENEMY_DX, dy=0, update_fn=update_enemy, draw_fn=draw_enemy},
        {x=70, y=0, dx=ENEMY_DX, dy=0, update_fn=update_enemy, draw_fn=draw_enemy},
        {x=80, y=0, dx=ENEMY_DX, dy=0, update_fn=update_enemy, draw_fn=draw_enemy}
    }
    for enemy in all(enemies) do
        add(things, enemy)
    end
end

function _update()
    update_enemy_group(enemies)
    for thing in all(things) do
        thing.update_fn(thing)
    end
end

function _draw()

    cls(dark_blue)
    print(player.x,0,0,pink)
    print(player.y,0,10,pink)
    print(player.shot_timer,0,20,pink)
    for thing in all(things) do
        thing.draw_fn(thing)
    end
end
__gfx__
0000000000000000000000000000000000000000000bb000000bb000000000000000000000000000000000000000000000000000000000000000000000000000
000000000b0000b00b0000b00bbbbbb00bbbbbb000bbbb0000bbbb00000000000000000000000000000000000000000000000000000000000000000000000000
0070070000b00b0000b00b00bbbbbbbbbbbbbbbb0bbbbbb00bbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000
000770000bbbbbb00bbbbbb0bb0bb0bbbb0bb0bbbb0bb0bbbb0bb0bb000000000000000000000000000000000000000000000000000000000000000000000000
000770000b0bb0b00b0bb0b0bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000
007007000bbbbbb0bbbbbbbb0b0bb0b000bbbb000b0bb0b000b00b00000000000000000000000000000000000000000000000000000000000000000000000000
00000000bb0000bb0b0000b0b000000b0b0000b0b000000b0b0bb0b0000000000000000000000000000000000000000000000000000000000000000000000000
00000000b0b00b0bb000000b0bb00bb0b000000b0b0000b0b0b00b0b000000000000000000000000000000000000000000000000000000000000000000000000
