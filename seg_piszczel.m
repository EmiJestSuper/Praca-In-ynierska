function mask = seg_piszczel(img)

    img = imadjust(img);
    BW0 = img > 800;
    BW = bwareafilt(BW0, 1, 'Largest');
    r = 3;
    se = strel('diamond', r);
    mask = int16(imdilate(BW, se));
end