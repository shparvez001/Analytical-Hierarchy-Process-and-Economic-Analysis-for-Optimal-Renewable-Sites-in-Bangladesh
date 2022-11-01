%%------------------Analytical Hierachy Process------------------%%


clc
clear
disp('                                  Analytical Hierachy Process')
disp('                        _________________________________________________');



Criteria = ["Solar DNI";"Air Temperature";"Aspect";"Cost efficacy";"Land Area";"Latitude"];
nC = length(Criteria);

%% Expert Ranking

nEx = 9;

Expert1 = [8 4 7 9 5 7]';
Expert2 = [8 5 7 8 6 7]';
Expert3 = [9 4 8 8 5 6]';
Expert4 = [9 4 6 7 6 6]';
Expert5 = [9 3 8 8 7 3]';
Expert6 = [9 2 7 9 5 5]';
Expert7 = [8 4 6 7 6 2]';
Expert8 = [8 2 9 7 3 7]';
Expert9 = [9 4 8 6 7 5]';

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

clear sum
%% Importing Sheet file for selecting value from Solar data range

ID = '12Vt0vd5fXWyOQGqyhc2nOXd7m26LWz_WtizhOxs5TzE';
sheet_name = 'FIXED AHP DATA SOLAR';
url_name = sprintf('https://docs.google.com/spreadsheets/d/%s/gviz/tq?tqx=out:csv&sheet=%s',...
    ID, sheet_name);
SolarData = webread(url_name);
sheet_name2 = 'SolarProjectData';
url_name2 = sprintf('https://docs.google.com/spreadsheets/d/%s/gviz/tq?tqx=out:csv&sheet=%s',...
    ID, sheet_name2);
SolarDataLoc = webread(url_name2);

% Data collected from 4 locations 


SolarDNI = SolarDataLoc.SolarDNI;
AirTemp = SolarDataLoc.AirTemp;
Slope = SolarDataLoc.Slope;
Aspect = SolarDataLoc.Aspect;
LandArea = SolarDataLoc.LandArea;
Latitude = SolarDataLoc.Latitude;
NearTL = SolarDataLoc.NearTL;
SoilStrngth = SolarDataLoc.SoilStrngth;
NearRoad = SolarDataLoc.NearRoad;
NearWaterResr = SolarDataLoc.NearWaterRcsr;
NearPopulatedArea = SolarDataLoc.NearPopulatedArea;
OpMCost = SolarDataLoc.OpMCost;

DataAll = table(SolarDNI ,AirTemp,Slope, Aspect, LandArea, Latitude, NearTL ,SoilStrngth ,NearRoad ,NearWaterResr ,NearPopulatedArea,OpMCost);
DataAllIndex = DataAll;

nData = length(SolarDNI);
Value = 9;
CostWeight = [4 9 9 3 7 6 5 7];

for d =1: nData
for i=1:Value
    if DataAll.SolarDNI(d)>=SolarData.SolarDNIMin(i) && DataAll.SolarDNI(d)<SolarData.SolarDNIMax(i)
        DataAllIndex.SolarDNI(d) = SolarData.Value(i);
        break
    end
end
for i=1:Value
    if DataAll.AirTemp(d)>=SolarData.AirTempertaureMin(i) && DataAll.AirTemp(d)<SolarData.AirTempertaureMax(i)
        DataAllIndex.AirTemp(d) = SolarData.Value(i);
        break
    end
end
for i=1:Value
    if DataAll.Slope(d)>=SolarData.SlopeMin(i) && DataAll.Slope(d)<SolarData.SlopeMax(i)
        DataAllIndex.Slope(d) = SolarData.Value(i);
        break
    end
end
for i=1:Value
    if DataAll.LandArea(d)>=SolarData.LandAreaMin(i) && DataAll.LandArea(d)<SolarData.LandAreaMax(i)
        DataAllIndex.LandArea(d) = SolarData.Value(i);
        break
    end
end

for i=1:Value
    if DataAll.Latitude(d)>=SolarData.LatitudeMin(i) && DataAll.Latitude(d)<SolarData.LatitudeMax(i)
        DataAllIndex.Latitude(d) = SolarData.Value(i);
        break
    end
end
for i=1:Value
    if DataAll.NearTL(d)>=SolarData.ProximityToTLMin(i) && DataAll.NearTL(d)<SolarData.ProximityToTLMax(i)
        DataAllIndex.NearTL(d) = SolarData.Value(i);
        break
    end
end
for i=1:Value
    if DataAll.NearRoad(d)>=SolarData.ProximityToRoadMin(i) && DataAll.NearRoad(d)<SolarData.ProximityToRoadMax(i)
        DataAllIndex.NearRoad(d) = SolarData.Value(i);
        break
    end
end
for i=1:Value
    if DataAll.NearWaterResr(d)>=SolarData.ProximityToWaterResourceMin(i) && DataAll.NearWaterResr(d)<SolarData.ProximityToWaterResourceMax(i)
        DataAllIndex.NearWaterResr(d) = SolarData.Value(i);
    end
end
for i=1:Value
    if DataAll.NearPopulatedArea(d)>=SolarData.Prox_ToPopulatedAreaMin(i) && DataAll.NearPopulatedArea(d)<SolarData.Prox_ToPopulatedAreaMax(i)
        DataAllIndex.NearPopulatedArea(d) = SolarData.Value(i);
        break
    end
end
end

CostDataAll = [ DataAllIndex.Slope  10-DataAllIndex.LandArea  DataAllIndex.NearTL DataAllIndex.SoilStrngth DataAllIndex.NearRoad DataAllIndex.NearWaterResr DataAllIndex.NearPopulatedArea 10-DataAllIndex.OpMCost];

CostDataAllReal = CostWeight .* CostDataAll;

CostDataFinal = sum(CostDataAllReal');
CostDataFinalw = CostDataFinal./sum(CostWeight');
CostDataFinalIndex = CostDataFinalw;
for d = 1:nData
for i=1:Value
    if CostDataFinalw(d)>=SolarData.EconomicMin(i) && CostDataFinalw(d)<SolarData.EconomicMax(i)
        CostDataFinalIndex(d) = SolarData.Value(i);
        break
    end
end
end

SolarDataFinal = [DataAllIndex.SolarDNI DataAllIndex.AirTemp DataAllIndex.Aspect CostDataFinalIndex' DataAllIndex.LandArea DataAllIndex.Latitude];
SolarIndexArray = SolarDataFinal.*Weights;
SolarIndex = sum(SolarIndexArray');

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
fprintf('\n Solar Data for %d different locations :\n\n',nData )
disp(DataAll)
fprintf('\n Solar range:\n\n')
disp(SolarData)
fprintf('\n Solar Data Index for %d different locations :\n\n',nData )
disp(DataAllIndex)
fprintf('\n Solar Data Index to calculate Cost efficacy index :\n\n')
disp(CostDataAll)
fprintf('\n Cost Efficacy :\n\n')
disp(CostDataFinalIndex')
fprintf('\n Solar Data Index to calculate Solar plant index :\n\n')
disp(SolarDataFinal)
fprintf('\n Solar Plant Index :\n\n')
disp(SolarIndex)

% Pie chart

W = [Weights(2) Weights(3) Weights(5)  Weights(4) Weights(6) Weights(1) ];

figure()
p1 = pie(W);

pText = findobj(p1,"Type","text");   % Access Text objects
defaultLabels = get(pText,"String"); % Obtain default labels from Text objects

labels = ["AIR TEMPERATURE","ASPECT","LAND AREA","COST EFFICACY","LATITUDE","SOLAR DNI"]; 
legend(labels,'Location','northeastoutside','Orientation','vertical')

title("Distribution of weights in each evaluation criteria")

colormap("autumn"); % Specify colormap
% camlightType = "right";
% lightingType = 'gouraud';
% shadingType = "flat";
% lighting(lightingType);
% shading(shadingType);
% camlight(camlightType);

f= gcf;
f.Units = 'inches';
f.OuterPosition = [0 0 5 5];
exportgraphics(f,'SolarW.pdf','Resolution',600)



% Bar plot
figure()
SolarIndexArrayBar = [SolarIndexArray(:,1) SolarIndexArray(:,4) SolarIndexArray(:,3) SolarIndexArray(:,5) SolarIndexArray(:,6) SolarIndexArray(:,2)];

bar(SolarIndexArrayBar,'stacked')
grid on
ylabel('Solar Plant Index')
legend(["Solar DNI";"Cost effi.";"Aspect";"Land Area";"Latitude";"Air Temp."],'Location','northeastoutside','Orientation','vertical')

ax = gca;

ax.XTickLabels = {'Dhaka','Chittagong','Rajshahi','Khulna','Rangpur','Sylhet','Barisal','Mymenshinngh'};
ax.XTickLabelRotation = 45;

f= gcf;
f.Units = 'inches';
f.OuterPosition = [1 1 4.6 3.5];
exportgraphics(f,'SolarD.pdf','Resolution',600)

