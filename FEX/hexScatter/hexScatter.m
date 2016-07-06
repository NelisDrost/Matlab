%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% THIS CODE REDUCES THE DATA RESOLUTION BY PREPARING A HEXAGONAL 2D GRID %  
% AND REPLACING ALL THE DATA POINTS INSIDE A HEXAGONE WITH A SINGLE      %
% VALUE. IT THEN GIVES OUT A SCATTER PLOT WITH THOSE HEXAGONES.          %
% PREPARED BY: SALMAN MASHAYEKH                                          %
% DATE: DECEMBER 2012                                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [figHndl,patchHndl,cbarHndl,xDataHex,yDataHex,cDataHex] = hexScatter(xData,yData,cData,xLim,yLim,rHex,ifFillEmptyHex)


%% make sure the inputs are vertical
if ~isvector(xData) || ~isvector(yData) || ~isvector(cData) || ...
        length(xData)~=length(yData) || length(xData)~=length(cData) || length(yData)~=length(cData)
    fprintf('Error! xData, ydata, and cData must be vectors of the same length!\n');
    return
end
xData = reshape(xData,length(xData),1) ;
yData = reshape(yData,length(yData),1) ;
cData = reshape(cData,length(cData),1) ;
% -------------------------------------------------------------


%% make the grid for the center of hexagons
xrow1 = xLim(1)+sqrt(3)/2*rHex:sqrt(3)*rHex:xLim(2)+sqrt(3)/2*rHex ;
xrow2 = xLim(1):sqrt(3)*rHex:xLim(2) ;
if length(xrow1) > length(xrow2)
    xrow1 = xrow1(1:end-1) ;
elseif length(xrow2) > length(xrow1)
    xrow2 = xrow2(1:end-1) ;
end
yrow1 = yLim(1):3/2*rHex:yLim(2) ;
% ------
xgrid = repmat([xrow2;xrow1],floor(length(yrow1)/2),1) ;
if mod(length(yrow1),2) == 1
    xgrid = [xrow1; xgrid] ;
end
ygrid = repmat(yrow1(1:size(xgrid,1))',1,length(xrow1)) ;
% ------
xHex = xgrid(:) ;
yHex = ygrid(:) ;
% -------------------------------------------------------------


%% determine which hexagon each (x,y) data belongs to
hexMmbr = zeros(size(xData)) ;
for n = 1:length(xData)
    distVect = (xHex-xData(n)).^2+(yHex-yData(n)).^2 ;
    [~,hexMmbr(n)] = min(distVect) ;
end
% -------------------------------------------------------------


%% determine the average of the c values of the points fall inside a hexagon
cHex = zeros(size(xHex)) ; 
for n = 1:length(cHex)
    hexNumbers = (hexMmbr==n) ;
    if any(hexNumbers)
        % average of the cData 
        cHex(n) = mean(cData(hexNumbers)) ;
    else
        % cHex for the hexagons without any point inside them is set to
        % NaN
        cHex(n) = NaN ;
    end
end
% -------------------------------------------------------------


%% fill the cHex for empty hexagons using the cHex of the closets un-empty hexagon
if ifFillEmptyHex ==1
    cHexEmpt = isnan(cHex) ;
    cHexFull = ~isnan(cHex) ;
    % ------
    for n = 1:length(cHex)
        if cHexEmpt(n)
            distVect = (xHex(cHexFull)-xHex(n)).^2 + (yHex(cHexFull)-yHex(n)).^2 ;
            [~,myIndex] = min(distVect) ;
            closestFullHex = find(cHexFull==1,myIndex) ;
            closestFullHex = closestFullHex(end) ;
            cHex(n) = cHex(closestFullHex) ;
        end
    end
end
% ------
cHexEmpt = isnan(cHex) ;
cHexFull = ~isnan(cHex) ;
% -------------------------------------------------------------


%% prepare the patches
vertHexX=[-sqrt(3)/2*rHex   0       +sqrt(3)/2*rHex +sqrt(3)/2*rHex     0       -sqrt(3)/2*rHex     -sqrt(3)/2*rHex ] ;
vertHexY=[-rHex/2           -rHex   -rHex/2         +rHex/2             +rHex   +rHex/2             -rHex/2         ] ;
vertHexX = repmat(vertHexX,length(xHex),1) ; vertHexX = vertHexX(:) ;
vertHexY = repmat(vertHexY,length(yHex),1) ; vertHexY = vertHexY(:) ;
% ------
vertX = repmat(xHex,7,1) + vertHexX ;
vertY = repmat(yHex,7,1) + vertHexY ;
% ------
faces = 0:length(xHex):length(xHex)*(7-1) ;
faces = repmat(faces,length(xHex),1) ;
faces = repmat((1:length(xHex))',1,7) + faces ;
% ------
% eliminate empty faces
faces(cHexEmpt,:) = [] ;
% ------
figHndl = figure ;
box on ; axis equal ;
xlim(xLim) ; ylim(yLim) ;
patchHndl = patch('Faces',faces,'Vertices',[vertX vertY]);
set(patchHndl,'FaceColor','flat','FaceVertexCData',cHex(cHexFull),'CDataMapping','scaled')
cbarHndl = colorbar ; 
% -------------------------------------------------------------


%% prepare outputs
xDataHex = xHex(cHexFull) ;
yDataHex = yHex(cHexFull) ;
cDataHex = cHex(cHexFull) ;
% -------------------------------------------------------------