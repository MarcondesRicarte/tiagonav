function [findX] = findHole(x,y)


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

    
end
