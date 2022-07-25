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
%T = table(LastName,Smoker,BloodPressure);
% cell array
CA = {'text', rand(5,10,2), {'test'; 22; 33}};
M = [5 4; 3 2];
S = single([5 4; 3 2]);
CA = int8(M);
Rpush('M',M,'S',S,'CA',CA)
Rrun('M2<-M')
Rrun('S2<-S')
Rrun('CA2<-CA')
Rrun('v <- factor(c("male", "female", "female", "male"))')
%Rrun('T2<-T')
Rrun('tib <- tibble(x=1:3,y=list(1:5,1:10,1:20))');

[CA2,M2,S2,tib,v] = Rpull('CA2','M2','S2','tib','v')

Rclear
  
