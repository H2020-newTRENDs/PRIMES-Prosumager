* ______________________ USEFUL DEMAND - ANNUAL BALANCE _______________________ *
EQUATION EQ_UsefulDemand_EA(h,tech,tAll) Annual useful demand balance per household per use for electrical appliances;
EQ_UsefulDemand_EA(hRun(h),techEA(tech),tRun(tAll))$sum(useEA(useRun)$map_UseTech(useRun,tech),1)..
         sum((useEA(useRun),techProg)$(map_UseTechProg(useRun,tech,techProg) and map_hTecht(h,useRun,tech,tAll)),
                 v_Capacity(h,useRun,tech,techProg,tAll))
         =G=
         Useful_Demand_EA(h,tech,tAll)
;

EQUATION EQ_UsefulDemand_EE_1(h,use,renovType,tAll) Part of total annual useful demand for SH covered through energy efficiency measures - linearization;
EQ_UsefulDemand_EE_1(hRun(h),useSH(useRun),renovType,tRun(tAll))$(not noRenov(renovType))..
         v_Useful_Demand_EE(h,useRun,renovType,tAll)
         =G=
           sum(s$winter(s),frequency(s) * (v_Hourly_Heat_Output(h,useRun,noRenov,s,tAll) - v_Hourly_Heat_Output(h,useRun,renovType,s,tAll)))
         - (1 - vb_Renovation_on(tAll,h,renovType)) * bigMuseful
;

EQUATION EQ_UsefulDemand_EE_2(h,use,renovType,tAll) Part of total annual useful demand for SH covered through energy efficiency measures - linearization;
EQ_UsefulDemand_EE_2(hRun(h),useSH(useRun),renovType,tRun(tAll))$(not noRenov(renovType))..
         v_Useful_Demand_EE(h,useRun,renovType,tAll)
         =L=
           sum(s$winter(s),frequency(s) * (v_Hourly_Heat_Output(h,useRun,noRenov,s,tAll) - v_Hourly_Heat_Output(h,useRun,renovType,s,tAll)))
         + (1 - vb_Renovation_on(tAll,h,renovType)) * bigMuseful
;

EQUATION EQ_UsefulDemand_EE_3(h,use,renovType,tAll) Part of total annual useful demand for SH covered through energy efficiency measures - linearization;
EQ_UsefulDemand_EE_3(hRun(h),useSH(useRun),renovType,tRun(tAll))$(not noRenov(renovType))..
         v_Useful_Demand_EE(h,useRun,renovType,tAll)
         =L=
         vb_Renovation_on(tAll,h,renovType) * bigMuseful
;

* ________________________________ RENOVATION ________________________________ *
EQUATION EQ_RenovationType(h,tAll) One type of renovation can be implemented in each period;
EQ_RenovationType(hRun(h),tRun(tAll))$sum(useThermal(useRun),1)..
         sum(renovType$(not noRenov(renovType)), vb_Renovation(tAll,h,renovType))
         =L=
         1
;

EQUATION EQ_RenovationNo(h) Maximum number of renovations that can be implemented within the total horizon;
EQ_RenovationNo(hRun(h))$sum(useThermal(useRun),1)..
         sum((ttrenov,renovType)$(tGEt(ttrenov,tRunStart) and tGEt(tRunEnd,ttrenov) and not noRenov(renovType)), vb_Renovation(ttrenov,h,renovType))
         =L=
         2
;

EQUATION EQ_RenovationSequence(h,renovType,tAll,renovType,tAll) "Allow only renovations of higher efficiency if a specific renovation is implemented - first tAll: renovType vintage, second tAll: subsequent renovType vintage";
EQ_RenovationSequence(hRun(h),renovType1,ttrenov,renovType,tRun(tAll))$(sum(useThermal(useRun),1) and tGEt(tAll,ttrenov) and tGEt(ttrenov,tRunStart) and tGEt(tRunEnd,ttrenov))..
         vb_Renovation(ttrenov,h,renovType1)
         + vb_Renovation(tAll,h,renovType)$((tAll.val - ttrenov.val lt lifeRenov or noRenov(renovType)) and not sameas(renovType1,renovType))
         + vb_Renovation(tAll,h,renovType)$(tAll.val - ttrenov.val ge lifeRenov and ord(renovType) le ord(renovType1))
         =L=
         1
;

EQUATION EQ_RenovationSelection(h,renovType) Each type of renovation can only be selected once;
EQ_RenovationSelection(hRun(h),renovType)$(sum(useThermal(useRun),1) and not noRenov(renovType))..
         sum(ttrenov$(tGEt(ttrenov,tRunStart) and tGEt(tRunEnd,ttrenov)),vb_Renovation(ttrenov,h,renovType))
         =L=
         1
;
EQUATION EQ_RenovationStatus(h,renovType,tAll) Renovation status: the commitment should comply with the start-up and shut-down status;
EQ_RenovationStatus(hRun(h),renovType,tRun(tAll))$sum(useThermal(useRun),1)..
         vb_Renovation_on(tAll,h,renovType) - vb_Renovation_on(tAll - 1,h,renovType)$(tGTt(tAll,tRunStart))
         =E=
         vb_Renovation(tAll,h,renovType) - vb_Renovation_dn(tAll,h,renovType)
;

EQUATION EQ_RenovationTransition(h,renovType,tAll) Only start up or shut down may take place during one time period;
EQ_RenovationTransition(hRun(h),renovType,tRun(tAll))$sum(useThermal(useRun),1)..
         vb_Renovation(tAll,h,renovType) + vb_Renovation_dn(tAll,h,renovType)
         =L=
         1
;

EQUATION EQ_RenovationImplementation(h,tAll) Implementation of maximum one type of renovation each time period;
EQ_RenovationImplementation(hRun(h),tRun(tAll))$sum(useThermal(useRun),1)..
         sum(renovType,vb_Renovation_on(tAll,h,renovType))
         =E=
         1
;

EQUATION EQ_RenovationStart(h) Activate one type of renovation at the beginning of the optimization horizon;
EQ_RenovationStart(hRun(h))$sum(useThermal(useRun),1)..
         sum(renovType,vb_Renovation(tRunStart,h,renovType))
         =E=
         1
;

* _______________________________ INVESTMENTS ________________________________ *
* ------------------------- Equipment - main system -------------------------- *
EQUATION EQ_EquipmentExistence(tAll,h,use,tech,techProg,tAll) Existence of equipment - main system;
EQ_EquipmentExistence(tteqdyn(tteq),hRun(h),useRun,tech,techProg,tRun(tAll))$(tGEt(tRunEnd,tteq) and map_UseTechProg(useRun,tech,techProg) and map_hTecht(h,useRun,tech,tAll) and map_hTecht(h,useRun,tech,tteq) )..
         vb_Equipment(tteq,h,useRun,tech,techProg,tAll)
         =E=
           (1 - vb_Decommission(tteq,h,useRun,tech,techProg,tAll))$CapacityStock(tteq,h,useRun,tech,techProg,tAll)
         + vb_Extension(tteq,h,useRun,tech,techProg,tAll)$(CapacityStock(tteq,h,useRun,tech,techProg,tteq) and not CapacityStock(tteq,h,useRun,tech,techProg,tAll) and TechLife(useRun,tech,techProg,tteq,tAll) gt eps )
         + vb_Investment(tteq,h,useRun,tech,techProg)$(tGEt(tAll,tteq) and tGEt(tteq,tRunStart) and map_hTecht(h,useRun,tech,tteq) and TechLife(useRun,tech,techProg,tteq,tAll) eq 1 )
;

EQUATION EQ_EquipmentExistenceSH(h,tAll) Existence of SH equipment - main system;
EQ_EquipmentExistenceSH(hRun(h),tRun(tAll))$sum(useRun$useSH(useRun), 1)..
         sum((tteqdyn(tteq),tech,techProg)$(tGEt(tRunEnd,tteq) and map_UseTechProg(useSH,tech,techProg) and map_hTecht(h,useSH,tech,tAll) and map_hTecht(h,useSH,tech,tteq)),
                 vb_Equipment(tteq,h,useSH,tech,techProg,tAll))
         =E=
         1

EQUATION EQ_EquipmentInvestment(tAll,h,use,tech) Investment in equipment - main system;
EQ_EquipmentInvestment(tteqdyn(tteq),hRun(h),useDyn(useRun),tech)$(tGEt(tteq,tRunStart) and tGEt(tRunEnd,tteq) and map_UseTech(useRun,tech) and map_hTecht(h,useRun,tech,tteq))..
         sum(techProg$map_UseTechProg(useRun,tech,techProg),vb_Investment(tteq,h,useRun,tech,techProg))
         =L=
         vb_InvestmentTransition(tteq,h,useRun,tech)
;

EQUATION EQ_CapacityTotal(h,use,tech,techProg,tAll) Total available capacity of equipment per year - main system;
EQ_CapacityTotal(hRun(h),useRun,tech,techProg,tRun(tAll))$(map_UseTechProg(useRun,tech,techProg) and map_hTecht(h,useRun,tech,tAll))..
         v_Capacity(h,useRun,tech,techProg,tAll)
         =E=
           sum(tteqdyn(tteq)$(TechLife(useRun,tech,techProg,tteq,tAll) eq 1),
                 CapacityStock(tteq,h,useRun,tech,techProg,tAll) * (1 - vb_Decommission(tteq,h,useRun,tech,techProg,tAll)))
         + sum(tteqdyn(tteq)$(tGEt(tAll,tteq) and not CapacityStock(tteq,h,useRun,tech,techProg,tAll) and TechLife(useRun,tech,techProg,tteq,tAll) gt eps ),
                 TechLife(useRun,tech,techProg,tteq,tAll) * CapacityStock(tteq,h,useRun,tech,techProg,tteq) * vb_Extension(tteq,h,useRun,tech,techProg,tAll))
         + sum(tteqdyn(tteq)$(tGEt(tAll,tteq) and tGEt(tteq,tRunStart) and tGEt(tRunEnd,tteq) and map_hTecht(h,useRun,tech,tteq) and TechLife(useRun,tech,techProg,tteq,tAll) eq 1),
                 v_Investment(tteq,h,useRun,tech,techProg))
;

EQUATION EQ_CapacityMin(tAll,h,use,tech,techProg) Minimum capacity of equipment - main system;
EQ_CapacityMin(tteqdyn(tteq),hRun(h),useDyn(useRun),tech,techProg)$(tGEt(tteq,tRunStart) and tGEt(tRunEnd,tteq) and map_UseTechProg(useRun,tech,techProg) and map_hTecht(h,useRun,tech,tteq))..
         v_Investment(tteq,h,useRun,tech,techProg)
         =G=
         vb_Investment(tteq,h,useRun,tech,techProg) * CapacityMin(useRun,tech)
;

EQUATION EQ_CapacityMax(tAll,h,use,tech,techProg) Investment in equipment - main system;
EQ_CapacityMax(tteqdyn(tteq),hRun(h),useRun,tech,techProg)$(tGEt(tteq,tRunStart) and tGEt(tRunEnd,tteq) and map_UseTechProg(useRun,tech,techProg) and map_hTecht(h,useRun,tech,tteq))..
         v_Investment(tteq,h,useRun,tech,techProg)
         =L=
         vb_Investment(tteq,h,useRun,tech,techProg) * bigMcapacity
;

* ------------------------- Equipment - backup unit -------------------------- *
EQUATION EQ_CapacityBackupTotal(h,use,tech,techProg,tAll) "Total available capacity of equipment per year - backup unit";
EQ_CapacityBackupTotal(hRun(h),useRun,techBU(tech1),techProg,tRun(tAll))$(sum(techMain(tech)$(map_UseTech(useRun,tech) and BUshare(useRun,tech) gt eps and map_UseTechBU(useRun,tech,tech1)),1)
                 and map_UseTechProg(useRun,tech1,techProg) and map_hTecht(h,useRun,tech1,tAll))..
         v_CapacityBackup(h,useRun,tech1,techProg,tAll)
         =E=
         sum(tteqdyn(tteq)$(tGEt(tAll,tteq) and TechLife(useRun,tech1,techProg,tteq,tAll) eq 1 and tGEt(tteq,tRunStart) and tGEt(tRunEnd,tteq)),
                 v_InvestmentBackup(tteq,h,useRun,tech1,techProg))
         + CapacityStockBackup(h,useRun,tech1,techProg,tAll) * (1 - vb_DecommissionBU(h,useRun,tech1,techProg,tAll))
;

EQUATION EQ_CapacityBackupSize(h,use,tech,tAll) "Total available capacity of equipment per year - backup unit";
EQ_CapacityBackupSize(hRun(h),useRun,techMain(tech),tRun(tAll))$(map_UseTech(useRun,tech) and map_hTecht(h,useRun,tech,tAll) and BUshare(useRun,tech) gt eps )..
         sum((techBU(tech1),techProg)$( map_UseTechBU(useRun,tech,tech1) and map_hTecht(h,useRun,tech1,tAll) and map_UseTechProg(useRun,tech1,techProg) ),
                 v_CapacityBackup(h,useRun,tech1,techProg,tAll))
         =G=
         sum((techProg)$map_UseTechProg(useRun,tech,techProg),
                 v_Capacity(h,useRun,tech,techProg,tAll)) * BUsize(useRun,tech)
;

EQUATION EQ_EquipmentExistenceBackup(h,use,tech,techProg,tAll) "Existence of equipment - backup unit";
EQ_EquipmentExistenceBackup(hRun(h),useRun,techBU(tech),techProg,tRun(tAll))$(map_UseTechProg(useRun,tech,techProg) and map_hTecht(h,useRun,tech,tAll) )..
         vb_EquipmentBU(h,useRun,tech,techProg,tAll)
         =E=
           (1 - vb_DecommissionBU(h,useRun,tech,techProg,tAll))$CapacityStockBackup(h,useRun,tech,techProg,tAll)
         + sum(tteqdyn(tteq)$(tGEt(tAll,tteq) and tGEt(tteq,tRunStart) and tGEt(tRunEnd,tteq) and TechLife(useRun,tech,techProg,tteq,tAll) eq 1),
                 vb_InvestmentBU(tteq,h,useRun,tech,techProg))
;

EQUATION EQ_CapacityMaxBackup(h,use,tech,techProg,tAll) "Upper limit for backup unit capacity";
EQ_CapacityMaxBackup(hRun(h),useRun,techBU(tech),techProg,tRun(tAll))$(
                     (useSH(useRun) or useWH(useRun))
                 and sum(techMain(tech1)$(map_UseTech(useRun,tech1) and map_hTecht(h,useRun,tech1,tAll) and map_UseTechBU(useRun,tech1,tech)),1)
                 and map_UseTechProg(useRun,tech,techProg) and map_hTecht(h,useRun,tech,tAll) )..
         v_CapacityBackup(h,useRun,tech,techProg,tAll)
         =L=
         vb_EquipmentBU(h,useRun,tech,techProg,tAll) * bigMcapacity
;

EQUATION EQ_InvestmentMaxBackup(tAll,h,use,tech,techProg) Investment in equipment - backup unit;
EQ_InvestmentMaxBackup(tteqdyn(tteq),hRun(h),useRun,techBU(tech),techProg)$(tGEt(tteq,tRunStart) and tGEt(tRunEnd,tteq) and map_UseTechProg(useRun,tech,techProg) )..
         v_InvestmentBackup(tteq,h,useRun,tech,techProg)
         =L=
         vb_InvestmentBU(tteq,h,useRun,tech,techProg) * bigMcapacity
;

* -------------------------- Equipment - micro CHP --------------------------- *
EQUATION EQ_Capacity_mCHP(h,chp,techProg,tAll) Total available capacity of mCHP per year;
EQ_Capacity_mCHP(hRun(h),chp,techProg,tRun(tAll))$sum((useRun,tech)$((useSH(useRun) or useWH(useRun)) and map_CHPtech(chp,tech) and map_UseTechProg(useRun,tech,techProg) and map_hTecht(h,useRun,tech,tAll)),1)..
         v_Capacity_mCHP(h,chp,techProg,tAll)
         =E=
         sum((useRun,tech)$((useSH(useRun) or useWH(useRun)) and map_CHPtech(chp,tech) and map_UseTechProg(useRun,tech,techProg) and map_hTecht(h,useRun,tech,tAll)),
                 v_Capacity(h,useRun,tech,techProg,tAll))
;

* -------------- Technology & vintage restrictions for equipment ------------- *
EQUATION EQ_TechnologyDynamic(h,use,tAll) "For dynamic uses: one type of vintage, technology and technology progress class per use during each time period";
EQ_TechnologyDynamic(hRun(h),useDyn(useRun),tRun(tAll))..
         sum((tteqdyn(tteq),tech,techProg)$(tGEt(tRunEnd,tteq) and map_UseTechProg(useRun,tech,techProg) and map_hTecht(h,useRun,tech,tAll)),
                   vb_Equipment(tteq,h,useRun,tech,techProg,tAll) )
         =E=
         1
;

EQUATION EQ_TechnologyEA(h,use,tech,tAll) "For electric appliances: one vintage and technology progress class per use during each time period";
EQ_TechnologyEA(hRun(h),useEA(useRun),techEA(tech),tRun(tAll))$( map_UseTech(useRun,tech) and map_hTecht(h,useRun,tech,tAll) )..
         sum((tteqdyn(tteq),techProg)$(map_UseTechProg(useRun,tech,techProg) and tGEt(tRunEnd,tteq)),
                   vb_Equipment(tteq,h,useRun,tech,techProg,tAll) )
         =E=
         1
;

EQUATION EQ_TechnologyBackupUnit(h,use,tAll) "For uses requiring backup units: one technology progress class per use during each time period";
EQ_TechnologyBackupUnit(hRun(h),useDyn(useRun),tRun(tAll))$(
                     (useSH(useRun) or useWH(useRun))
                 and sum((techMain(tech),techBU(tech1))$(map_UseTech(useRun,tech) and map_hTecht(h,useRun,tech,tAll)),1$map_UseTechBU(useRun,tech,tech1)))..
         sum(techBU(tech)$(map_UseTech(useRun,tech) and map_hTecht(h,useRun,tech,tAll)),
                    sum(techProg$map_UseTechProg(useRun,tech,techProg),vb_EquipmentBU(h,useRun,tech,techProg,tAll))
                  - sum((tteqdyn(tteq),techMain(tech1),techProg)$(    map_UseTechBU(useRun,tech1,tech) and map_UseTechProg(useRun,tech1,techProg)
                                                and map_hTecht(h,useRun,tech1,tAll) and tGEt(tRunEnd,tteq)),
                         vb_Equipment(tteq,h,useRun,tech1,techProg,tAll)
                       )
            )
         =E=
         0
;

EQUATION EQ_EquipmentExtension(tteq,h,use,tech,techProg,tAll) Lifetime extension of existing equipment;
EQ_EquipmentExtension(tteqdyn(tteq),hRun(h),useRun,tech,techProg,tRun(tAll))$(    map_UseTechProg(useRun,tech,techProg) and map_hTecht(h,useRun,tech,tAll) and tGEt(tAll,tteq)
                                                                              and CapacityStock(tteq,h,useRun,tech,techProg,tteq) )..
         vb_Extension(tteq,h,useRun,tech,techProg,tAll)$(not CapacityStock(tteq,h,useRun,tech,techProg,tAll) and TechLife(useRun,tech,techProg,tteq,tAll))
         =L=
         +      vb_Extension(tteq,h,useRun,tech,techProg,tAll - 1)$( tGTt(tAll,tRunStart) and not CapacityStock(tteq,h,useRun,tech,techProg,tAll - 1) and TechLife(useRun,tech,techProg,tteq,tAll - 1) gt eps )
         + (1 - vb_Decommission(tteq,h,useRun,tech,techProg,tAll - 1))$(tGTt(tAll,tRunStart) and     CapacityStock(tteq,h,useRun,tech,techProg,tAll - 1) )
;

EQUATION EQ_EquipmentDecommissioning(tteq,h,use,tech,techProg,tAll) Equipment decommissioning;
EQ_EquipmentDecommissioning(tteqdyn(tteq),hRun(h),useRun,tech,techProg,tRun(tAll))$(    map_UseTechProg(useRun,tech,techProg) and map_hTecht(h,useRun,tech,tAll)
                                                                                    and tGEt(tAll,tteq) and tGTt(tAll,tRunStart)
                                                                                    and CapacityStock(tteq,h,useRun,tech,techProg,tAll)
                                                                                    and CapacityStock(tteq,h,useRun,tech,techProg,tAll - 1))..
         vb_Decommission(tteq,h,useRun,tech,techProg,tAll)
         =G=
         vb_Decommission(tteq,h,useRun,tech,techProg,tAll - 1)
;

EQUATION EQ_TechnologyExistence(h,use,tech,tAll) Existing capacity of equipment per technology - uses with feasible technology transition;
EQ_TechnologyExistence(hRun(h),useTrans(useRun),tech,tRun(tAll))$(map_UseTech(useRun,tech) and map_hTecht(h,useRun,tech,tAll))..
         vb_Technology(h,useRun,tech,tAll)
         =E=
         sum((tteqdyn(tteq),techProg)$(map_UseTechProg(useRun,tech,techProg) and tGEt(tRunEnd,tteq)),
                   vb_Equipment(tteq,h,useRun,tech,techProg,tAll))
;

EQUATION EQ_TransitionCapacity1(tAll,h,use,tech,tech) "Technology transition for space heating, air cooling, water heating, cooking";
EQ_TransitionCapacity1(tteqdyn(tteq),hRun(h),useTrans(useRun),techFROM,techTO)$(    map_UseTech(useRun,techFROM) and map_UseTech(useRun,techTO)
                                                                                and tGEt(tteq,tRunStart) and tGEt(tRunEnd,tteq)
                                                                                and map_hTecht(h,useRun,techFROM,tteq)
                                                                                and map_hTecht(h,useRun,techTO,tteq)
                                                                                and map_UseTechTransition(useRun,techFROM,techTO) )..
         v_InvestmentTransition(tteq,h,useRun,techFROM,techTO)
         =L=
         (
                   vb_Technology(h,useRun,techFROM,tteq - 1)$(tGTt(tteq,tRunStart))
                 + 1$(sameas(tteq,tRunStart) and sum((tteq2,techProg),CapacityStock(tteq2,h,useRun,techFROM,techProg,tteq - 1)))
         ) * bigMcapacity
;

EQUATION EQ_TransitionCapacity2(tAll,h,use,tech) "Capacity during technology transition for SH,ACO,WH,COO";
EQ_TransitionCapacity2(tteqdyn(tteq),hRun(h),useTrans(useRun),techTO)$(tGEt(tteq,tRunStart) and tGEt(tRunEnd,tteq) and map_UseTech(useRun,techTO) and map_hTecht(h,useRun,techTO,tteq))..
         sum(techFROM$( map_UseTech(useRun,techFROM) and map_hTecht(h,useRun,techFROM,tteq) and map_UseTechTransition(useRun,techFROM,techTO) ),
                 v_InvestmentTransition(tteq,h,useRun,techFROM,techTO))
         =E=
         sum(techProg,
                 v_Investment(tteq,h,useRun,techTO,techProg))
;

EQUATION EQ_Transition1(h,use,tech,tech,tAll) "Feasible technology transition - linearization";
EQ_Transition1(hRun(h),useTrans(useRun),techFROM,techTO,tRun(tAll))$(    map_UseTech(useRun,techFROM) and map_UseTech(useRun,techTO)
                                                                     and map_hTecht(h,useRun,techFROM,tAll) and map_hTecht(h,useRun,techTO,tAll)
                                                                     and not map_UseTechTransition(useRun,techFROM,techTO) )..
         sum(techProg,v_Capacity(h,useRun,techFROM,techProg,tAll))
         =G=
         -(1 - vb_TechnologyBan(h,tAll,useRun,techFROM,techTO)) * bigMcapacity
;

EQUATION EQ_Transition2(h,use,tech,tech,tAll) "Feasible technology transition - linearization";
EQ_Transition2(hRun(h),useTrans(useRun),techFROM,techTO,tRun(tAll))$(    map_UseTech(useRun,techFROM) and map_UseTech(useRun,techTO)
                                                                     and map_hTecht(h,useRun,techFROM,tAll) and map_hTecht(h,useRun,techTO,tAll)
                                                                     and not map_UseTechTransition(useRun,techFROM,techTO) )..
         sum(techProg,v_Capacity(h,useRun,techFROM,techProg,tAll))
         =L=
         (1 - vb_TechnologyBan(h,tAll,useRun,techFROM,techTO)) * bigMcapacity
;

EQUATION EQ_Transition3(h,use,tech,tech,tAll) "Feasible technology transition - linearization";
EQ_Transition3(hRun(h),useTrans(useRun),techFROM,techTO,tRun(tAll))$(    map_UseTech(useRun,techFROM) and map_UseTech(useRun,techTO) and tGTt(tRunEnd,tAll)
                                                                     and map_hTecht(h,useRun,techFROM,tAll) and map_hTecht(h,useRun,techTO,tAll)
                                                                     and not map_UseTechTransition(useRun,techFROM,techTO) )..
         sum(tteqdyn(tteq)$(ord(tteq) = ord(tAll) + 1), vb_InvestmentTransition(tteq,h,useRun,techTO)) * bigMcapacity
         =G=
         - vb_TechnologyBan(h,tAll,useRun,techFROM,techTO) * bigMcapacity
;

EQUATION EQ_Transition4(h,use,tech,tech,tAll) "Feasible technology transition - linearization";
EQ_Transition4(hRun(h),useTrans(useRun),techFROM,techTO,tRun(tAll))$(    map_UseTech(useRun,techFROM) and map_UseTech(useRun,techTO) and tGTt(tRunEnd,tAll)
                                                                     and map_hTecht(h,useRun,techFROM,tAll) and map_hTecht(h,useRun,techTO,tAll)
                                                                     and not map_UseTechTransition(useRun,techFROM,techTO))..
         sum(tteqdyn(tteq)$((ord(tteq) = ord(tAll) + 1) ), vb_InvestmentTransition(tteq,h,useRun,techTO)) * bigMcapacity
         =L=
         vb_TechnologyBan(h,tAll,useRun,techFROM,techTO) * bigMcapacity
;

EQUATION EQ_capMAX5(h,use,tech,tech,tAll) Feasible technology combinations;
EQ_capMAX5(hRun(h),useTrans(useRun),tech,tech1,tRun(tAll))$(   sum(usedyn2,1$usedyn2(useSH)) and map_UseTech(useRun,tech) and not useSH(useRun) and map_UseTech(useSH,tech1)
                                                            and map_hTecht(h,useRun,tech,tAll) and map_hTecht(h,useSH,tech1,tAll)
                                                            and not map_UseSHtech(useRun,tech1,tech) )..
         vb_Technology(h,useSH,tech1,tAll) + vb_Technology(h,useRun,tech,tAll)
         =L=
         1
;

* ---------------------------- Local generation ------------------------------ *
EQUATION EQ_LocalGenerationPotential(h,techGen,tAll) Site potential for local generation;
EQ_LocalGenerationPotential(hRun(h),techGen,tRun(tAll))..
         sum((tteqdyn(tteq),techProg)$(tGEt(tAll,tteq) and (tAll.val - tteq.val lt LocalGenerationLife(techGen,techProg)) and tGEt(tteq,tRunStart) and tGEt(tRunEnd,tteq)),
                 v_CapacityLocalGen(h,tteq,techGen,techProg))
         =L=
         LocalGenPot(h,techGen)
;

EQUATION EQ_LocalGenerationInvestment(h,tAll,techGen,techProg) Implementation of investment in local generation;
EQ_LocalGenerationInvestment(hRun(h),tRun(tteq),techGen,techProg)$(tGEt(tteq,tRunStart) and tGEt(tRunEnd,tteq))..
         v_CapacityLocalGen(h,tteq,techGen,techProg)
         =L=
         LocalGenPot(h,techGen) * vb_LocalGeneration(h,tteq,techGen,techProg)
;

EQUATION EQ_LocalGenerationModules(h,tAll,techGen,techProg) Total capacity of local generation;
EQ_LocalGenerationModules(hRun(h),tRun(tteq),techGen,techProg)$(tGEt(tteq,tRunStart) and tGEt(tRunEnd,tteq))..
         v_CapacityLocalGen(h,tteq,techGen,techProg)
         =E=
         LocalGenMod(techGen) * vi_LocalGenerationModules(h,tteq,techGen,techProg)
;

EQUATION EQ_LocalGenerationStatus(h,tAll,tAll,techGen) New investment in local generation;
EQ_LocalGenerationStatus(hRun(h),tteqdyn(tteq),tt2dyn(tt2),techGen)$(tGTt(tt2,tteq) and tGEt(tRunEnd,tteq) and tGEt(tt2,tRunStart) and tGEt(tRunEnd,tt2))..
         sum(techProg,vb_LocalGeneration(h,tt2,techGen,techProg))
         =L=
         1
         - sum(techProg$((tt2.val - tteq.val) lt LocalGenerationLife(techGen,techProg)),
                   vb_LocalGeneration(h,tteq,techGen,techProg)$(tGEt(tteq,tRunStart))
                 + 1$CapacityLocalGeneration(h,tteq,techGen,techProg)$(tGTt(tRunStart,tteq))
              )
;

EQUATION EQ_LocalGenerationTechnology(h,tAll,techGen) Local generation - one technology progress class during each time period;
EQ_LocalGenerationTechnology(hRun(h),tteqdyn(tteq),techGen)$(tGEt(tteq,tRunStart) and tGEt(tRunEnd,tteq))..
         sum(techProg,vb_LocalGeneration(h,tteq,techGen,techProg))
         =L=
         1
;

* -------------------------------- Batteries --------------------------------- *
EQUATION EQ_BTR_Investment(h,techBTR,tAll) BESS total capacity;
EQ_BTR_Investment(hRun(h),techBTR,tRun(tAll))..
         v_BTR_Capacity(h,techBTR,tAll)
         =E=
         sum(tteqdyn(tteq)$(tGEt(tAll,tteq) and ((tAll.val - tteq.val) lt BTRlife(techBTR)) and tGEt(tteq,tRunStart) and tGEt(tRunEnd,tteq)),
                 v_BTR_Investment(h,tteq,techBTR))
;

EQUATION EQ_BTR_InvestmentSelection(h,tAll,techBTR) BESS investment;
EQ_BTR_InvestmentSelection(hRun(h),tteqdyn(tteq),techBTR)$(tGEt(tteq,tRunStart) and tGEt(tRunEnd,tteq))..
         v_BTR_Investment(h,tteq,techBTR)
         =L=
         vb_BTR(h,tteq,techBTR) * capBTRmax
;

EQUATION EQ_BTR_CapacityMinimum(h,tAll,techBTR) BESS minimum capacity;
EQ_BTR_CapacityMinimum(hRun(h),tteqdyn(tteq),techBTR)$(tGEt(tteq,tRunStart) and tGEt(tRunEnd,tteq))..
         v_BTR_Investment(h,tteq,techBTR)
         =G=
         vb_BTR(h,tteq,techBTR) * capBTRmin
;

EQUATION EQ_BTR_Technology(h,techBTR,tAll) BESS investment decision;
EQ_BTR_Technology(hRun(h),techBTR,tRun(tAll))..
         sum(tteqdyn(tteq)$(tGEt(tAll,tteq) and ((tAll.val - tteq.val) lt BTRlife(techBTR)) and tGEt(tteq,tRunStart) and tGEt(tRunEnd,tteq)),
                 vb_BTR(h,tteq,techBTR))
         =L=
         1
;

* ________________________________ OPERATION _________________________________ *
* -------------------------------- Equipment --------------------------------- *
EQUATION EQ_Capacity(h,tech,techProg,sAll,tAll) Capacity constraint per technology and hour;
EQ_Capacity(hRun(h),tech,techProg,s,tRun(tAll))..
         sum(useHeat(useRun)$(not useSH(useRun) and map_UseTechProg(useRun,tech,techProg) and map_hTecht(h,useRun,tech,tAll)),
                 v_Hourly_Demand(h,useRun,tech,techProg,s,tAll))
         =L=
         sum(useHeat(useRun)$(map_UseTechProg(useRun,tech,techProg) and map_hTecht(h,useRun,tech,tAll) and (not useACO(useRun) or (useACO(useRun) and summer(s)))),
                 v_Capacity(h,useRun,tech,techProg,tAll))
;

EQUATION EQ_Capacity_SH(h,use,tech,techProg,sAll,tAll) Capacity constraint per hour for SH equipment - a dedicated piece of equipment should exist;
EQ_Capacity_SH(hRun(h),useSH(useRun),tech,techProg,s,tRun(tAll))$(map_UseTechProg(useRun,tech,techProg) and map_hTecht(h,useRun,tech,tAll))..
         v_Hourly_Demand(h,useRun,tech,techProg,s,tAll)
         =L=
         v_Capacity(h,useRun,tech,techProg,tAll)$winter(s)
;

EQUATION EQ_HourlyProfile(h,use,tech,techProg,sAll,tAll) Uses with inflexible profile;
EQ_HourlyProfile(hRun(h),useRun,tech,techProg,s(sAll),tRun(tAll))$(    map_UseTechProg(useRun,tech,techProg) and map_hTecht(h,useRun,tech,tAll)
                                                                   and (techEA(tech) or useCOO(useRun) or (useWH(useRun) and techSol(tech))) )..
         v_Hourly_Demand(h,useRun,tech,techProg,sAll,tAll)
         =E=
           (Inflex_profile(h,useRun,tech,techProg,sAll,tAll) * v_Capacity(h,useRun,tech,techProg,tAll) )$(techEA(tech) or useCOO(useRun)) //[kWh/appl/year] * [appl]
         + (LocalGenPattern(h,techPV,sAll)*v_Capacity(h,useRun,tech,techProg,tAll) - v_GenerationSpill_WH(h,techProg,sAll,tAll))$(useWH(useRun) and techSol(tech))
;

EQUATION EQ_BalanceHeat(h,renovType,use,tAll,s) Heat balance for space heating and air cooling;
EQ_BalanceHeat(hRun(h),renovType,useRun,tRun(tAll),s)$((useSH(useRun) and winter(s)) or (useACO(useRun) and summer(s)))..
         v_Theta_int(h,renovType,useRun,s,tAll)
         =E=
         + sum(ss$(hourSequence(s,ss) and winter(ss)), v_Theta_int(h,renovType,useRun,ss,tAll))
         + (
            + v_Hourly_Heat_Output(h,useRun,renovType,s,tAll)
            + HeatGains(h,renovType,useRun,s,tAll) * sqm(h)
            - (HeatLosses(h) * sqm(h))$useSH(useRun)
            - HeatTransferCoefficient(h,renovType,useRun,tAll) * (v_Theta_int(h,renovType,useRun,s,tAll) - ThetaExternal(s,tAll))
           ) * hours(s)
         /(c_m(h) * sqm(h))
;

EQUATION EQ_Heat_EX1(h,renovType,use,s,tAll) Select renovation;
EQ_Heat_EX1(hRun(h),renovType,useHeat(useRun),s,tRun(tAll))$((useSH(useRun) and winter(s)) or (useACO(useRun) and summer(s)) )..
           sum((tech,techProg)$(map_UseTechProg(useRun,tech,techProg) and map_hTecht(h,useRun,tech,tAll)),
                 (v_Hourly_Demand(h,useRun,tech,techProg,s,tAll) + v_Hourly_DemandBU(h,useRun,tech,techProg,s,tAll)$techBU(tech)) * efficiency(useRun,tech,techProg,tAll))
         =L=
         v_Hourly_Heat_Output(h,useRun,renovType,s,tAll)
         + (1 - vb_Renovation_on(tAll,h,renovType)) * bigMheat(h)
;

EQUATION EQ_Heat_EX2(h,renovType,use,s,tAll) Select renovation;
EQ_Heat_EX2(hRun(h),renovType,useHeat(useRun),s,tRun(tAll))$((useSH(useRun) and winter(s)) or (useACO(useRun) and summer(s)))..
           sum((tech,techProg)$(map_UseTechProg(useRun,tech,techProg) and map_hTecht(h,useRun,tech,tAll)),
                 (v_Hourly_Demand(h,useRun,tech,techProg,s,tAll) + v_Hourly_DemandBU(h,useRun,tech,techProg,s,tAll)$techBU(tech)) * efficiency(useRun,tech,techProg,tAll))
         =G=
         v_Hourly_Heat_Output(h,useRun,renovType,s,tAll)
         - (1 - vb_Renovation_on(tAll,h,renovType)) * bigMheat(h)
;

EQUATION EQ_BalanceWH(h,use,tAll,s) Heat balance for WH;
EQ_BalanceWH(hRun(h),useWH(useRun),tRun(tAll),s)..
         sum((tech,techProg)$(map_UseTechProg(useRun,tech,techProg) and map_hTecht(h,useRun,tech,tAll)),
                 (v_Hourly_Demand(h,useRun,tech,techProg,s,tAll) + v_Hourly_DemandBU(h,useRun,tech,techProg,s,tAll)$techBU(tech)) * efficiency(useRun,tech,techProg,tAll))
         =E=
         (  Cp_water * kJ2kWh * (v_Theta_int(h,noRenov,useRun,s,tAll) - ThetaWater(s,tAll)) * DHW_demand(h,tAll)
          + DHW_heatLosses(h,tAll) * sqm(h)) / sum(ss,frequency(ss))
;

EQUATION EQ_BackupEnergy(h,use,tech,tAll) Operation of backup unit;
EQ_BackupEnergy(hRun(h),useHeat(useRun),techBU(tech),tRun(tAll))$(    map_UseTech(useRun,tech) and map_hTecht(h,useRun,tech,tAll)
                                                                  and sum((techMain(tech1))$(    map_UseTech(useRun,tech1) and map_hTecht(h,useRun,tech1,tAll)
                                                                                             and map_UseTechBU(useRun,tech1,tech) and BUshare(useRun,tech1) gt eps),1) )..
           sum(techProg$(map_hTecht(h,useRun,tech,tAll) and map_UseTechProg(useRun,tech,techProg) ),
                 sum(s$((not useSH(useRun) or (useSH(useRun) and winter(s))) and (not useACO(useRun) or (useACO(useRun) and summer(s)))),
                         frequency(s)*v_Hourly_DemandBU(h,useRun,tech,techProg,s,tAll)))
         - sum((techMain(tech1),techProg)$(    map_hTecht(h,useRun,tech1,tAll) and map_UseTechProg(useRun,tech1,techProg)
                                           and BUshare(useRun,tech1) lt 1 and map_UseTechBU(useRun,tech1,tech) ),
                 sum(s$((not useSH(useRun) or (useSH(useRun) and winter(s))) and (not useACO(useRun) or (useACO(useRun) and summer(s)))),
                         frequency(s)*v_Hourly_Demand(h,useRun,tech1,techProg,s,tAll)) * BUshare(useRun,tech1) / (1 - BUshare(useRun,tech1)) )
         =E=
         0
;

EQUATION EQ_BackupCapacity(h,use,tech,techProg,sAll,tAll) Capacity limit of backup unit;
EQ_BackupCapacity(hRun(h),useHeat(useRun),techBU(tech),techProg,s,tRun(tAll))$(   (sameas(useRun,useWH) or (useSH(useRun) and winter(s)) or (useACO(useRun) and summer(s)))
                                                                               and map_hTecht(h,useRun,tech,tAll) and map_UseTechProg(useRun,tech,techProg) )..
         v_Hourly_DemandBU(h,useRun,tech,techProg,s,tAll)
         =L=
         v_CapacityBackup(h,useRun,tech,techProg,tAll)
;

* ---------------------------- Local generation ------------------------------ *
EQUATION EQ_ELC_LocalGeneration(h,techGen,sAll,tAll) Hourly capacity constraint for local RES generation;
EQ_ELC_LocalGeneration(hRun(h),techGen,s,tRun(tAll))..
         (v_Hourly_Generation(h,techGen,s,tAll) + v_GenerationSpill(h,techGen,s,tAll)) * frequency(s)
         =E=
         LocalGenPattern(h,techGen,s) * frequency(s)
         * [
             sum((techProg,tteqdyn(tteq))$(tGEt(tAll,tteq) and (tAll.val - tteq.val lt LocalGenerationLife(techGen,techProg)) and tGEt(tteq,tRunStart) and tGEt(tRunEnd,tteq)),
                         v_CapacityLocalGen(h,tteq,techGen,techProg) * (1 - LocalGenerationDegradation(techGen)*(tAll.val - tteq.val + (TimeStep - 1)/2)))
           + sum((techProg,tteq)$(tGEt(tAll,tteq) and (tAll.val - tteq.val lt LocalGenerationLife(techGen,techProg)) and tGEt(tRunStart,tteq)),
                         CapacityLocalGeneration(h,tteq,techGen,techProg) * (1 - LocalGenerationDegradation(techGen)*(tAll.val - tteq.val + (TimeStep - 1)/2)))
           ]
;

* -------------------------------- Batteries --------------------------------- *
EQUATION EQ_BTR_Capacity(h,techBTR,sAll,tAll) Hourly capacity constraint for BESS;
EQ_BTR_Capacity(hRun(h),techBTR,s(sAll),tRun(tAll))..
         frequency(sAll)*(v_BTR_Charge(h,techBTR,sAll,tAll) + v_BTR_Discharge(h,techBTR,sAll,tAll))
         =L=
         frequency(sAll) * v_BTR_Capacity(h,techBTR,tAll)
;

EQUATION EQ_BTR_Charge(h,techBTR,sAll,tAll) Hourly operation of BESS - charging;
EQ_BTR_Charge(hRun(h),techBTR,s(sAll),tRun(tAll))..
         frequency(sAll) * v_BTR_Charge(h,techBTR,sAll,tAll)
         =L=
         frequency(sAll) * vb_BTR_Charge(h,techBTR,sAll,tAll) * capBTRmax
;

EQUATION EQ_BTR_Discharge(h,techBTR,sAll,tAll) Hourly operation of BESS - discharging;
EQ_BTR_Discharge(hRun(h),techBTR,s(sAll),tRun(tAll))..
         frequency(sAll) * v_BTR_Discharge(h,techBTR,sAll,tAll)
         =L=
         frequency(sAll) * vb_BTR_Discharge(h,techBTR,sAll,tAll) * capBTRmax
;

EQUATION EQ_BTR_ChargeMin(h,techBTR,sAll,tAll) Hourly operation of BESS - minimum charge capacity;
EQ_BTR_ChargeMin(hRun(h),techBTR,s(sAll),tRun(tAll))..
         frequency(sAll) * v_BTR_Charge(h,techBTR,sAll,tAll)
         =G=
         frequency(sAll) * vb_BTR_Charge(h,techBTR,sAll,tAll) * chargeBTRmin
;

EQUATION EQ_BTR_DischargeMin(h,techBTR,sAll,tAll) Hourly operation of BESS - minimum discharge capacity;
EQ_BTR_DischargeMin(hRun(h),techBTR,s(sAll),tRun(tAll))..
         frequency(sAll) * v_BTR_Discharge(h,techBTR,sAll,tAll)
         =G=
         frequency(sAll) * vb_BTR_Discharge(h,techBTR,sAll,tAll) * chargeBTRmin
;

EQUATION EQ_BTR_StatusOn(h,techBTR,sAll,tAll) Hourly operation of BESS - ON;
EQ_BTR_StatusOn(hRun(h),techBTR,s(sAll),tRun(tAll))..
         frequency(sAll) * vb_BTR_On(h,techBTR,sAll,tAll)
         =E=
         frequency(sAll) * (vb_BTR_Charge(h,techBTR,sAll,tAll) + vb_BTR_Discharge(h,techBTR,sAll,tAll))
;

EQUATION EQ_BTR_DailyEquilibrium(h,techBTR,day,tAll) Daily battery equilibrium;
EQ_BTR_DailyEquilibrium(hRun(h),techBTR,day,tRun(tAll))..
         Sum(s(sAll)$(map_Day(sAll,day)), frequency(sAll) * v_BTR_Discharge(h,techBTR,sAll,tAll))
         =E=
         BTRefficiency(tAll) * Sum(s(sAll)$(map_Day(sAll,day)), frequency(sAll) * v_BTR_Charge(h,techBTR,sAll,tAll))
;

EQUATION EQ_BTR_Cycles(h,techBTR,day,tAll) "Stored energy constraint for BESS - charging/discharging cycles per year";
EQ_BTR_Cycles(hRun(h),techBTR,day,tRun(tAll))..
         Sum(s(sAll)$(map_Day(sAll,day)), frequency(sAll) * v_BTR_Charge(h,techBTR,sAll,tAll))
         =L=
         sum(s(sAll)$map_Day(sAll,day),  frequency(sAll) * cyclesBTR / 365 * hoursBTR * v_BTR_Capacity(h,techBTR,tAll) )/24
;

EQUATION EQ_BTR_SOC(h,techBTR,sAll,tAll) Hourly energy equilibrium for BESS;
EQ_BTR_SOC(hRun(h),techBTR,s,tRun(tAll))..
         frequency(s) * v_BTR_SOC(h,techBTR,s,tAll)
         =E=
         frequency(s) *
         sum(ss$hourSequence(s,ss),
                   v_BTR_SOC(h,techBTR,ss,tAll))
                 + (BTRefficiency(tAll) * v_BTR_Charge(h,techBTR,s,tAll) - v_BTR_Discharge(h,techBTR,s,tAll) - v_BTR_SelfDischarge(h,techBTR,s,tAll))
                   * sum(ss$hourSequence(s,ss),hours(ss))
;

EQUATION EQ_BTR_SelfDischarge1(h,techBTR,sAll,tAll) Self-discharge of BESS when idle - linearization;
EQ_BTR_SelfDischarge1(hRun(h),techBTR,s,tRun(tAll))..
         frequency(s) * v_BTR_SelfDischarge(h,techBTR,s,tAll)
         =L=
         frequency(s) * (
         SelfDischargeBTR * v_BTR_Capacity(h,techBTR,tAll) * hoursBTR / ( sum(ss,frequency(ss))/ 12)
         + bigMBTR * vb_BTR_On(h,techBTR,s,tAll))
;

EQUATION EQ_BTR_SelfDischarge2(h,techBTR,sAll,tAll) Self-discharge of BESS when idle - linearization;
EQ_BTR_SelfDischarge2(hRun(h),techBTR,s(sAll),tRun(tAll))..
         frequency(sAll) * v_BTR_SelfDischarge(h,techBTR,sAll,tAll)
         =G=
         frequency(sAll)* (
         SelfDischargeBTR * v_BTR_Capacity(h,techBTR,tAll) * hoursBTR / ( sum(ss,frequency(ss))/ 12)
         - bigMBTR * vb_BTR_On(h,techBTR,sAll,tAll))
;

EQUATION EQ_BTR_SelfDischarge3(h,techBTR,sAll,tAll) Self-discharge of BESS when idle - linearization;
EQ_BTR_SelfDischarge3(hRun(h),techBTR,s(sAll),tRun(tAll))..
         frequency(sAll) * v_BTR_SelfDischarge(h,techBTR,sAll,tAll)
         =L=
         frequency(sAll) * bigMBTR * (1 - vb_BTR_On(h,techBTR,sAll,tAll))
;

EQUATION EQ_BTR_SelfDischarge4(h,techBTR,sAll,tAll) Self-discharge of BESS when idle - linearization;
EQ_BTR_SelfDischarge4(hRun(h),techBTR,s(sAll),tRun(tAll))..
         frequency(sAll) * v_BTR_SelfDischarge(h,techBTR,sAll,tAll)
         =G=
         - frequency(sAll) * bigMBTR * (1 - vb_BTR_On(h,techBTR,sAll,tAll))
;

EQUATION EQ_btrDoD(h,techBTR,sAll,tAll) Hourly depth of discharge for BESS;
EQ_btrDoD(hRun(h),techBTR,s(sAll),tRun(tAll))..
         frequency(sAll) * v_BTR_DoD(h,techBTR,sAll,tAll)
         =E=
         frequency(sAll) * (  SOC_max * hoursBTR
                            * sum(tteqdyn(tteq)$(tGEt(tAll,tteq) and ((tAll.val - tteq.val) lt BTRlife(techBTR)) and tGEt(tteq,tRunStart) and tGEt(tRunEnd,tteq)),
                                 v_BTR_Investment(h,tteq,techBTR) * BTRcapacityFade(tteq,tAll,sAll))
                            - v_BTR_SOC(h,techBTR,sAll,tAll))
;

EQUATION EQ_btrSOC_max(h,techBTR,sAll,tAll) BESS state of charge upper limit;
EQ_btrSOC_max(hRun(h),techBTR,s(sAll),tRun(tAll))..
         frequency(sAll) * v_BTR_SOC(h,techBTR,sAll,tAll)
         =L=
         frequency(s) * SOC_max * hoursBTR
                      * sum(tteqdyn(tteq)$(tGEt(tAll,tteq) and ((tAll.val - tteq.val) lt BTRlife(techBTR)) and tGEt(tteq,tRunStart) and tGEt(tRunEnd,tteq)),
                                 v_BTR_Investment(h,tteq,techBTR) * BTRcapacityFade(tteq,tAll,sAll))
;

EQUATION EQ_btrSOC_min(h,techBTR,sAll,tAll) BESS state of charge lower limit;
EQ_btrSOC_min(hRun(h),techBTR,s(sAll),tRun(tAll))..
         frequency(sAll) * v_BTR_SOC(h,techBTR,sAll,tAll)
         =G=
         frequency(sAll) * SOC_min * v_BTR_Capacity(h,techBTR,tAll) * hoursBTR
;

* -------------------------------- micro CHP --------------------------------- *
EQUATION EQ_mCHP_BAL(h,sAll,tAll) mCHP hourly operation;
EQ_mCHP_BAL(hRun(h),s(sAll),tRun(tAll))$sum((useRun,tech,chp)$((useSH(useRun) or useWH(useRun)) and map_CHPtech(chp,tech) and map_UseTech(useRun,tech) and map_hTecht(h,useRun,tech,tAll)),1)..
         sum((chp,techProg), v_mCHP_Heat(h,chp,techProg,sAll,tAll))
         =G=
         sum((chp,useRun,tech,techProg)$((useSH(useRun) or useWH(useRun)) and map_CHPtech(chp,tech) and map_UseTechProg(useRun,tech,techProg) and map_hTecht(h,useRun,tech,tAll)),
              (v_Hourly_Demand(h,useRun,tech,techProg,sAll,tAll) * efficiency(useRun,tech,techProg,tAll) ))
;

EQUATION EQ_mCHP_CAP(h,chp,techProg,sAll,tAll) mCHP hourly capacity constraint;
EQ_mCHP_CAP(hRun(h),chp,techProg,s(sAll),tRun(tAll))$sum((useRun,tech)$((useSH(useRun) or useWH(useRun)) and map_CHPtech(chp,tech) and map_UseTechProg(useRun,tech,techProg) and map_hTecht(h,useRun,tech,tAll)),1)..
         v_mCHP_Heat(h,chp,techProg,sAll,tAll) * frequency(sAll)
         =L=
         v_Capacity_mCHP(h,chp,techProg,tAll) * frequency(sAll)
;

EQUATION EQ_mCHPfuel(h,chp,techProg,tAll) mCHP fuel consumption;
EQ_mCHPfuel(hRun(h),chp,techProg,tRun(tAll))$sum((useRun,tech)$((useSH(useRun) or useWH(useRun)) and map_CHPtech(chp,tech) and map_UseTechProg(useRun,tech,techProg) and map_hTecht(h,useRun,tech,tAll)),1)..
         sum(fuel$(map_CHPfuel(chp,fuel) and sum((useRun,tech)$((useSH(useRun) or useWH(useRun)) and map_CHPtech(chp,tech) and map_UseTechProg(useRun,tech,techProg) and map_hTecht(h,useRun,tech,tAll)),1)),
                 v_mCHP_fuel(h,chp,techProg,fuel,tAll))
         =E=
         Heatrate(chp)* [sum(s(sAll),frequency(s) * (v_mCHP_Electricity(h,chp,techProg,sAll,tAll) - LossCoefficient(chp) * v_mCHP_Heat(h,chp,techProg,sAll,tAll)))]
;

EQUATION EQ_mCHPhel(h,chp,techProg,sAll,tAll) mCHP heat to electricity ratio;
EQ_mCHPhel(hRun(h),chp,techProg,s(sAll),tRun(tAll))$sum((useRun,tech)$((useSH(useRun) or useWH(useRun)) and map_CHPtech(chp,tech) and map_UseTechProg(useRun,tech,techProg) and map_hTecht(h,useRun,tech,tAll)),1)..
         frequency(sAll) * v_mCHP_Heat(h,chp,techProg,s,tAll)
         =E=
         frequency(sAll) * C(chp,techProg) * v_mCHP_Electricity(h,chp,techProg,sAll,tAll)
;

* ___________________________ ELECTRICITY BALANCE ____________________________ *
EQUATION EQ_ELC_balance(h,sAll,tAll)  Electricity balance per hour;
EQ_ELC_balance(hRun(h),s(sAll),tRun(tAll))..
         [sum((useRun,tech,techProg)$(    map_UseTechFuel(useRun,tech,fuelELC) and map_UseTechProg(useRun,tech,techProg) and map_hTecht(h,useRun,tech,tAll)
                                      and (not useSH(useRun) or (useSH(useRun) and winter(s))) and (not useACO(useRun) or (useACO(useRun) and summer(s)))),
                 v_Hourly_Demand(h,useRun,tech,techProg,sAll,tAll)
             )
         + sum((useRun,techBU(tech1),techProg)$(   (sameas(useRun,useSH) or sameas(useRun,useWH)) and (not useSH(useRun) or (useSH(useRun) and winter(s))) and (not useACO(useRun) or (useACO(useRun) and summer(s)))
                                                and map_UseTechFuel(useRun,tech1,fuelELC) and map_UseTechProg(useRun,tech1,techProg) and map_hTecht(h,useRun,tech1,tAll)),
                 v_Hourly_DemandBU(h,useRun,tech1,techProg,sAll,tAll)
             )
$IF %BTR%=="on" + sum(techBTR,v_BTR_Charge(h,techBTR,sAll,tAll))
         ] * frequency(sAll)
         =E=
         (
$IF %GEN%=="on"    sum(techGen, v_Hourly_Generation(h,techGen,sAll,tAll))
                 + v_ELC_Load(h,sAll,tAll)
$IF %GEN%=="on"  - v_ELC_Injection(h,sAll,tAll)
$IF %BTR%=="on"  + sum(techBTR,v_BTR_Discharge(h,techBTR,sAll,tAll))
                 + sum((chp,techProg)$sum((useRun,tech)$((useSH(useRun) or useWH(useRun)) and map_CHPtech(chp,tech) and map_UseTechProg(useRun,tech,techProg) and map_hTecht(h,useRun,tech,tAll)),1),
                         v_mCHP_Electricity(h,chp,techProg,sAll,tAll))
         ) * frequency(sAll)
;

EQUATION EQ_ELC_imports(h,sAll,tAll) Electricity imports;
EQ_ELC_imports(hRun(h),s(sAll),tRun(tAll))..
         v_ELC_Load(h,sAll,tAll)
         =L=
$IF %GEN%=="on"  vb_Imports(h,sAll,tAll) *
         LineRating
;

EQUATION EQ_ELC_exports(h,sAll,tAll) Electricity exports;
EQ_ELC_exports(hRun(h),s(sAll),tRun(tAll))..
         v_ELC_Injection(h,sAll,tAll)
         =L=
         (1 - vb_Imports(h,sAll,tAll)) * LineRating
;

EQUATION EQ_ELC_Year(h,tAll) Annual constraint for electricity - the prosumer should be net importer;
EQ_ELC_Year(hRun(h),tRun(tAll))..
         sum(s(sAll),
                 (+ v_ELC_Load(h,sAll,tAll)
$IF %GEN%=="on"  - v_ELC_Injection(h,sAll,tAll)
                 ) * frequency(sAll))
         =G=
         0
;

EQUATION EQ_ELC_Lev_Load(h,sAll,tAll);
EQ_ELC_Lev_Load(hRun(h),s(sAll),tRun(tAll))..
         sum(levv,v_ELC_Lev_Load(h,levv,sAll,tAll)) * frequency(sAll)
         =E=
         v_ELC_Load(h,sAll,tAll) * frequency(sAll)
;

EQUATION EQ_ELC_Lev_Injection(h,sAll,tAll);
EQ_ELC_Lev_Injection(hRun(h),s(sAll),tRun(tAll))..
         sum(levv,v_ELC_Lev_Injection(h,levv,sAll,tAll)) * frequency(sAll)
         =E=
         v_ELC_Injection(h,sAll,tAll) * frequency(sAll)
;

* ___________________________ OBJECTIVE FUNCTION _____________________________ *
EQUATION EQ_TotCost Objective function (total cost);
EQ_TotCost..
         v_cost
         =E=
         sum{hRun(h),
                 sum[tRun(tAll),
                         cint(tAll) *
                         (
                         - (
* POLICIES _____________________________________________________________________
* Energy Efficiency Value ------------------------------------------------------
                              EnergyEfficiencyValue(tAll) * sum(renovType$(not noRenov(renovType)),
                                 v_Useful_Demand_EE(h,useSH,renovType,tAll))
* Heat Pump Value for SH -------------------------------------------------------
                            + HeatPumpValue(tAll)
                                 * sum((techHP(tech),techProg,winter(s))$(map_UseTechFuel(useSH,tech,fuelELC) and map_UseTechProg(useSH,tech,techProg) and map_hTecht(h,useSH,tech,tAll)),
                                         frequency(s) * v_Hourly_Demand(h,useSH,tech,techProg,s,tAll))
                           )$sum(useRun$useSH(useRun),1)
* Renewable value for electricity generated from local RES ---------------------
$IF %GEN%=="on"          - RenewablesValue(tAll) * sum((techGen,s),frequency(s) * v_Hourly_Generation(h,techGen,s,tAll) )
* RENOVATION ___________________________________________________________________
* investment cost --------------------------------------------------------------
                         +   sqm(h)
                           * sum(renovType,
                                   (RenovationCost(h,renovType,tAll) + RenovationHiddenCost(h,renovType,tAll))
                                 * sum(ttrenov$(tGEt(tAll,ttrenov) and tGEt(ttrenov,tRunStart) and tGEt(tRunEnd,ttrenov) and ((not sameas(renovType,noRenov) and (tAll.val - ttrenov.val lt lifeRenov)) or sameas(renovType,noRenov))),
                                         RenovationCRF(h,ttrenov) * vb_Renovation(ttrenov,h,renovType)) )$sum(useThermal(useRun),1)
* EQUIPMENT ____________________________________________________________________
* capital cost -----------------------------------------------------------------
                         + sum((useRun,tech,techProg,tteqdyn(tteq))$( (useDyn(useRun) or useEA(useRun)) and map_UseTechProg(useRun,tech,techProg) and map_hTecht(h,useRun,tech,tAll)
                                                                     and tGEt(tAll,tteq) and tGEt(tRunEnd,tteq) and ((tAll.val - tteq.val) lt TechLifeEcon(useRun,tech)) ),
                                   (  1$useEA(useRun) + MAVT(useRun,tech,tAll)$(not useEA(useRun)) ) * TechCRF(h,useRun,tech) * TechCost(useRun,tech,techProg,tteq)
* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ new investments
                                 * (   ( v_Investment(tteq,h,useRun,tech,techProg)$(tGEt(tteq,tRunStart) and TechLife(useRun,tech,techProg,tteq,tAll) eq 1 )
                                        + CapacityStock(tteq,h,useRun,tech,techProg,tteq) )$(TechLife(useRun,tech,techProg,tteq,tAll) eq 1)
* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ lifetime extension of existing equipment
                                     + (CapacityStock(tteq,h,useRun,tech,techProg,tteq) * TechLife(useRun,tech,techProg,tteq,tAll) * vb_Extension(tteq,h,useRun,tech,techProg,tAll))$(TechLife(useRun,tech,techProg,tteq,tAll) lt 1)
                                   )  )
* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ backup units
                         + sum((useRun,techBU(tech1))$((useDyn(useRun) or useEA(useRun)) and (sameas(useRun,useWH) or sameas(useRun,useSH)) and map_UseTech(useRun,tech1) and map_hTecht(h,useRun,tech1,tAll)),
                                         TechCRF(h,useRun,tech1)
                                         * sum(techProg$map_UseTechProg(useRun,tech1,TechProg),
                                                 sum(tteqdyn(tteq)$(tGEt(tAll,tteq) and tGEt(tRunEnd,tteq) and ((tAll.val - tteq.val) lt TechLifeEcon(useRun,tech1))),
                                                           TechCost(useRun,tech1,techProg,tteq) * v_InvestmentBackup(tteq,h,useRun,tech1,techProg))
                                                         + TechCost(useRun,tech1,techProg,tBase) * CapacityStockBackup(h,useRun,tech1,techProg,tBase) ) )
* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ hidden cost due to technology transition
                         + sum((tteqdyn(tteq),useTrans(useRun),techFROM,techTO)$(    tGEt(tteq,tRunStart) and tGEt(tRunEnd,tteq) and ((tAll.val - tteq.val) lt TechLifeEcon(useRun,techTO))
                                                                                 and map_hTecht(h,useRun,techTO,tteq) and map_UseTech(useRun,techFROM) and map_UseTech(useRun,techTO) and map_UseTechTransition(useRun,techFROM,techTO)),
                                         (1$useEA(useRun) + MAVT(useRun,techTO,tAll)$(not useEA(useRun))) * TechCRF(h,useRun,techTO) * TechTransitionCost(useRun,techFROM,techTO) * v_InvestmentTransition(tteq,h,useRun,techFROM,techTO) )

* local RES generation capital cost --------------------------------------------
$IF %GEN%=="on"          + sum((techGen,techProg,tteqdyn(tteq))$(tGEt(tAll,tteq) and ((tAll.val - tteq.val) lt LocalGenerationLifeEcon(techGen,techProg)) and tGEt(tteq,tRunStart) and tGEt(tRunEnd,tteq)),
$IF %GEN%=="on"                  LocalGenerationMAVT(techGen,tAll) * LocalGenerationCRF(h,techGen,techProg) * LocalGenerationCost(techGen,techProg,tteq) * v_CapacityLocalGen(h,tteq,techGen,techProg) )
$IF %GEN%=="on"          + sum((techGen,techProg,tteq)$(tGEt(tAll,tteq) and ((tAll.val - tteq.val) lt LocalGenerationLifeEcon(techGen,techProg)) and tGEt(tRunStart,tteq)),
$IF %GEN%=="on"                  LocalGenerationCRF(h,techGen,techProg) * LocalGenerationCost(techGen,techProg,tteq) * CapacityLocalGeneration(h,tteq,techGen,techProg) )
* Batteries capital cost -------------------------------------------------------
$IF %BTR%=="on"          + sum((techBTR,tteqdyn(tteq))$(tGEt(tAll,tteq) and ((tAll.val - tteq.val) lt BTRlifeEcon(techBTR)) and tGEt(tteq,tRunStart) and tGEt(tRunEnd,tteq)),
$IF %BTR%=="on"                    BTR_MAVT(techBTR,tAll) * (BTR_CRF(h,techBTR) * BTRcost(techBTR,tteq) * v_BTR_Investment(h,tteq,techBTR) * hoursBTR
$IF %BTR%=="on"                  + BTRcostFix(techBTR,tteq) * v_BTR_Investment(h,tteq,techBTR) * hoursBTR ))
* Fixed O&M cost ---------------------------------------------------------------
                         + sum((useRun,tech,techProg)$(map_UseTechProg(useRun,tech,techProg) and map_hTecht(h,useRun,tech,tAll)),
                                  TechCostOM(h,useRun,tech,techProg) * v_Capacity(h,useRun,tech,techProg,tAll) * (1$useEA(useRun) + MAVT(useRun,tech,tAll)$(not useEA(useRun))) )
                         + sum((useRun,techBU(tech1),techProg)$((sameas(useRun,useSH) or sameas(useRun,useWH)) and map_UseTechProg(useRun,tech1,techProg) and map_hTecht(h,useRun,tech1,tAll)),
                                  TechCostOM(h,useRun,tech1,techProg) * v_CapacityBackup(h,useRun,tech1,techProg,tAll) )
$IF %GEN%=="on"          + sum((techGen,techProg,tteqdyn(tteq))$(tGEt(tAll,tteq) and ((tAll.val - tteq.val) lt LocalGenerationLife(techGen,techProg)) and tGEt(tteq,tRunStart) and tGEt(tRunEnd,tteq)),
$IF %GEN%=="on"                   LocalGenerationCostFix(techGen,techProg,tteq) * v_CapacityLocalGen(h,tteq,techGen,techProg) * LocalGenerationMAVT(techGen,tAll))
$IF %BTR%=="on"          + sum((techBTR,tteqdyn(tteq))$(tGEt(tAll,tteq) and ((tAll.val - tteq.val) lt BTRlifeEcon(techBTR)) and tGEt(tteq,tRunStart) and tGEt(tRunEnd,tteq)),
$IF %BTR%=="on"                   BTRcostFix(techBTR,tteq) * v_BTR_Investment(h,tteq,techBTR) * hoursBTR * BTR_MAVT(techBTR,tAll) )
* fuel cost --------------------------------------------------------------------
                         + sum((useRun,tech,techProg)$(    (useDyn(useRun) or useEA(useRun)) and map_UseTechProg(useRun,tech,techProg) and map_hTecht(h,useRun,tech,tAll)
                                                       and not sum(chp,1$(map_CHPtech(chp,tech) and (useSH(useRun) or useWH(useRun)))) ),
                                    (MAVF(useRun,tech,tAll)$(not useEA(useRun)) + 1$useEA(useRun))
                                  * sum(s,frequency(s) * sum(fuel$(map_UseTechFuel(useRun,tech,fuel) and not sameas(fuel,fuelELC)), (FuelCost(fuel,tAll) + EmissionsFactor(fuel) * CarbonValue(tAll)))
                                                                  * (  v_Hourly_Demand(h,useRun,tech,techProg,s,tAll)$(not useThermal(useRun))
                                                                     + v_Hourly_Demand(h,useRun,tech,techProg,s,tAll)$(useSH(useRun) and winter(s))
                                                                     + v_Hourly_Demand(h,useRun,tech,techProg,s,tAll)$(useACO(useRun) and summer(s)) ) ) )
                         + sum((useRun,techBU(tech1),techProg)$(    (useDyn(useRun) or useEA(useRun)) and map_UseTechProg(useRun,tech1,techProg) and map_hTecht(h,useRun,tech1,tAll)
                                                                and not sum(chp,1$(map_CHPtech(chp,tech1) and (useSH(useRun) or useWH(useRun)))) ),
                                    (MAVF(useRun,tech1,tAll)$(not useEA(useRun)) + 1$useEA(useRun))
                                  * sum(s, frequency(s) * sum(fuel$(map_UseTechFuel(useRun,tech1,fuel) and not sameas(fuel,fuelELC)), (FuelCost(fuel,tAll) + EmissionsFactor(fuel) * CarbonValue(tAll))) * v_Hourly_DemandBU(h,useRun,tech1,techProg,s,tAll)))
                         + sum(s,frequency(s) * sum(levv,
                                                           ElectricityCurve("Price-Load",levv,s,tAll)      * v_ELC_Lev_Load(h,levv,s,tAll)
$IF %GEN%=="on"                                          - ElectricityCurve("Price-Injection",levv,s,tAll) * v_ELC_Lev_Injection(h,levv,s,tAll)
                                                   )
                              )
                         + sum((useRun,chp,fuel)$((useSH(useRun) or useWH(useRun)) and map_CHPfuel(chp,fuel)),
                               sum(tech$map_CHPtech(chp,tech), 0.5 * MAVF(useRun,tech,tAll)) * (FuelCost(fuel,tAll) + EmissionsFactor(fuel) * CarbonValue(tAll)) * sum(techProg,v_mCHP_fuel(h,chp,techProg,fuel,tAll)) )
* Generation curtailment cost --------------------------------------------------
                         + GenerationSpillCost(tAll) * sum(s, frequency(s) * ((1 - 1$(not sum((techProg,tteq),CapacityStock(tteq,h,useWH,techSol,techProg,tAll)))) * sum(techProg$(map_hTecht(h,useWH,techSol,tAll) and map_UseTechProg(useWH,techSol,techProg)), v_GenerationSpill_WH(h,techProg,s,tAll))
                                                                              + sum(techGen,v_GenerationSpill(h,techGen,s,tAll))) )
                         )
                    ]
            }
;

MODEL Prosumager
/
EQ_UsefulDemand_EA
EQ_UsefulDemand_EE_1, EQ_UsefulDemand_EE_2, EQ_UsefulDemand_EE_3

EQ_RenovationType
EQ_RenovationNo
EQ_RenovationSequence
EQ_RenovationSelection
EQ_RenovationStatus
EQ_RenovationTransition
EQ_RenovationImplementation
EQ_RenovationStart

EQ_EquipmentExistence
EQ_EquipmentExistenceSH
EQ_EquipmentInvestment
EQ_CapacityTotal
EQ_CapacityMin
EQ_CapacityMax

EQ_CapacityBackupTotal
EQ_CapacityBackupSize
EQ_EquipmentExistenceBackup
EQ_CapacityMaxBackup
EQ_InvestmentMaxBackup

EQ_Capacity_mCHP

EQ_TechnologyDynamic
EQ_TechnologyEA
EQ_TechnologyBackupUnit
EQ_EquipmentExtension
EQ_EquipmentDecommissioning

EQ_TechnologyExistence
EQ_TransitionCapacity1
EQ_TransitionCapacity2

EQ_Transition1,EQ_Transition2,EQ_Transition3,EQ_Transition4

$IF %GEN%=="on" EQ_LocalGenerationPotential
$IF %GEN%=="on" EQ_LocalGenerationInvestment
$IF %GEN%=="on" EQ_LocalGenerationModules
$IF %GEN%=="on" EQ_LocalGenerationStatus
$IF %GEN%=="on" EQ_LocalGenerationTechnology

$IF %BTR%=="on" EQ_BTR_Investment
$IF %BTR%=="on" EQ_BTR_InvestmentSelection
$IF %BTR%=="on" EQ_BTR_CapacityMinimum
$IF %BTR%=="on" EQ_BTR_Technology

EQ_Capacity
EQ_Capacity_SH
EQ_HourlyProfile

EQ_BalanceHeat
EQ_BalanceWH
EQ_Heat_EX1
EQ_Heat_EX2

EQ_BackupEnergy
EQ_BackupCapacity

$IF %GEN%=="on" EQ_ELC_LocalGeneration

$IF %BTR%=="on" EQ_BTR_Capacity
$IF %BTR%=="on" EQ_BTR_StatusOn, EQ_BTR_Charge, EQ_BTR_ChargeMin, EQ_BTR_Discharge, EQ_BTR_DischargeMin
$IF %BTR%=="on" EQ_BTR_DailyEquilibrium, EQ_BTR_Cycles, EQ_BTR_SOC
$IF %BTR%=="on" EQ_BTR_SelfDischarge1,EQ_BTR_SelfDischarge2,EQ_BTR_SelfDischarge3,EQ_BTR_SelfDischarge4
$IF %BTR%=="on" EQ_btrDoD, EQ_btrSOC_max, EQ_btrSOC_min

EQ_mCHP_BAL
EQ_mCHP_CAP
EQ_mCHPfuel
EQ_mCHPhel

EQ_ELC_imports
$IF %GEN%=="on" EQ_ELC_exports
$IF %GEN%=="on" EQ_ELC_Year
EQ_ELC_balance

EQ_ELC_Lev_Load
$IF %GEN%=="on" EQ_ELC_Lev_Injection

EQ_TotCost
/
;