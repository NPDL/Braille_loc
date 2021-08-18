% convert a 48*32 BMP to a byte array
function stream = encodePicture(mat)
%     disp(size(mat))
    assert(all(size(mat) == [32, 48]));
    
    mat = ~(mat > 0); % convert to boolean
    mat = fliplr(mat)'; % Correct orientation
    stream = zeros(4, 48);
    for lane = 1:4
        lanestart = 1+ (lane-1)*8;
        laneend = lanestart + 8 -1;

        stream(lane, :) = mat(:, lanestart:laneend) * [1 2 4 8 16 32 64 128]';
    end
    stream = stream(:);
%     disp(stream)
end