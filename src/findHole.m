function [coord] = findHole(img,x,y,fator)

    x = x/fator;
    y = y/fator;

    step = 1;
    for step=0:(320/fator) 
        if img(x+step,y) == 0 % 0 - file, 1 - robot
            findX = x+step;
            break;
        elseif img(x-step,y) == 0
            findX = x-step;
            break;
        else
            step = step + 1;
        end
    end;

    coord.xi = 320/fator;
    coord.yi = 470/fator;
    coord.xf = findX;
    coord.yf = 370/fator;
    
    if findX > 600/fator | findX < 150/fator
        coord.lines = 'two';
        coord.xm = findX;
        coord.ym = 470/fator;
    else
        coord.lines = 'one';
    end;
    
end
