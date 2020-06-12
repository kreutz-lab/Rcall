
Rinit('mice');

% struct
S = struct;
S.LastName = {'Sanchez';'Johnson';'Li';'Diaz';'Brown'};
S.BloodPressure = [124 93; 109 77; 125 83; 117 75; 122 80];
% table
LastName = {'San';'John';'L';'Di';'Bro'};
Smoker = logical([1;0;1;0;1]);
BloodPressure = [124 93; 109 NaN; 125 83; 117 75; 122 80];
T = table(LastName,Smoker,BloodPressure);
% cell array
CA = [S.LastName,LastName];
M = categorical(CA);

Rpush('M',M,'S',S,'T',T,'CA',CA)
Rrun('M2<-M')
Rrun('S<-S')
Rrun('CA<-CA')
Rrun('T<-T')
[T2,CA2,M2,S2] = Rpull('T','CA','M2','S');

Rclear
  
