function drawMode7(x, y, tex, ox, oy, r, s)
    for i = 1,screen.h,1 do
        love.graphics.setScissor(0, i, screen.w, 1)
        love.graphics.draw(tex, screen.w/2 + ox, screen.h/2 + oy, r, i * s, i * s, x, y)
    end
    love.graphics.setScissor()
end