PARAMETERS
         frequency(sAll)                                    Frequency of characteristic hour s
         hours(sAll)                                        # of consecutive hours represented by one typical hour [hours]
         sqm(h)                                             Floor area per household [m^2]

         Useful_Demand_EA(h,tech,tAll)                      Useful demand for electrical appliances [# of electrical appliances]
         CapacityStock(tAll,h,use,tech,techProg,tAll)       "Capacity of existing stock per equipment vintage, use, technology and technology progress class - main system [kW or # of electrical appliances]"
         CapacityStockBackup(h,use,tech,techProg,tAll)      "Capacity of existing stock per equipment vintage, use, technology and technology progress class - backup unit [kW or # of electrical appliances]"
         CapacityMin(use,tech)                              Minimum capacity of equipment per use and technology [kW]
         efficiency(use,tech,techProg,tAll)                 "Equipment efficiency per use, technology, technology progress class [-]"
         CapacityLocalGeneration(h,tAll,techGen,techProg)   Existing rooftop PV capacity [kW]
         BUsize(use,tech)                                   Size of backup unit [% of main system capacity]
         BUshare(use,tech)                                  Share of hours per annum the backup system works [%]
         Inflex_profile(h,use,tech,techProg,sAll,tAll)      Demand profile of inflexible uses - normalized [-]

         LocalGenPattern(h,techGen,sAll)                    Pattern for local RES generation - normalized [-]
         LocalGenPot(h,techGen)                             Local RES potential per installation site and technology [kW]
         LocalGenMod(techGen)                               Local RES capacity of one module - i.e. minimum installed capacity [kW]

         thetaSetPointRange(*,h,use,sAll,tAll)              Temperature set-point range per use and hour [Celsius]
         SolarIrradiation(sAll,tAll)                        Solar irradiation on surfaces in heating and cooling season per characteristic hour [kWh per sqm per hour]
         ThetaExternal(sAll,tAll)                           Temperature of external environment [Celsius]
         HeatGains(h,renovType,use,sAll,tAll)               Heat gains (solar heat load and internal heat gains) during the heating season [kWh per m^2 per hour]
         HeatLosses(h)                                      Heat losses of the space heating distribution and storage system [kWh per m^2 per hour]
         HeatTransferCoefficient(h,renovType,use,tAll)      "Coefficient for heat transfer by transmission, ventilation [kW per K]"
         c_m(h)                                             Internal heat capacity per reference area [kWh per m^2 per K]
         ThetaWater(sAll,tAll)                              Inlet water temperature [Celsius]
         DHW_demand(h,tAll)                                 Annual demand for domestic hot water [lt]
         DHW_heatLosses(h,tAll)                             Annual domestic hot water system heat losses [kWh per m^2]

         TechLife(use,tech,techProg,tAll,tAll)              Equipment service life [% of nominal capacity]
         TechLifeEcon(use,tech)                             Economic lifetime of equipment [years]
         TechCRF(h,use,tech)                                Capital recovery factor per use and technology
         TechCost(use,tech,techProg,tAll)                   Investment cost for technologies [euros per kW or euros per appliance]
         TechCostOM(h,use,tech,techProg)                    Operation and maintenance cost for technologies [euros per kW or euros per appliance]
         TechTransitionCost(use,tech,tech)                  Hidden cost factor for technology transition [-]
         MAVF(use,tech,tAll)                                Market acceptance factor for fuels
         MAVT(use,tech,tAll)                                Market acceptance factor for technologies

         LocalGenerationLife(techGen,techProg)              Technical lifetime of local RES generation [years]
         LocalGenerationLifeEcon(techGen,techProg)          Economic lifetime of local RES generation [years]
         LocalGenerationDegradation(techGen)                Annual degradation for local generation units output [-]
         LocalGenerationCRF(h,techGen,techProg)             Capital recovery factor per local generation technology
         LocalGenerationCost(techGen,techProg,tAll)         Capital cost of local RES generation [euros per kW]
         LocalGenerationCostFix(techGen,techProg,tAll)      Fixed cost of local RES generation [euros per kW]
         LocalGenerationMAVT(techGen,tAll)                  Market acceptance factor for local RES [-]

         BTRlife(techBTR)                                   BESS technical lifetime [years]
         BTRlifeEcon(techBTR)                               BESS economic lifetime [years]
         BTRcapacityFade(tAll,tAll,sAll)                    BESS capacity fade due to calendar aging [%]
         BTRefficiency(tAll)                                BESS efficiency [%]
         BTR_CRF(h,techBTR)                                 Capital recovery factor for BESS
         BTRcost(techBTR,tAll)                              Capital cost for BESS [euros per kWh]
         BTRcostFix(techBTR,tAll)                           Fixed cost for BESS [euros per kWh]
         BTR_MAVT(techBTR,tAll)                             Market acceptance factor for BESS [-]

         LineRating                                         Capacity of the power connection to the utility line

         C(chp,techProg)                                    Power-to-heat ratio for mCHP technologies [kWth per kWe]
         Heatrate(chp)                                      mCHP heatrate [kWh fuel per kWe]
         LossCoefficient(chp)                               Loss coefficient for mCHP - loss of electricity generation per unit of extracted heat [kWhe per kWhth]

         EmissionsFactor(fuel)                              Emissions factor per fuel [ton CO2 per kWh]

         FuelCost(fuel,tAll)                                Fuel cost [euros per kWh]
         GenerationSpillCost(tAll)                          Local generation spillage cost [euros per kWh]
         ElectricityCurve(*,levv,sAll,tAll)                 "Stepwise function for electricity exchange with the grid [price in euros per kWh/h, volume in kWh per hour]"
         RenovationCost(h,renovType,tAll)                   Renovation cost - engineering [euros per m^2]
         RenovationHiddenCost(h,renovType,tAll)             Renovation cost - hidden [euros per m^2]
         RenovationCRF(h,tAll)                              Capital recovery factor for renovation per household

         RenewablesValue(tAll)                              Renewable value for electricity generation produced by RES [euros per kWh]
         CarbonValue(tAll)                                  Carbon value [euros per ton CO2]
         HeatPumpValue(tAll)                                Renewable value for heat pumps [euros per kWh]
         EnergyEfficiencyValue(tAll)                        Energy efficiency value [euros per kWh]

         cint(tAll)                                         Compound interest factors

         bigMheat(h)                                        big-M formulation for operation of uses affected by the renovation after renovation is implemented
;

SCALARS
         TimeStep                                           Projection horizon time step [# of years between two consecutive years in the projection horizon]
         lifeRenov                                          Economic lifetime of investment in renovation
         Cp_water                                           Specific heat capacity of water [kJ per kg per K]
         kJ2kWh                                             Conversion factor for kJ to kWh [kWh per kJ]
         mCHPmax                                            Maximum capacity of mCHP [kWth]
         SOC_min                                            Minimum state of charge of BESS [%]
         SOC_max                                            Maximum state of charge of BESS [%]
         SelfDischargeBTR                                   Self-discharge rate [% of nominal energy content per month]
         chargeBTRmin                                       "Minimum charge/discharge capacity for BESS"
         hoursBTR                                           Hours to fully charge each kW of installed capacity [h]
         cyclesBTR                                          Maximum number of charging cycles per year
         capBTRmax                                          Maximum charging capacity [kW]
         capBTRmin                                          Minimum charging capacity [kW]
         bigMcapacity                                       big-M for equipment capacity constraints
         bigMuseful                                         big-M for SH useful demand linearization
         bigMBTR                                            big-M for BESS self-discharge linearization
;

POSITIVE VARIABLES
         v_Useful_Demand_effective(h,use,tAll)              Part of useful demand covered through actual energy consumption by operating the equipment in the building [kWh]
         v_Useful_Demand_EE(h,use,renovType,tAll)           Part of useful demand covered through energy efficiency measures [kWh]

         v_Capacity(h,use,tech,techProg,tAll)               Equipment capacity - main system [kW or # of appliances]
         v_CapacityBackup(h,use,tech,techProg,tAll)         Equipment capacity - backup unit [kW]
         v_Investment(tteq,h,use,tech,techProg)             Investment in new equipment - main system [kW or # of appliances]
         v_InvestmentBackup(tteq,h,use,tech,techProg)       Investment in new equipment - backup unit [kW]
         v_InvestmentTransition(tteq,h,use,tech,tech)       Transition in investment in new equipment for uses with feasible technology transition [kW]
         v_Hourly_Demand(h,use,tech,techProg,sAll,tAll)     Hourly final energy demand of equipment [kWh per hour]
         v_Hourly_DemandBU(h,use,tech,techProg,sAll,tAll)   Hourly final energy demand of backup equipment [kWh per hour]
         v_Hourly_Heat_Output(h,use,renovType,sAll,tAll)    "Hourly heating/cooling output of heating/cooling equipment per renovation type for uses affected by the selected renovation [kWh per hour]"

         v_Capacity_mCHP(h,chp,techProg,tAll)               Capacity of micro CHP unit [kWth]

         v_CapacityLocalGen(h,tAll,techGen,techProg)        Local RES generation investment [kW]
         v_Hourly_Generation(h,techGen,sAll,tAll)           Hourly generation of local resources used [kWh per hour]
         v_GenerationSpill(h,techGen,sAll,tAll)             Hourly generation of local resources spilled [kWh per hour]

         v_ELC_Load(h,sAll,tAll)                            Energy exchange with the grid [kWh per hour]
         v_ELC_Injection(h,sAll,tAll)                       Energy exchange with the grid [kWh per hour]
         v_ELC_Lev_Load(h,levv,sAll,tAll)                   Stepwise function for electricity exchange with the grid - load [kWh per hour]
         v_ELC_Lev_Injection(h,levv,sAll,tAll)              Stepwise function for electricity exchange with the grid - injection [kWh per hour]

         v_Theta_int(h,renovType,use,sAll,tAll)             Internal temperature [Celsius]
         v_GenerationSpill_WH(h,techProg,sAll,tAll)         Hourly solar energy spilled - water heating [kWh per hour]

         v_BTR_Investment(h,tAll,techBTR)                   "Nominal charging/discharging power of battery storage investment [kW]"
         v_BTR_Capacity(h,techBTR,tAll)                     "Total nominal charging/discharging power of battery storage [kW]"
         v_BTR_Charge(h,techBTR,sAll,tAll)                  Battery charging capacity [kW]
         v_BTR_Discharge(h,techBTR,sAll,tAll)               Battery discharging capacity [kW]
         v_BTR_SOC(h,techBTR,sAll,tAll)                     Battery state of charge [kWh]
         v_BTR_SelfDischarge(h,techBTR,sAll,tAll)           Battery self-discharge when idle [kWh per hour]
         v_BTR_DoD(h,techBTR,sAll,tAll)                     Battery depth of discharge [kWh]

         v_mCHP_Electricity(h,chp,techProg,sAll,tAll)       Electricity generation of mCHP per hour [kWh per hour]
         v_mCHP_Heat(h,chp,techProg,sAll,tAll)              Heat generation of mCHP per hour [kWh per hour]
         v_mCHP_fuel(h,chp,techProg,fuel,tAll)              Fuel consumption of mCHP per hour [kWh per hour]
;

BINARY VARIABLES
         vb_Renovation(tAll,h,renovType)                    "Implementation of renovation, aka 'start-up'"
         vb_Renovation_on(tAll,h,renovType)                 "Active renovation, aka 'commitment'"
         vb_Renovation_dn(tAll,h,renovType)                 "Inactive renovation, aka 'shut-down', as a higher level one is implemented"
         vb_InvestmentTransition(tAll,h,use,tech)           Investment in new equipment in uses with feasible technology transition
         vb_Equipment(tAll,h,use,tech,techProg,tAll)        Existing equipment - main system
         vb_EquipmentBU(h,use,tech,techProg,tAll)           Existing equipment - backup unit
         vb_Investment(tAll,h,use,tech,techProg)            Investment in new equipment - main system
         vb_InvestmentBU(tAll,h,use,tech,techProg)          Investment in new equipment - backup unit
         vb_Extension(tAll,h,use,tech,techProg,tAll)        Lifetime extension of existing equipment (1 if the equipment is retained)
         vb_Decommission(tAll,h,use,tech,techProg,tAll)     Premature decommissioning of existing equipment (1 if the equipment is decommissioned) - main system
         vb_DecommissionBU(h,use,tech,techProg,tAll)        Premature decommissioning of existing equipment (1 if the equipment is decommissioned) - backup unit
         vb_Technology(h,use,tech,tAll)                     Existing technology per use per year
         vb_TechnologyBan(h,tAll,use,tech,tech)             "Infeasible technology transition - first tech: technology installed in the household, second tech: technology replacing the existing one"
         vb_LocalGeneration(h,tAll,techGen,techProg)        Implementation of investment in local generation
         vb_BTR(h,tAll,techBTR)                             Implementation of investment in BESS
         vb_BTR_Charge(h,techBTR,sAll,tAll)                 Indicates whether the battery is charging
         vb_BTR_Discharge(h,techBTR,sAll,tAll)              Indicates whether the battery is discharging
         vb_BTR_On(h,techBTR,sAll,tAll)                     Indicates whether the battery operates
         vb_Imports(h,sAll,tAll)                            Indicates whether the household imports electricity from the distribution grid
;

INTEGER VARIABLES
         vi_LocalGenerationModules(h,tAll,techGen,techProg) "Number of local generation modules, i.e. solar panels"
;

VARIABLE
         v_cost                                             Total cost (objective function)
;