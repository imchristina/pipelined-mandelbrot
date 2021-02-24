xin = 0
yin = 0
xmax = 8
ymax = 8
x0 = (xin/xmax)*3.5-2.5
y0 = (yin/ymax)*2-1

print("x0:"..x0.." y0:"..y0)

x = 0
y = 0
i = 0
imax = 16
while (x*x+y*y < 4 and i < imax) do
    xtemp = x*x-y*y+x0
    y = 2*x*y+y0
    x=xtemp
    i = i + 1
    print("X:"..x.." Y:"..y.." I:"..i)
end
