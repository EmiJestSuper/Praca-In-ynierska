%% Projekt z Analizy Obrazów Medycznych
% Autor: Emilia Skwarek
% Temat: Wyznaczenie wektora cech wybranej struktury anatomicznej stawu kolanowego w płaszczyźnie strzałkowej.
% Topic: Determination of the feature vector of selected anatomical structures of the knee joint in the sagittal plane
%% SECTION 1 Zamykanie i czyszczenie okien
close all; clear; clc;
%% SECTION 2 Check that user has the Image Processing Toolbox installed.
hasIPT = license('test', 'image_toolbox');
if ~hasIPT
	% User does not have the toolbox installed.
	message = sprintf('It looks like you forgot to install a toolbox you dummy. Do you still want to continue?');
	reply = questdlg(message, 'No Image Processing Toolbox ', 'No', 'No', 'Yes');
	if strcmpi(reply, 'Nie')
		return;
	end
end
%% SECTION 3 Wczytywanie serii - "animacja" (Konkretny folder)

path = uigetdir('C:\');
k = dir( fullfile(path,'*.dcm'));

%k=dir(path,'*.dcm');

if numel(k) == 0
   errordlg('There are no Dicom files in chosen directory. Choose other foler.');
else
   for i=1:length(k)
    c = dicomread([k(i).folder '\' k(i).name]);
    imshow(c, 'DisplayRange',[])
   figure(1);
   title('Slices animation. Press any key to continue.')
    end
end
%% SECTION 4 Wyświetlanie informacjii, jeśli są podane do pliku Dicom (w posiadanej bazie nie ma takowych)
% info = dicominfo("PAC1_ok_T1/IM_09.dcm");
% Y = dicomread(info);
% figure(2)
% imshow(Y,[]);
%% SECTION 5 wczytanie danych i wybranie najlepszego obrazu

plik = dicomreadVolume("PAC1_ok_T1");
seriesSize = size(plik);
for i = 1:seriesSize(4)
    img = imadjust(plik(:,:,1,i));
    plik(:,:,1,i) = img;
 end
 matrix = plik;
[ileRzedow,ileKolumn,~,arrSize] = size(plik);
half = int8(arrSize/2);
wybraniec = plik(:,:,:,half);
figure(2)
imshow(wybraniec);
title("Best slice. Press any key to continue");
pause;
%%  SECTION 6 W CELU WYBORU STRUKTURY NALEŻY ODKOMENTOWAĆ JEDNĄ Z 3 SEGMENTACJI \|/---------------------------------------------------------
%% Segmentacja obiektu - więzadło krzyżowe tylne

maski = zeros(ileRzedow, ileKolumn, arrSize);
maski(:,:,half) = seg_wiezadlo(wybraniec);
figure(3)
%imshow(maski(:, :, half));
mask = maski(:,:,half);
globalMask = mask;
imshow(mask);
title("Segmented picture. Press any key to continue");
pause;
 %% Segmentacja obiektu - kość udowa
% 
% maski = zeros(ileRzedow, ileKolumn, arrSize);
% maski(:,:,half) = seg_udo(wybraniec);
% figure(3)
% imshow(maski(:, :, half));
% title("wysegmentowany obraz");
% mask = maski(:,:,half);
% globalMask = mask;
% imshow(mask);
% title("Segmented picture. Press any key to continue");
% pause;
%% Segmentacja obiektu - kość piszczelowa

% maski = zeros(ileRzedow, ileKolumn, arrSize);
% maski(:,:,half) = seg_piszczel(wybraniec);
% figure(3)
% imshow(maski(:, :, half));
% title("wysegmentowany obraz");
% mask = maski(:,:,half);
% globalMask = mask;
% imshow(mask);
% title("Segmented picture. Press any key to continue");
% pause;
%% ----------------------------------------------------------------------------------------------------------------
%% SECTION 7 Szkieletyzacja obiektu
BW=maski(:, :, half);
figure(4)
subplot(1,2,1);
imshow(BW);
title('Segmented mask.');
for i=0:5:40
  BW_szkielet = bwmorph(BW,'skel',i);
  subplot(1,2,2);
  imshow(BW_szkielet);
  title('Skeleton of segmented mask. Press any key to continue.');
end
pause;
%% SECTION 8 wyznazcanie cech --------------------------------------------------
%% Punkty końcowe szkieletu
It = bwmorph(BW_szkielet,'thin','inf');
B =  bwmorph(It,'branchpoints');
[i,j] = find(bwmorph(It,'endpoints'));
D = bwdistgeodesic(It,find(B),'quasi');
figure(5);
imshow(BW_szkielet);
for n = 1:numel(i)
    text(j(n),i(n),[num2str(D(i(n),j(n)))],'color','g');
end
title('Skeleton end points.');
pause;
%% powierzchnia stawu
level = 0.4;
BW111 = imbinarize(wybraniec,level);
%% najjaśniejszy piksel
I = wybraniec;
S = sum(I,3); %
[~,idx] = max(S(:));
[row,col] = ind2sub(size(S),idx);
maxBrightness = S(col,row);
%% Średnia jasność piksela
srednia_intensywnosc_obrazu = mean(wybraniec(:));
%% Minimalna przekątna Fereta

[out1,LM] = bwferet(BW,'MinFeretProperties');
najkrotsza_przekatna_fereta = out1.MinDiameter;
minimalny_kat_fereta = out1.MinAngle;
koordynatymin = cell2mat(out1.MinCoordinates);
%% Maksymalna średnica Fereta

[out2,LM] = bwferet(BW,'MaxFeretProperties');
najdluzsza_przekatna_fereta = out2.MaxDiameter;
maksymalny_kat_fereta = out2.MaxAngle;
koordynaty = cell2mat(out2.MaxCoordinates); 
%% wyświetlanie /|\
maxLabel = max(LM(:));
figure(6);
h = imshow(LM,[]);
axis = h.Parent;
for labelvalues = 1:maxLabel
    xmin = [out1.MinCoordinates{labelvalues}(1,1) out1.MinCoordinates{labelvalues}(2,1)];
    ymin = [out1.MinCoordinates{labelvalues}(1,2) out1.MinCoordinates{labelvalues}(2,2)];
    imdistline(axis,xmin,ymin);
end
%hold on
title(axis,'Minimum and maximum Ferets diameters.');
maxLabel = max(LM(:));
axis = h.Parent;
for labelvalues = 1:maxLabel
    xmax = [out2.MaxCoordinates{labelvalues}(1,1) out2.MaxCoordinates{labelvalues}(2,1)];
    ymax = [out2.MaxCoordinates{labelvalues}(1,2) out2.MaxCoordinates{labelvalues}(2,2)];
    imdistline(axis,xmax,ymax);
end
%hold off
pause;
%% Wysokość i szerokość w pikselach
wysokosc = abs(koordynaty(4) - koordynaty(2));
szerokosc = abs(koordynaty(3) - koordynaty(1));
%% Współczynnik Fereta
wsp_Fereta = szerokosc/wysokosc;
%% Euler
BW = (maski(:, :, half));
Euler=bweuler(BW);
%% Powierzchnia
powierzchnia = bwarea(BW);
%% Obwiednia
obwiednia = regionprops(BW,'BoundingBox');
%% Centroid
centroid = regionprops(BW,'Centroid');
%% kolistość
kolistosc = regionprops(BW,'circularity');
%% kierunek
kierunek = regionprops(mask,'orientation');
%% Inne cechy i tworzenie wektora
wsio = regionprops(BW,'all');
wsio1 = regionprops("table", BW, 'all');
wsio0 = wsio1(:, [1 2 3 5 6 7 8 11 12 15 16 18 19 20 23 24 25 26 28 29]);
%wsio_separated = splitvars(wsio1);
%tabela_fin = rows2vars(wsio_separated);
% a=tabela{kolumna,wiersz};
%% SECTION 9 Wektor końcowy
colnames = {'average image intensity', 'Max image brightness', 'ferret coefficient'};
t = table(srednia_intensywnosc_obrazu, maxBrightness,wsp_Fereta,'VariableNames',colnames);
finish = [wsio0 t];
close all;