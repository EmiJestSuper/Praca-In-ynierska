function mask = seg_udo(img)

    img = imadjust(img);
    BW0 = img > 800;
    BW1=bwareafilt(BW0,1);
    BW2=BW0 & ~BW1; 
    BW3=bwareafilt(BW2,1);
    BW4=BW2 & ~BW3;
    BW5=bwareafilt(BW4,1);
    BW6=BW4 & ~BW5;
    BW7=bwareafilt(BW6,1);
    r = 3;
    se = strel('diamond', r);
    mask = int16(imdilate(BW7, se));    

end