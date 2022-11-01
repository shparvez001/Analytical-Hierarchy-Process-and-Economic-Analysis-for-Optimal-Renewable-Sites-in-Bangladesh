%%------------------Analytical Hierachy Process------------------%%


clc
clear
disp('                                  Analytical Hierachy Process')
disp('                        _________________________________________________');



Criteria = ["Raw Materials";"Air Temperature";"Water Availability";"Cost efficacy";"Land Area";"Proximity to Residential Area"];
nC = length(Criteria);

%% Expert Ranking


nEx = 9;

Expert1 = [9 4 9 8 5 3]';
Expert2 = [7 2 5 5 2 2]';
Expert3 = [9 3 8 7 4 7]';
Expert4 = [4 2 3 2 3 1]';
Expert5 = [9 4 8 8 7 5]';
Expert6 = [8 2 6 6 6 7]';
Expert7 = [9 2 8 7 6 2]';
Expert8 = [8 4 7 7 7 5]';
Expert9 = [4 1 3 5 2 2]';

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
RankingC1 = Experts(:,RankOneExpert);

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



% RankingC = [9 4 8 7 6 3];
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

clear sum
%% Importing Sheet file for selecting value from Biogas data range

ID = '12Vt0vd5fXWyOQGqyhc2nOXd7m26LWz_WtizhOxs5TzE';
sheet_name = 'FIXED AHP DATA Biogas';
url_name = sprintf('https://docs.google.com/spreadsheets/d/%s/gviz/tq?tqx=out:csv&sheet=%s',...
    ID, sheet_name);
BiogasData = webread(url_name)
sheet_name2 = 'BiogasProjectData';
url_name2 = sprintf('https://docs.google.com/spreadsheets/d/%s/gviz/tq?tqx=out:csv&sheet=%s',...
    ID, sheet_name2);
BiogasDataLoc = webread(url_name2);

% Data collected from 4 locations 


RawMaterials = BiogasDataLoc.RawMaterials;
AirTemp = BiogasDataLoc.AirTemp;
Slope = BiogasDataLoc.Slope;
WaterAvailability = BiogasDataLoc.WaterAvailability;
DigestateDisposalPoint = BiogasDataLoc.DigestateDisposalPoint;
LandArea = BiogasDataLoc.LandArea;
NearResi = BiogasDataLoc.NearResi;
NearTL = BiogasDataLoc.NearTL;
SoilStrngth = BiogasDataLoc.SoilStrngth;
NearRoad = BiogasDataLoc.NearRoad;
NearWaterResr = BiogasDataLoc.NearWaterRcsr;
NearFarm = BiogasDataLoc.NearFarm;
NearUtility= BiogasDataLoc.NearUtility;
OpMCost = BiogasDataLoc.OpMCost;
DataAll = table(RawMaterials ,AirTemp,WaterAvailability,DigestateDisposalPoint, LandArea, NearResi,NearFarm,Slope, NearTL ,SoilStrngth ,NearRoad ,NearWaterResr ,NearUtility,OpMCost);
DataAllIndex = DataAll;

nData = length(RawMaterials);
Value = 9;
CostWeight = [5 5 8 4 6 5 4 9 8 7];

for d =1: nData
for i=1:Value
    if DataAll.AirTemp(d)>=BiogasData.AirTempertaureMin(i) && DataAll.AirTemp(d)<BiogasData.AirTempertaureMax(i)
        DataAllIndex.AirTemp(d) = BiogasData.Value(i);
        break
    end
end
for i=1:Value
    if DataAll.Slope(d)>=BiogasData.SlopeMin(i) && DataAll.Slope(d)<BiogasData.SlopeMax(i)
        DataAllIndex.Slope(d) = BiogasData.Value(i);
        break
    end
end
for i=1:Value
    if DataAll.LandArea(d)>=BiogasData.LandAreaMin(i) && DataAll.LandArea(d)<BiogasData.LandAreaMax(i)
        DataAllIndex.LandArea(d) = BiogasData.Value(i);
        break
    end
end

for i=1:Value
    if DataAll.DigestateDisposalPoint(d)>=BiogasData.DigestateDisposalPointMin(i) && DataAll.DigestateDisposalPoint(d)<BiogasData.DigestateDisposalPointMax(i)
        DataAllIndex.DigestateDisposalPoint(d) = BiogasData.Value(i);
        break
    end
end
for i=1:Value
    if DataAll.NearResi(d)>=BiogasData.ProximityToResidentialAreaMin(i) && DataAll.NearResi(d)<BiogasData.ProximityToResidentialAreaMax(i)
        DataAllIndex.NearResi(d) = BiogasData.Value(i);
        break
    end
end
for i=1:Value
    if DataAll.NearFarm(d)>=BiogasData.ProximityToFarmMin(i) && DataAll.NearFarm(d)<BiogasData.ProximityToFarmMax(i)
        DataAllIndex.NearFarm(d) = BiogasData.Value(i);
        break
    end
end
for i=1:Value
    if DataAll.NearTL(d)>=BiogasData.ProximityToTLMin(i) && DataAll.NearTL(d)<BiogasData.ProximityToTLMax(i)
        DataAllIndex.NearTL(d) = BiogasData.Value(i);
        break
    end
end
for i=1:Value
    if DataAll.NearRoad(d)>=BiogasData.ProximityToRoadMin(i) && DataAll.NearRoad(d)<BiogasData.ProximityToRoadMax(i)
        DataAllIndex.NearRoad(d) = BiogasData.Value(i);
        break
    end
end
for i=1:Value
    if DataAll.NearWaterResr(d)>=BiogasData.ProximityToWaterResourceMin(i) && DataAll.NearWaterResr(d)<BiogasData.ProximityToWaterResourceMax(i)
        DataAllIndex.NearWaterResr(d) = BiogasData.Value(i);
    end
end
for i=1:Value
    if DataAll.NearUtility(d)>=BiogasData.ProximityOfUtilityMin(i) && DataAll.NearUtility(d)<BiogasData.ProximityOfUtilityMax(i)
        DataAllIndex.NearUtility(d) = BiogasData.Value(i);
        break
    end
end
end

CostDataAll = [DataAllIndex.DigestateDisposalPoint 10-DataAllIndex.LandArea DataAllIndex.NearFarm DataAllIndex.Slope DataAllIndex.NearTL DataAllIndex.SoilStrngth DataAllIndex.NearRoad DataAllIndex.NearWaterResr DataAllIndex.NearUtility 10-DataAllIndex.OpMCost];

CostDataAllReal = CostWeight .* CostDataAll;

CostDataFinal = sum(CostDataAllReal');
CostDataFinalw = CostDataFinal./sum(CostWeight');
CostDataFinalIndex = CostDataFinal;
for d = 1:nData
for i=1:Value
    if CostDataFinalw(d)>=BiogasData.EconomicMin(i) && CostDataFinalw(d)<BiogasData.EconomicMax(i)
        CostDataFinalIndex(d) = BiogasData.Value(i);
        break
    end
end
end

BiogasDataFinal = [DataAllIndex.RawMaterials DataAllIndex.AirTemp DataAllIndex.WaterAvailability CostDataFinalIndex' DataAllIndex.LandArea DataAllIndex.NearResi];
BiogasIndexArray = BiogasDataFinal.*Weights;
BiogasIndex = sum(BiogasIndexArray');

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
fprintf('\n Biogas Data for %d different locations :\n\n',nData )
disp(DataAll)
fprintf('\n Biogas range:\n\n')
disp(BiogasData)
fprintf('\n Biogas Data Index for %d different locations :\n\n',nData )
disp(DataAllIndex)
fprintf('\n Biogas Data Index to calculate Cost efficacy index :\n\n')
disp(CostDataAll)
fprintf('\n Cost Efficacy :\n\n')
disp(CostDataFinalIndex')
fprintf('\n Biogas Data Index to calculate Biogas plant index :\n\n')
disp(BiogasDataFinal)
fprintf('\n Biogas Plant Index :\n\n')
disp(BiogasIndex)

% Pie chart

W = [Weights(2) Weights(3) Weights(6) Weights(4) Weights(5) Weights(1) ];

figure()
p1 = pie(W);

pText = findobj(p1,"Type","text");   % Access Text objects
defaultLabels = get(pText,"String"); % Obtain default labels from Text objects

labels = ["AIR TEMPERATURE : ","WATER AVAILABILITY: ","PROX. TO RESI. AREA :","COST EFFICACY: ","LAND AREA : ","RAW MATERIALS : "]; 

for i = 1:length(pText)
    pText(i).String = [labels{i} defaultLabels{i}]; % Insert desired text into label
end
title("Distribution of weights in each evaluation criteria")

colormap("summer"); % Specify colormap
% camlightType = "right";
% lightingType = 'gouraud';
% shadingType = "flat";
% lighting(lightingType);
% shading(shadingType);
% camlight(camlightType);

% Bar plot
figure()
BiogasIndexArrayBar = [BiogasIndexArray(:,1) BiogasIndexArray(:,3) BiogasIndexArray(:,4) BiogasIndexArray(:,5) BiogasIndexArray(:,6) BiogasIndexArray(:,2)];

bar(BiogasIndexArray,'stacked')
grid on
ylabel('Biogas Plant Index')
legend(["Raw Materials";"Water Availability";"Cost efficacy";"Land Area";"Proximity to Residential Area";"Air Temperature"])

ax = gca;

ax.XTickLabels = {'Demra Thana','Lohajang Upazila','Municipal,Naryanganj ','Naryanganj Sadar Upazila'};
ax.XTickLabelRotation = 45;
