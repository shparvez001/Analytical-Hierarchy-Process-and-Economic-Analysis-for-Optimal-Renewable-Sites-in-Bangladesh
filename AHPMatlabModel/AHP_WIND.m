%%------------------Analytical Hierachy Process------------------%%


clc
clear
disp('                                  Analytical Hierachy Process')
disp('                        _________________________________________________');



Criteria = ["Wind Speed";"Elevation";"Rainfall";"Cost Efficacy";"Land Area";"Slope"];
nC = length(Criteria);

%% Expert Ranking

nEx = 9;


Expert1 = [9 6 4 5 6 3]';
Expert2 = [5 4 5 5 4 2]';
Expert3 = [9 5 3 7 6 3]';
Expert4 = [9 4 3 5 6 1]';
Expert5 = [7 6 5 3 8 5]';
Expert6 = [8 4 5 8 7 1]';
Expert7 = [9 6 4 7 6 2]';
Expert8 = [9 4 6 4 9 4]';
Expert9 = [6 6 4 2 5 1]';

TotalRanking = table(Criteria, Expert1, Expert2 ,Expert3, Expert4, Expert5 ,Expert6, Expert7 ,Expert8, Expert9 );
Experts = TotalRanking{:,2:end};

Sc = sum(Experts);
Sall = sum(Experts,'all');
Sr = zeros(1,nC);
dj = Sr;
Dev= Sc;
RankingC = Sr;
for i=1:nC
    Sr(i)=sum(Experts(i,:));
end
for i=1:nC
    dj(i)= Sr(i)-Sall/nC;
end
for i=1:nEx
    Dev(i)=Sc(i)-mean(Sc);
end
dj2 = dj.^2;
W = (12*sum(dj2))/(nEx^2*(nC^3-nC));
fprintf('\n\n Expert Ranking(Total number of expert is %d):\n\n',nEx)
disp(TotalRanking)
fprintf(' The coefficient of concordance : ')
disp(W)
if W <0 || W>1
    fprintf(' Coefficient of Concordance is not valid.Try again.')
    return
elseif W <0.2
    fprintf(' Experts consclusions are not consistent.')
elseif W <0.4
    fprintf(' Experts consclusions are poorly consistent.')
elseif W< 0.6
    fprintf(' Experts consclusions are moderately consistent.')
elseif W< 0.8
    fprintf(' Experts consclusions are fairly consistent.')
elseif W< 0.9
    fprintf(' Experts consclusions are highly consistent.')
elseif W<= 1
    fprintf(' Experts consclusions are entirely consistent.')
end


RankOneExpert = find(abs(Dev)== min(abs(Dev))); % Expert with highest rating
RankLastExpert = find(abs(Dev)== max(abs(Dev))); % Expert with lowest rating

[sortedVals,indexes] = sort(abs(Dev));

RankingC1 = Experts(:,indexes(1:3));
[rc,cc] = size(RankingC1);

for i= 1:rc
    RankingC(i) = sum(RankingC1(i,:))/cc;
end
RankingC = round(RankingC);
%RankingC = round(Sr/nEx);
fprintf('\n\n Expert with highest rating : ');
disp(RankOneExpert);
fprintf(' Expert with lowest rating : ');
disp(RankLastExpert);
fprintf('\n Selected Ranking\n\n')
disp(RankingC')


%% Pairwise Comarison Matrix

CompM = zeros(nC);
for i = 1:nC
    for j = 1:nC
        if RankingC(i)>RankingC(j)
            CompM(i,j) = RankingC(i)-RankingC(j)+1;
        elseif RankingC(i)<RankingC(j)
            CompM(i,j)= 1/(RankingC(j)-RankingC(i)+1);
        elseif RankingC(i)==RankingC(j)
            CompM(i,j)=1;
        end
    end
end

%% Initialization
[r,c] = size(CompM);
n =r;
Normalized_CompM = zeros(r);
ConsCompM =zeros(r);
sum = zeros(1,c);
Weights = sum;
ConsWsum= sum;
LambdaAll= sum;
LambdaMax = 0;

%% Normalized Pairwise Comparison Matrix
for j= 1:c
    for i=1:r
        sum(j) = sum(j)+ CompM(i,j);
    end
    for i=1:r
        Normalized_CompM(i,j)=CompM(i,j)/sum(j);
    end
end
%% Calculation of Weights
for i= 1:r
    for j=1:c
        Weights(i)=Weights(i)+Normalized_CompM(i,j);
        if j<c
            continue
        end
        Weights(i) = Weights(i)/c;
    end
end
for i= 1:r
    for j=1:c
        ConsCompM(i,j) = CompM(i,j)*Weights(j);
        ConsWsum(i) = ConsWsum(i)+ConsCompM(i,j);
    end
end
%% Consistency vector
for i = 1:r
    LambdaAll(i) = ConsWsum(i)/Weights(i);
    LambdaMax = LambdaMax +LambdaAll(i);
end
LambdaMax = LambdaMax/n;
ConsistencyIndex = (LambdaMax-n)/(n-1);

%% Cosistency Ratio

RandomIndex = [0 0 0.52 0.89 1.12 1.26 1.36 1.41 1.46 1.49 1.52 1.52 1.54 1.56 1.58];
ConsistencyRatio = ConsistencyIndex/RandomIndex(n);


%% Importing Sheet file for selecting value from wind data range
ID = '12Vt0vd5fXWyOQGqyhc2nOXd7m26LWz_WtizhOxs5TzE';
sheet_name = 'FIXED AHP DATA WIND';
url_name = sprintf('https://docs.google.com/spreadsheets/d/%s/gviz/tq?tqx=out:csv&sheet=%s',...
    ID, sheet_name);
WindData = webread(url_name);
sheet_name2 = 'WindProjectData';
url_name2 = sprintf('https://docs.google.com/spreadsheets/d/%s/gviz/tq?tqx=out:csv&sheet=%s',...
    ID, sheet_name2);
WindDataLoc = webread(url_name2);


% Data collected from 4 locations 
WindSpeed = WindDataLoc.WindSpeed; 
Elevation = WindDataLoc.Elevation;
Rainfall = WindDataLoc.Rainfall;
Slope = WindDataLoc.Slope;
LandArea = WindDataLoc.LandArea;
NearTL = WindDataLoc.NearTL;
SoilStrngth = WindDataLoc.SoilStrngth;
NearRoad = WindDataLoc.NearRoad;
NearWaterResr = WindDataLoc.NearWaterRcsr;
NearPopulatedArea = WindDataLoc.NearPopulatedArea;
OpMCost = WindDataLoc.OpMCost;
DataAll = table(WindSpeed ,Elevation, Rainfall, LandArea,Slope, NearTL ,SoilStrngth ,NearRoad ,NearWaterResr ,NearPopulatedArea,OpMCost);
DataAllIndex = DataAll;

nData = length(WindSpeed);
Value = 9;
CostWeight = [1 7 7 8 8 7 6 5 9];
clear sum
for d =1: nData
for i=1:Value
    if DataAll.WindSpeed(d)>=WindData.WindMin(i) && DataAll.WindSpeed(d)<WindData.WindMax(i)
        DataAllIndex.WindSpeed(d) = WindData.Value(i);
        break
    end
end
for i=1:Value
    if DataAll.Elevation(d)>=WindData.ElevationMin(i) && DataAll.Elevation(d)<WindData.ElevationMax(i)
        DataAllIndex.Elevation(d) = WindData.Value(i);
        break
    end
end
for i=1:Value
    if DataAll.Rainfall(d)>=WindData.RainfallMinPerMonth(i) && DataAll.Rainfall(d)<WindData.RainfallMax(i)
        DataAllIndex.Rainfall(d) = WindData.Value(i);
        break
    end
end
for i=1:Value
    if DataAll.LandArea(d)>=WindData.LandAreaMin(i) && DataAll.LandArea(d)<WindData.LandAreaMax(i)
        DataAllIndex.LandArea(d) = WindData.Value(i);
        break
    end
end
for i=1:Value
    if DataAll.Slope(d)>=WindData.SlopeMin(i) && DataAll.Slope(d)<WindData.SlopeMax(i)
        DataAllIndex.Slope(d) = WindData.Value(i);
        break
    end
end

for i=1:Value
    if DataAll.NearTL(d)>=WindData.ProximityToTLMin(i) && DataAll.NearTL(d)<WindData.ProximityToTLMax(i)
        DataAllIndex.NearTL(d) = WindData.Value(i);
        break
    end
end
for i=1:Value
    if DataAll.NearRoad(d)>=WindData.ProximityToRoadMin(i) && DataAll.NearRoad(d)<WindData.ProximityToRoadMax(i)
        DataAllIndex.NearRoad(d) = WindData.Value(i);
        break
    end
end
for i=1:Value
    if DataAll.NearWaterResr(d)>=WindData.ProximityToWaterResourceMin(i) && DataAll.NearWaterResr(d)<WindData.ProximityToWaterResourceMax(i)
        DataAllIndex.NearWaterResr(d) = WindData.Value(i);
    end
end
for i=1:Value
    if DataAll.NearPopulatedArea(d)>=WindData.Prox_ToPopulatedAreaMin(i) && DataAll.NearPopulatedArea(d)<WindData.Prox_ToPopulatedAreaMax(i)
        DataAllIndex.NearPopulatedArea(d) = WindData.Value(i);
        break
    end
end
end

CostDataAll = [10-DataAllIndex.Rainfall 10-DataAllIndex.LandArea 10-DataAllIndex.Slope  DataAllIndex.NearTL DataAllIndex.SoilStrngth DataAllIndex.NearRoad DataAllIndex.NearWaterResr DataAllIndex.NearPopulatedArea 10-DataAllIndex.OpMCost];
%CostWeight = [1 7 7 8 8 7 6 5 9];
CostDataAllReal = CostWeight .* CostDataAll;

CostDataFinal = sum(CostDataAllReal');
CostDataFinalw = CostDataFinal./sum(CostWeight');
CostDataFinalIndex = CostDataFinal;
for d = 1:nData
for i=1:Value
    if CostDataFinalw(d)>=WindData.EconomicMin(i) && CostDataFinalw(d)<WindData.EconomicMax(i)
        CostDataFinalIndex(d) = WindData.Value(i);
        break
    end
end
end

WindDataFinal = [DataAllIndex.WindSpeed DataAllIndex.Elevation DataAllIndex.Rainfall CostDataFinalIndex' DataAllIndex.LandArea DataAllIndex.Slope];
WindIndexArray = WindDataFinal.*Weights;
WindIndex = sum(WindIndexArray');


%% Results 

fprintf('\n Normalized Matrix:\n\n')
disp(CompM)
fprintf('\n Weights:\n\n')
disp(Weights)
fprintf('\n Consistency Index:')
disp(ConsistencyIndex)
fprintf(' Consistency Ratio:')
disp(ConsistencyRatio)

if ConsistencyRatio <0.1
    disp(' The ratio indicates reasonable level of consistency in the pairwise comparison')
else
    disp(' The ratio indicates inconsistent judgement')
end
% Data
fprintf('\n Wind Data for %d different locations :\n\n',nData )
disp(DataAll)
fprintf('\n Wind range:\n\n')
disp(WindData)
fprintf('\n Wind Data Index for %d different locations :\n\n',nData )
disp(DataAllIndex)
fprintf('\n Wind Data Index to calculate Cost efficacy index :\n\n')
disp(CostDataAll)
fprintf('\n Cost Efficacy :\n\n')
disp(CostDataFinalIndex')
fprintf('\n Wind Data Index to calculate Wind plant index :\n\n')
disp(WindDataFinal)
fprintf('\n Wind Plant Index :\n\n')
disp(WindIndex)

% Pie chart
W = [Weights(2) Weights(5) Weights(2)  Weights(4) Weights(3) Weights(1) ];

figure()
p1 = pie(W);

pText = findobj(p1,"Type","text");   % Access Text objects
defaultLabels = get(pText,"String"); % Obtain default labels from Text objects

labels = ["SLOPE :","LAND AREA : ","ALTITUDE : ","COST EFFICACY : ","RAINFALL : "," WIND SPEED : "]; 

for i = 1:length(pText)
    pText(i).String = [labels{i} defaultLabels{i}]; % Insert desired text into label
end
title("Distribution of weights in each evaluation criteria")

colormap("hot"); % Specify colormap
% camlightType = "right";
% lightingType = 'gouraud';
% shadingType = "flat";
% lighting(lightingType);
% shading(shadingType);
% camlight(camlightType);

% bar plot
figure()
WindIndexArrayBar = [WindIndexArray(:,1) WindIndexArray(:,4) WindIndexArray(:,5) WindIndexArray(:,2) WindIndexArray(:,3) WindIndexArray(:,6)];

bar(WindIndexArrayBar,'stacked')
grid on
ylabel('Wind Plant Index')
legend(["Wind Speed";"Cost efficacy";"Land Area";"Altitude";"Rainfall";"Slope"])

ax = gca;

ax.XTickLabels = {'Dhaka','Chittagong','Rajshahi','Khulna','Rangpur','Sylhet','Barisal','Mymenshingh'};
ax.XTickLabelRotation = 45;
