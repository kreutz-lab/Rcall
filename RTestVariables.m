Rinit('tibble');

% struct
S = struct;
S.LastName = {'Sanchez';'Johnson';'Li';'Diaz';'Brown'};
S.BloodPressure = [124 93; 109 77; 125 83; 117 75; 122 80];
S.Smoker.true = [1;1;1;0;1];
S.Smoker.false = [0;0;0;1;0];

% table
LastName = {'San';'John';'L';'Di';'Bro'};
Smoker = logical([1;0;1;0;1]);
BloodPressure = [124 93; 109 NaN; 125 83; 117 75; 122 80];
T = table(LastName,Smoker,BloodPressure);
% cell array
CA = {'text', rand(5,10,2), {'test'; 22; 33}};
M = [5 4; 3 2];

Rpush('M',M,'S',S,'T',T,'CA',CA)
Rrun('M2<-M')
Rrun('S2<-S')
Rrun('CA2<-CA')
Rrun('T2<-T')
Rrun('tib <- tibble(x=1:3,y=list(1:5,1:10,1:20))');

[T2,CA2,M2,S2,tib] = Rpull('T2','CA2','M2','S2','tib')

Rclear
  
