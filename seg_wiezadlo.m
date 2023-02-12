function mask = seg_wiezadlo(img)

    img = imadjust(img);
    BW = img> -20000;
    r = 4;
    dekompozycja = 0;
    se = strel('disk', r, dekompozycja);
    BW = imopen(BW, se);
    BW = imcomplement(BW);
    BW = imclearborder(BW);
    length = 5.000000;
    angle = 145.000000;
    se = strel('line', length, angle);
    BW = imerode(BW, se);
    r = 1;
    se = strel('diamond', r);
    BW = imerode(BW, se);
    r = 2;
    se = strel('diamond', r);
    mask = int16(imdilate(BW, se));    
end