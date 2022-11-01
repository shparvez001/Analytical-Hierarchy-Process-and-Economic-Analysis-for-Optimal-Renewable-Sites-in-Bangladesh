%%------------------Analytical Hierachy Process------------------%%


clc
clear
disp('                                  Analytical Hierachy Process')
disp('                        _________________________________________________');



Criteria = ["Flow Rate";"Head";"Rainfall";"Cost Efficacy";"Catchment Area";"Water Temperature"];
nC = length(Criteria);

%% Expert Ranking

 %Let not take expert ranking right now ;)
nEx = 9;


Expert1 = [4 6 3 3 5 1]';
Expert2 = [5 9 9 7 5 4]';
Expert3 = [5 8 8 6 8 2]';
Expert4 = [6 9 7 6 7 3]';
Expert5 = [6 8 7 9 9 3]';
Expert6 = [2 4 3 5 4 2]';
Expert7 = [4 9 6 5 8 2]';
Expert8 = [5 9 7 6 9 2]';
Expert9 = [5 8 8 7 6 4]';

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
fprintf('\n\n Expert with highest rating : ');
disp(RankOneExpert);
fprintf(' Expert with lowest rating : ');
disp(RankLastExpert);
fprintf('\n Selected Ranking\n\n')
disp(RankingC')


% RankingC = [8 7 6 5 6 1];
% fprintf('\n Selected Ranking\n\n')
% disp(RankingC')
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


%% Importing Sheet file for selecting value from Hydro data range
ID = '12Vt0vd5fXWyOQGqyhc2nOXd7m26LWz_WtizhOxs5TzE';
sheet_name = 'FIXED AHP DATA HYDRO';
url_name = sprintf('https://docs.google.com/spreadsheets/d/%s/gviz/tq?tqx=out:csv&sheet=%s',...
    ID, sheet_name);
HydroData = webread(url_name)
sheet_name2 = 'HydroProjectData';
url_name2 = sprintf('https://docs.google.com/spreadsheets/d/%s/gviz/tq?tqx=out:csv&sheet=%s',...
    ID, sheet_name2);
HydroDataLoc = webread(url_name2);


% Data collected from 4 locations 
FlowRate = HydroDataLoc.FlowRate; 
Head = HydroDataLoc.Head;
Rainfall = HydroDataLoc.Rainfall;
CatchmentArea = HydroDataLoc.CatchmentArea;
WaterTemp = HydroDataLoc.WaterTemp;
RiverWidth = HydroDataLoc.RiverWidth;
OpMCost = HydroDataLoc.OpMCost;
NearTL = HydroDataLoc.NearRoad;
RockStructure = HydroDataLoc.RockStructure;
NearRoad = HydroDataLoc.NearPopulatedArea;
NearPopulatedArea = HydroDataLoc.NearPopulatedArea;
DataAll = table(FlowRate ,Head, Rainfall, CatchmentArea,WaterTemp,RiverWidth,OpMCost, NearTL ,RockStructure ,NearRoad ,NearPopulatedArea);
DataAllIndex = DataAll;

nData = length(FlowRate);
Value = 9;
CostWeight = [7 8 9 7 6 5 4];
clear sum
for d =1: nData
for i=1:Value
    if DataAll.FlowRate(d)>=HydroData.FlowRateMin(i) && DataAll.FlowRate(d)<HydroData.FlowRateMax(i)
        DataAllIndex.FlowRate(d) = HydroData.Value(i);
        break
    end
end
for i=1:Value
    if DataAll.Head(d)>=HydroData.HeadMin(i) && DataAll.Head(d)<HydroData.HeadMax(i)
        DataAllIndex.Head(d) = HydroData.Value(i);
        break
    end
end
for i=1:Value
    if DataAll.Rainfall(d)>=HydroData.RainfallMin(i) && DataAll.Rainfall(d)<HydroData.RainfallMax(i)
        DataAllIndex.Rainfall(d) = HydroData.Value(i);
        break
    end
end
for i=1:Value
    if DataAll.CatchmentArea(d)>=HydroData.CatchmentAreaMin(i) && DataAll.CatchmentArea(d)<HydroData.CatchmentAreaMax(i)
        DataAllIndex.CatchmentArea(d) = HydroData.Value(i);
        break
    end
end
for i=1:Value
    if DataAll.WaterTemp(d)>=HydroData.WaterTemperatureMin(i) && DataAll.WaterTemp(d)<HydroData.WaterTemoeratureMax(i)
        DataAllIndex.WaterTemp(d) = HydroData.Value(i);
        break
    end
end
for i=1:Value
    if DataAll.NearTL(d)>=HydroData.ProximityToTLMin(i) && DataAll.NearTL(d)<HydroData.ProximityToTLMax(i)
        DataAllIndex.NearTL(d) = HydroData.Value(i);
        break
    end
end
for i=1:Value
    if DataAll.NearRoad(d)>=HydroData.ProximityToRoadMin(i) && DataAll.NearRoad(d)<HydroData.ProximityToRoadMax(i)
        DataAllIndex.NearRoad(d) = HydroData.Value(i);
        break
    end
end
for i=1:Value
    if DataAll.RiverWidth(d)>=HydroData.RiverWidthMin(i) && DataAll.RiverWidth(d)<HydroData.RiverWidthMax(i)
        DataAllIndex.RiverWidth(d) = HydroData.Value(i);
        break
    end
end
for i=1:Value
    if DataAll.NearPopulatedArea(d)>=HydroData.Prox_ToPopulatedAreaMin(i) && DataAll.NearPopulatedArea(d)<HydroData.Prox_ToPopulatedAreaMax(i)
        DataAllIndex.NearPopulatedArea(d) = HydroData.Value(i);
        break
    end
end
end

CostDataAll = [10-DataAllIndex.CatchmentArea DataAllIndex.RiverWidth 10-DataAllIndex.OpMCost  DataAllIndex.NearTL DataAllIndex.RockStructure DataAllIndex.NearRoad DataAllIndex.NearPopulatedArea];
%CostWeight = [7 8 9 7 6 5 4];
CostDataAllReal = CostWeight .* CostDataAll;

CostDataFinal = sum(CostDataAllReal');
CostDataFinalw = CostDataFinal./sum(CostWeight');
CostDataFinalIndex = CostDataFinal;
for d = 1:nData
for i=1:Value
    if CostDataFinalw(d)>=HydroData.EconomicMin(i) && CostDataFinalw(d)<HydroData.EconomicMax(i)
        CostDataFinalIndex(d) = HydroData.Value(i);
        break
    end
end
end

HydroDataFinal = [DataAllIndex.FlowRate DataAllIndex.Head DataAllIndex.Rainfall CostDataFinalIndex' DataAllIndex.CatchmentArea DataAllIndex.WaterTemp];
HydroIndexArray = HydroDataFinal.*Weights;
HydroIndex = sum(HydroIndexArray');


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
fprintf('\n Hydro Data for %d different locations :\n\n',nData )
disp(DataAll)
fprintf('\n Hydro range:\n\n')
disp(HydroData)
fprintf('\n Hydro Data Index for %d different locations :\n\n',nData )
disp(DataAllIndex)
fprintf('\n Hydro Data Index to calculate Cost efficacy index :\n\n')
disp(CostDataAll)
fprintf('\n Cost Efficacy :\n\n')
disp(CostDataFinalIndex')
fprintf('\n Hydro Data Index to calculate Hydro plant index :\n\n')
disp(HydroDataFinal)
fprintf('\n Hydro Plant Index :\n\n')
disp(HydroIndex)

% Pie chart
W = [Weights(6) Weights(5) Weights(4) Weights(3) Weights(1) Weights(2)];
figure()
p1 = pie(W);

pText = findobj(p1,"Type","text");   % Access Text objects
defaultLabels = get(pText,"String"); % Obtain default labels from Text objects

labels = ["WATER TEMPERATURE :"    "CATCHMENT AREA : "    "COST EFFICACY : "    "RAINFALL : "  " FLOW RATE : "  "HEAD : "    ]; 
for i = 1:length(pText)
    pText(i).String = [labels{i} defaultLabels{i}]; % Insert desired text into label
end
title("Distribution of weights in each evaluation criteria")

colormap("cool"); % Specify colormap
% camlightType = "right";
% lightingType = 'gouraud';
% shadingType = "flat";
% lighting(lightingType);
% shading(shadingType);
% camlight(camlightType);

% bar plot
figure()
HydroIndexArrayBar = [HydroIndexArray(:,2) HydroIndexArray(:,5) HydroIndexArray(:,3) HydroIndexArray(:,4) HydroIndexArray(:,1) HydroIndexArray(:,6)];

bar(HydroIndexArray,'stacked')
grid on
ylabel('Hydro Plant Index')
legend(["Head";"Catchment Area";"Rainfall";"Cost efficacy";"Flow Rate";"Water Temperature"])

ax = gca;

ax.XTickLabels = {'Jadukata River','Jhalukhali River','Sarigoyain River','Dhalai River'};
ax.XTickLabelRotation = 45;
