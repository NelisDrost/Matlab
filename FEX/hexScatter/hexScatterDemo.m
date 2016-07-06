myData = xlsread('myData.xlsx') ;

% x and y coordinates
xData = myData(:,1) ;
yData = myData(:,2) ;
% c data for the (x,y) points
cData = myData(:,3) ;
% x and y limits
xLim = [10 80] ;
yLim = [5 40] ;

% regular scatter plot
figure
scatter(xData,yData,20,cData,'marker','*')
title('Regular scatter plot')
axis equal ; box on
colorbar ;

% hexScatter plot with rHex = 1.0 without filling empty hexagons
rHex = 1.0 ;
ifFillEmptyHex = 0 ;
[figHndl,patchHndl,cbarHndl,xDataHex,yDataHex,cDataHex] = ...
    hexScatter(xData,yData,cData,xLim,yLim,rHex,ifFillEmptyHex) ;
title('hexScatter plot with rHex = 1.0 without filling empty hexagons')

% hexScatter plot with rHex = 0.3 without filling empty hexagons
rHex = 0.3 ;
ifFillEmptyHex = 0 ;
[figHndl,patchHndl,cbarHndl,xDataHex,yDataHex,cDataHex] = ...
    hexScatter(xData,yData,cData,xLim,yLim,rHex,ifFillEmptyHex) ;
title('hexScatter plot with rHex = 1.0 without filling empty hexagons')
set(patchHndl,'EdgeColor',[0.8,0.8,0.8]) ;

% hexScatter plot with rHex = 0.3 with filling empty hexagons
rHex = 0.3 ;
ifFillEmptyHex = 1 ;
[figHndl,patchHndl,cbarHndl,xDataHex,yDataHex,cDataHex] = ...
    hexScatter(xData,yData,cData,xLim,yLim,rHex,ifFillEmptyHex) ;
title('hexScatter plot with rHex = 1.0 without filling empty hexagons')
set(patchHndl,'EdgeColor',[0.8,0.8,0.8]) ;
