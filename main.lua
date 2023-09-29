local Bezier_pos = {0,0,1,1} --控制点坐标
local moing = false --按下状态
local moingpos = 0
local ctrl = false
local time = 0
local time2 = 0 --动画
local copy = false
function getBezier1(startTime, endTime, startValue, endValue, bezierTable,nowtime)
    -- 计算时间点在时间范围内的百分比
    local timePercent = (nowtime - startTime) / (endTime - startTime)
    
    -- 限制时间范围在0到1之间
    timePercent = math.max(0, math.min(1, timePercent))
    
    -- 计算贝塞尔曲线的插值点
    local p0 = {0, 0}  -- 起点
    local p1 = {bezierTable[1], bezierTable[2]}  -- 控制点1
    local p2 = {bezierTable[3], bezierTable[4]}  -- 控制点2
    local p3 = {1, 1}  -- 终点
    local weight = 3
    local t = timePercent
    local u = 1 - t
    local tt = t * t
    local uu = u * u
    local uuu = uu * u
    local ttt = tt * t
    
    local x = uuu * p0[1] + weight * uu * t * p1[1] + weight * u * tt * p2[1] + ttt * p3[1]
    local y = uuu * p0[2] + weight * uu * t * p1[2] + weight * u * tt * p2[2] + ttt * p3[2]
    -- 根据插值点计算数值
    local value = startValue + (endValue - startValue) * y
    
    return value
end

function getBezier(startTime, endTime, startValue, endValue, bezierTable,nowtime,tr)
    -- 计算时间点在时间范围内的百分比
    local timePercent = (nowtime - startTime) / (endTime - startTime)
    
    -- 限制时间范围在0到1之间
   -- timePercent = math.max(0, math.min(1, timePerce nt))

    local p0 = {0, 0}  -- 起点
    local p1 = {bezierTable[1], bezierTable[2]}  -- 控制点1
    local p2 = {bezierTable[3], bezierTable[4]}  -- 控制点2
    local p3 = {1, 1}  -- 终点

    -- 线1 先算出线性方程 然后求点坐标
  --  local line1 = math.sqrt((p1[1] - p0[1]) * (p1[1] - p0[1]) + (p1[2] - p0[2]) * (p1[2] - p0[2])) --线长度 1
    local line1_now = {((p1[1] - p0[1]) * timePercent) + p0[1],((p1[2] - p0[2]) * timePercent) + p0[2]} --现在点位置

   
    local line2_now = {((p2[1] - p1[1]) * timePercent) + p1[1],((p2[2] - p1[2]) * timePercent) + p1[2]} --现在点位置 动点1


    local line3_now = {((p3[1] - p2[1]) * timePercent) + p2[1],((p3[2] - p2[2]) * timePercent) + p2[2]} --现在点位置 动点2 


    local line21_now = {((line2_now[1] - line1_now[1]) * timePercent) + line1_now[1],((line2_now[2] - line1_now[2]) * timePercent) + line1_now[2]}

    local line22_now = {((line3_now[1] - line2_now[1]) * timePercent) + line2_now[1],((line3_now[2] - line2_now[2]) * timePercent) + line2_now[2]}

    local line31_now = {((line22_now[1] - line21_now[1]) * timePercent) + line21_now[1],((line22_now[2] - line21_now[2]) * timePercent) + line21_now[2]}
    --当时间t作为kx的时候 推出ky
    local value,v2 = startValue + (endValue - startValue) * line31_now[1],startValue + (endValue - startValue) * line31_now[2]
    local ky = 0

    --二分求解 
    local accuracy = 0.005
    --精度
    local lf = 0
    local rl = 1
    local mid = 0

    while rl - lf > accuracy do --精度之外
        local t = mid
        local u = 1 - t
        local tt = t * t
        local uu = u * u
        local uuu = uu * u
        local ttt = tt * t
        mid = (lf + rl) / 2
        mid_x = uuu * p0[1] + 3 * uu * t * p1[1] + 3 * u * tt * p2[1] + ttt * p3[1]
        if mid_x > timePercent then
            rl = rl - accuracy
        end
        if mid_x == timePercent then
           break
        end
        if mid_x < timePercent then
           lf = lf + accuracy
        end
    end

    local t = mid
    local u = 1 - t
    local tt = t * t
    local uu = u * u
    local uuu = uu * u
    local ttt = tt * t
    
    -- 根据插值点计算数值
    local ky = startValue + (endValue - startValue) * (uuu * p0[2] + 3 * uu * t * p1[2] + 3 * u * tt * p2[2] + ttt * p3[2])
   
   
    if tr then
        return 1,line1_now,line2_now,line3_now,line21_now,line22_now,line31_now
    else --通过kx 求ky 
        return value,v2,ky
    end
end

function getBezier_recursive(startTime, endTime, startValue, endValue, bezierTable, nowt ,all,tue_l,bezierTable4)
    if #bezierTable % 2 == 0 and nowt then --正确数组
        local bezierTable2 = {}   
        local timePercent = ( nowt - startTime) / (endTime - startTime)
        --储存表t4

        if all == true then --未递归状态

            table.insert(bezierTable,1,0)
            table.insert(bezierTable,1,0)
            table.insert(bezierTable,#bezierTable,1)
            table.insert(bezierTable,#bezierTable,1)

        end
        local bezierTable3 = {}
        for i = 2,#bezierTable ,2 do
             bezierTable3[i / 2] = {bezierTable[i - 1],bezierTable[i]}
        end


        if #bezierTable / 2 == 1 then --求出结果
        if tue_l == true then
           return bezierTable[2] --返回y
        else
            --当时间t作为kx的时候 推出ky
          local value,v2 = startValue + (endValue - startValue) * bezierTable[1],startValue + (endValue - startValue) * bezierTable[2]
          local ky = 0

          --二分求解 
          local accuracy = 0.005
          --精度
          local lf = 0
          local rl = 1
          local mid = 0

          while rl - lf > accuracy do --精度之外

              mid = (lf + rl) / 2
              mid_x = getBezier_recursive(startTime, endTime, startValue, endValue, bezierTable4,mid,true,true,bezierTable4)
              if mid_x > timePercent then
                  rl = rl - accuracy
              end
              if mid_x == timePercent then
                 break
              end
              if mid_x < timePercent then
                  lf = lf + accuracy
              end
          end
    
          -- 根据插值点计算数值
       --   local ky = startValue + (endValue - startValue) * getBezier_recursive(startTime, endTime, startValue, endValue, bezierTable4,mid_x,true,"true_?",bezierTable4)
          return value,v2,(startValue + (endValue - startValue) * getBezier_recursive(startTime, endTime, startValue, endValue, bezierTable4,mid,true,true,bezierTable4))
           
        end
        end

        for i = 1 ,(#bezierTable / 2) - 1 do --递归
           bezierTable2[#bezierTable2] = ((bezierTable3[i + 1][1] - bezierTable3[i][1]) * timePercent) + bezierTable3[i][1]
           bezierTable2[#bezierTable2] = ((bezierTable3[i + 1][2] - bezierTable3[i][2]) * timePercent) + bezierTable3[i][2]
        end
        return getBezier_recursive(startTime, endTime, startValue, endValue, bezierTable2,nowt,false,true,bezierTable4)
    else
       return false
    end
end

function getMidX(startTime, endTime, startValue, endValue, bezierTable, timePercent)
    local accuracy = 0.005
    local lf = 0
    local rl = 1
    local mid = 0

    while rl - lf > accuracy do
        mid = (lf + rl) / 2
        local mid_x = getBezier3(startTime, endTime, startValue, endValue, bezierTable, mid, true)
        if mid_x > timePercent then
            rl = rl - accuracy
        elseif mid_x < timePercent then
            lf = lf + accuracy
        else
            return mid_x
        end
    end

    return lf
end
function love.load()
   love.window.setMode(700,700)
    love.window.setTitle("Bezier")
end

function love.update(dt)
--位置计算
   mousex, mousey = love.mouse.getPosition()
   bzpos1 = {Bezier_pos[1] * 300 + 250,(1 - Bezier_pos[2]) * 300 + 200}
   bzpos2 = {Bezier_pos[3] * 300 + 250,(1 - Bezier_pos[4]) * 300 + 200}
   if moing == true and moingpos == 1 then
     bzpos1 = {mousex,mousey}
     Bezier_pos[1],Bezier_pos[2] = (bzpos1[1] -250) / 300 ,1 - ( (bzpos1[2] -200) / 300)
   end
   if moing == true and moingpos == 2 then
     bzpos2 = {mousex,mousey}
     Bezier_pos[3],Bezier_pos[4] = (bzpos2[1] -250) / 300 , 1 -((bzpos2[2] -200) / 300)
   end
  --限制范围
      if Bezier_pos[1] > 1 then
           Bezier_pos[1] = 1
      elseif Bezier_pos[1] < 0 then
          Bezier_pos[1] = 0  
      elseif Bezier_pos[3] > 1 then
           Bezier_pos[3] = 1
      elseif Bezier_pos[3] < 0 then
          Bezier_pos[3] = 0  
      end
      if Bezier_pos[2] > 1.5 then
           Bezier_pos[2] = 1.5
      elseif Bezier_pos[2] < -0.5 then
          Bezier_pos[2] = -0.5  
       elseif Bezier_pos[4] > 1.5 then
           Bezier_pos[4] = 1.5
      elseif Bezier_pos[4] < -0.5 then
          Bezier_pos[4] = -0.5  
      end
     bzpos1 = {Bezier_pos[1] * 300 + 250,(1 - Bezier_pos[2]) * 300 + 200}
     bzpos2 = {Bezier_pos[3] * 300 + 250,(1 - Bezier_pos[4]) * 300 + 200}
   time = time + dt
   if time >= 3 then
      time = 0
   end 
   if copy == true then
      time2 = time2 + dt
   end
   if time2 >= 1 then
      copy = false
      time2 = 0
   end
   --图像演示
end 
function love.draw()
  love.graphics.setColor(1,1,1,1)
   local kx,ky,ky1 = getBezier(0,3,200,500,Bezier_pos,time)
   --local kx,ky,ky1 = getBezier3(0,3,200,500, Bezier_pos , time ,true,false,Bezier_pos)
   if time > 0  then
       love.graphics.rectangle("fill",250 + (100 * time),-ky1 + 700,1,ky1 - 200) --运动线
      
       love.graphics.line(250 + (100 * time) ,700 - ky1,550,700 - ky1) --运动线y

       love.graphics.setColor(0,1,1)
       love.graphics.rectangle("fill",550,700-ky1 ,10,10) --运动点1
   
   end

   love.graphics.setColor(1,0,1)
   love.graphics.rectangle("fill",kx + 50,550,10,10) --运动点2
   love.graphics.setColor(1,1,0)
   love.graphics.rectangle("fill",ky + 50,525,10,10) --运动点3
   
    love.graphics.setColor(1,1,1)
   love.graphics.rectangle("line",250 + (100 * time),575,10,10) --运动点4


   love.graphics.line(250,500,bzpos1[1],bzpos1[2]) --连接线
   love.graphics.line(550,200,bzpos2[1],bzpos2[2]) --连接线2
  love.graphics.print("COPY :ctrl + c",500,50)
  love.graphics.print("Bezier",500,600)
  love.graphics.setColor(0,1,1,1)
  for i = 0 ,300,0.1 do
    
    local q,w,e,r,t,y,u = getBezier(0,300,500,200,Bezier_pos,i,1)
       w1 = {w[1] * 300 + 250,(1 - w[2]) * 300 + 200}
       e1 = {e[1] * 300 + 250,(1 - e[2]) * 300 + 200}
       r1 = {r[1] * 300 + 250,(1 - r[2]) * 300 + 200}
       t1 = {t[1] * 300 + 250,(1 - t[2]) * 300 + 200}
       y1 = {y[1] * 300 + 250,(1 - y[2]) * 300 + 200}
       u1 = {u[1] * 300 + 250,(1 - u[2]) * 300 + 200}
       love.graphics.setColor(0,0.3,1,0.1)
       love.graphics.rectangle("fill",w1[1],w1[2],1,1)
       love.graphics.rectangle("fill",e1[1],e1[2],1,1)
       love.graphics.rectangle("fill",r1[1],r1[2],1,1)
       love.graphics.setColor(0,0.7,1,0.1)
       love.graphics.rectangle("fill",t1[1],t1[2],1,1)
       love.graphics.rectangle("fill",y1[1],y1[2],1,1)
       love.graphics.setColor(1,1,1,0.5)
       love.graphics.rectangle("fill",u1[1],u1[2],1,1)
       love.graphics.setColor(0,1,1,1)

           kkx,kky = getBezier(0,300,200,500,Bezier_pos,i-0.1)
           kkx2,kky2 =  getBezier(0,300,200,500,Bezier_pos,i)
          love.graphics.line(kkx + 50,-kky + 700,kkx2 + 50,-kky2 + 700)
          love.graphics.setColor(1,0,1,0.2)
          love.graphics.line(i + 250 ,-kky + 700,i + 0.1 + 250,-kky2 + 700)
          love.graphics.setColor(1,1,0,0.2)
          love.graphics.line(i + 250,-kkx + 700,i + 0.1 + 250,-kkx2 + 700)
  end
  love.graphics.setColor(1,1,1,1)
  for i = 1 ,4 do
     if i == 1 or i == 2 then
        love.graphics.setColor(1,1,0)
     else
        love.graphics.setColor(1,0,1)
     end
     love.graphics.print(Bezier_pos[i],100,50*i)
  end
  love.graphics.setColor(1,1,0)
  love.graphics.circle("line",bzpos1[1],bzpos1[2],20)
  love.graphics.setColor(1,0,1)
  love.graphics.circle("line",bzpos2[1],bzpos2[2],20)


  love.graphics.setColor(1,1,1)
   love.graphics.rectangle("fill",250,500,300,5) --轴 下一个一样
    love.graphics.rectangle("fill",550,100,5,405)

  if copy == true then
    love.graphics.setColor(1,1,1,getBezier1(0,1,1,0,{0,0,1,1},time2))
    love.graphics.print("Copy success !",500,75)
  end
end

function love.mousepressed(x, y, button)
   moing = true
   if x <= bzpos1[1] + 20 and y <= bzpos1[2] + 20 and x >= bzpos1[1] - 20 and y >= bzpos1[2] - 20 then
     moingpos = 1
   elseif x <= bzpos2[1] + 20 and y <= bzpos2[2] + 20 and x >= bzpos2[1] - 20 and y >= bzpos2[2] - 20 then
     moingpos = 2
   else
     moingpos = 0
   end
end

function love.mousereleased(button,x,y)
   moing = false
end


function love.keypressed(key)
   if key == "lctrl" or key == "rctrl" then
    ctrl = true
   end
   if key == "c" and ctrl == true then
      love.system.setClipboardText(Bezier_pos[1]..","..Bezier_pos[2]..","..Bezier_pos[3]..","..Bezier_pos[4])
      copy = true
   end
end
function love.keyreleased(key)
     ctrl = false
end
