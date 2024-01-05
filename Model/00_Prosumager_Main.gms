$TITLE Prosumager model - version 1.0 - 05/01/2024 (originally developed within NewTrends T5.3: https://newtrends2020.eu/publications/)

$ontext
* ____________________________________________________________________________ *
The prosumager model describes the decision-making process of individual
households regarding:
 - investments in appliances (timing, technology);
 - investments in local generation units (timing, type, capacity);
 - investments in electricity storage (timing, technology, capacity);
 - investments in energy efficiency/renovation (timing, deepness);
 - the hourly operation of the equipment and the Battery Energy Storage System
   (BESS);
 - the interaction with the electricity grid
in order to maximize total revenues minus costs (= revenues from selling excess
energy to the grid + perceived utility due to energy efficiency - investment
cost in equipment & energy efficiency measures - fixed O&M cost - variable
costs) considering the following core constraints:
 - final energy demand is determined through selection of specific technology in
   order to meet the useful demand per end use
 - capacity constraints and operational rules of equipment, local generation
   units, BESS
 - electricity demand is covered through local generation and by electricity
   from the grid
 - the household is a price taker

COMMAND LINE PARAMETERS
 GEN: on/off flag for including decision about local generation units
 PRS: on/off flag for allowing electricity injection into the grid
 BTR: on/off flag for allowing investment in batteries
 horizonStart, horizonEnd: optimization horizon start & end
 ModelPath: model folder path
* ____________________________________________________________________________ *
$offtext

$eolcom //

$include %ModelPath%01_Prosumager_Sets.gms
$include %ModelPath%02_Prosumager_Definitions.gms
$include %ModelPath%03_Prosumager_Model.gms

file fx2;
put fx2;
loop(hIndex,
         hRun(h) = no;
         hRun(hIndex) = yes;
         loop(hRun,put_utility 'msgLog' / ' --------------------- ' hRun.tl:4 ' --------------------- '/ ;);

$include %ModelPath%04_Prosumager_VarAttributes.gms

         SOLVE Prosumager using MIP minimizing v_cost;
);