function [fishx, fishy] = FishWire(startPoint, midPoint, endPoint, pos_cell, midPointFrame, currentFrame)

% https://math.stackexchange.com/questions/2297518/find-x-value-on-a-line-segment-with-given-y

[ax, ay, az] = deal(startPoint(1,1), startPoint(1,2), startPoint(1,3));
[bx, by, bz] = deal(midPoint(1,1), midPoint(1,2), midPoint(1,3));
[cx, cy, cz] = deal(endPoint(1,1), endPoint(1,2), endPoint(1,3));
fz = pos_cell{currentFrame}(1,1);

if currentFrame < midPointFrame
    fishx = ax + (fz-az)/(bz-az) * (bx - ax);
    
    fishy = ay + (fz-az)/(bz-az) * (by - ay);
    
elseif currentFrame > midPointFrame
    fishx = bx + (fz-bz)/(cz-bz) * (cx - bx);
    
    fishy = by + (fz-bz)/(cz-bz) * (cy - by);
end
end
