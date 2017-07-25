function [coord] = findHole(img,x,y)

    %x = 320;
    %y = 470;

    step = 1;
    for step=0:320 
        if img(x+step,y) == 0
            findX = x+step;
            break;
        elseif img(x-step,y) == 0
            findX = x-step;
            break;
        else
            step = step + 1;
        end
    end;

    coord.xi = 320;
    coord.yi = 470;
    coord.xf = findX;
    coord.yf = 370;
    
    if findX > 600 | findX < 150
        coord.lines = 'two';
        coord.xm = findX;
        coord.ym = 470;
    else
        coord.lines = 'one';
    end;
    
end
