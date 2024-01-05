vb_Renovation.UP(   tRun(tAll),hRun(h),renovType)$exist_h_t(h,tAll) = 1;
vb_Renovation_on.UP(tRun(tAll),hRun(h),renovType)$exist_h_t(h,tAll) = 1;
vb_Renovation_dn.UP(tRun(tAll),hRun(h),renovType)$exist_h_t(h,tAll) = 1;

v_Investment.UP(tteqdyn(tteq),hRun(h),useRun,tech,techProg)$(exist_h_t(h,tteq) and tGEt(tteq,tRunStart) and tGEt(tRunEnd,tteq))
         = bigMcapacity$(map_UseTechProg(useRun,tech,techProg) and map_hTecht(h,useRun,tech,tteq));

v_InvestmentTransition.UP(tteqdyn(tteq),hRun(h),useTrans(useRun),techFROM,techTO)$(tGEt(tteq,tRunStart) and tGEt(tRunEnd,tteq))
         = bigMcapacity$(map_UseTech(useRun,techFROM) and map_UseTech(useRun,techTO) and map_hTecht(h,useRun,techTO,tteq) and map_UseTechTransition(useRun,techFROM,techTO) ) ;

v_Capacity.UP(hRun(h),useRun,tech,techProg,tRun(tAll))
         = bigMcapacity$( map_UseTechProg(useRun,tech,techProg) and map_hTecht(h,useRun,tech,tAll) );

v_InvestmentBackup.UP(tteqdyn(tteq),hRun(h),useRun,techBU(tech1),techProg)$(    exist_h_t(h,tteq) and tGEt(tteq,tRunStart) and tGEt(tRunEnd,tteq)
                                                                            and (useSH(useRun) or useWH(useRun))
                                                                            and sum(tech$map_UseTech(useRun,tech),1$(map_UseTechBU(useRun,tech,tech1)))
                                                                            and map_UseTechProg(useRun,tech1,techProg) and map_hTecht(h,useRun,tech1,tteq))
         = bigMcapacity * (1 - 1$(smin(tech$(map_UseTech(useRun,tech) and map_UseTechBU(useRun,tech,tech1)),BUshare(useRun,tech)) eq 0));

v_CapacityBackup.UP(hRun(h),useRun,techBU(tech1),techProg,tRun(tAll))$(   (useSH(useRun) or useWH(useRun))
                                                                       and sum(tech$map_UseTech(useRun,tech),1$(map_UseTechBU(useRun,tech,tech1) and BUshare(useRun,tech) gt eps ))
                                                                       and map_UseTechProg(useRun,tech1,techProg) and map_hTecht(h,useRun,tech1,tAll))
         = bigMcapacity * (1 - 1$(smin(tech$(map_UseTech(useRun,tech) and map_UseTechBU(useRun,tech,tech1)),BUshare(useRun,tech)) eq 0));

$IF %BTR%=="on" v_BTR_Capacity.UP(hRun(h),techBTR,tRun(tAll))      = capBTRmax;
$IF %BTR%=="on" v_BTR_Investment.UP(hRun(h),tteqdyn(tteq),techBTR) = capBTRmax;

v_Capacity_mCHP.UP(hRun(h),chp,techProg,tRun(tAll))$(    exist_h_t(h,tAll)
                                                     and sum((useRun,tech)$(map_UseTechProg(useRun,tech,techProg) and map_CHPtech(chp,tech) and map_hTecht(h,useRun,tech,tAll)),1))
         = mCHPmax;

$IF %GEN%=="on" v_CapacityLocalGen.UP(hRun(h),tteqdyn(tteq),techGen,techProg)$(tGEt(tteq,tRunStart) and tGEt(tRunEnd,tteq)) = LocalGenPot(h,techGen);

$IF %GEN%=="on" v_GenerationSpill.UP(  hRun(h),techGen,s(sAll),tRun(tAll)) = LocalGenPattern(h,techGen,sAll) * LocalGenPot(h,techGen);
$IF %GEN%=="on" v_Hourly_Generation.UP(hRun(h),techGen,s(sAll),tRun(tAll)) = LocalGenPattern(h,techGen,sAll) * LocalGenPot(h,techGen);

v_Theta_int.UP(hRun(h),renovType,useHeat(useRun),s,tRun(tAll))  = thetaSetPointRange("max",h,useRun,s,tAll);
v_Theta_int.LO(hRun(h),renovType,useHeat(useRun),s,tRun(tAll))  = thetaSetPointRange("min",h,useRun,s,tAll);

v_ELC_Load.UP(    hRun(h),     s(sAll),tRun(tAll)) = sum(levv, ElectricityCurve("Volume",levv,sAll,tAll));
v_ELC_Lev_Load.UP(hRun(h),levv,s(sAll),tRun(tAll)) =           ElectricityCurve("Volume",levv,sAll,tAll) ;

v_ELC_Injection.UP(hRun(h),s(sAll),tRun(tAll))
$IF %PRS%=="on"  = sum(levv, ElectricityCurve("Volume",levv,sAll,tAll));
$IF %PRS%=="off" = 0;

v_ELC_Lev_Injection.UP(hRun(h),levv,s(sAll),tRun(tAll))
$IF %PRS%=="on"  = ElectricityCurve("Volume",levv,sAll,tAll);
$IF %PRS%=="off" = 0;

* _______________________________ VARIABLE FIXES _______________________________
v_Useful_Demand_EE.FX(hRun(h),useRun,noRenov(renovType),tRun(tAll)) = 0;

v_Investment.FX(tteqdyn(tteq),hRun(h),useRun,tech,techProg)$(exist_h_t(h,tteq) and tGEt(tteq,tRunStart) and tGEt(tRunEnd,tteq)
                 and not (map_UseTechProg(useRun,tech,techProg) and map_hTecht(h,useRun,tech,tteq)) )
         = 0;

vb_InvestmentTransition.FX(tRunStart(tAll),hRun(h),useTrans(useRun),tech)$map_UseTech(useRun,tech)
         = 1 - 1$(not map_hTecht(h,useRun,tech,tAll) or sum((tteqdyn(tteq),techProg,tech1)$(map_UseTech(useRun,tech1) and not map_UseTechTransition(useRun,tech1,tech)),
                                                                 CapacityStock(tteq,h,useRun,tech1,techProg,tAll - 1)) );

v_InvestmentTransition.FX(tteqdyn(tteq),hRun(h),useTrans(useRun),techFROM,techTO)$(tGEt(tteq,tRunStart) and tGEt(tRunEnd,tteq)
                 and not (    map_UseTech(useRun,techFROM) and map_UseTech(useRun,techTO)
                          and map_hTecht(h,useRun,techTO,tteq) and map_UseTechTransition(useRun,techFROM,techTO) )  )
         = 0;

v_Hourly_Heat_Output.FX(hRun(h),useRun,renovType    ,s,tRun(tAll))$((useSH(useRun) and summer(s)) or ((useACO(useRun) and winter(s)))) = 0;
v_Hourly_Demand.FX     (hRun(h),useRun,tech,techProg,s,tRun(tAll))$((useSH(useRun) and summer(s)) or ((useACO(useRun) and winter(s)))) = 0;
v_Hourly_DemandBU.FX   (hRun(h),useRun,tech,techProg,s,tRun(tAll))$((useSH(useRun) and summer(s)) or ((useACO(useRun) and winter(s)))) = 0;