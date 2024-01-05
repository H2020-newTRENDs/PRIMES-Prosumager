SETS
         tAll              time (years)
         t(tAll)           time (years - subset)
         tRun(tAll)        running time
         tteqdyn(tAll)     equipment vintage
         ttrenov(tall)     renovation vintage
         day               characteristic days
         sAll              typical hours
         s(sAll)           typical hours (subset)
         winter(s)         typical hours during winter
         summer(s)         typical hours during summer

         h                 households
         hIndex(h)         collection of households considered
         hRun(h)           household for running the model

         use               uses in residential buildings
         useRun(use)       uses for running the model
         useThermal(use)   thermal uses in residential buildings
         useDyn(use)       dynamic uses in residential buildings
         useTrans(use)     uses with feasible technology transition
         useHeat(use)      heat uses
         useEA(use)        electric uses

         renovType         renovation type

         tech              technologies of equipment to cover the uses
         techEA(tech)      technologies for electrical appliances
         techHP(tech)      heat pump technologies
         techMain(tech)    technologies for main system
         techBU(tech)      technologies for backup unit
         techFROM(tech)    technology installed in the household
         techTO(tech)      technology replacing the existing one
         techGen           technologies for local RES generation
         techBTR           technologies for batteries
         chp               mCHP technologies

         techProg          technological progress class of the equipment
         fuel              fuels used by the equipment
         levv              levels of supply cost curves
;

ALIAS
         (tAll,tt,tt2,tteq,tteq2)
         (tRun,tRun2)
         (tech,tech1)
         (useDyn,useDyn2)
         (s,ss)
         (renovType,renovType1)
;

SETS
         tt2dyn(tt2)
;

SINGLETON SETS
         tBase(tAll)        base year (last historical year)
         tRunStart(tAll)    first year of the optimization horizon
         tRunEnd(tAll)      last year of the optimization horizon

         noRenov(renovType) no renovation - only repair and maintenance works

         useSH(use)         space heating use
         useACO(use)        air cooling use
         useWH(use)         water heating use
         useCOO(use)        cooking use

         techSol(tech)      solar technology
         techPV(techGen)    rooftop PV technology
         fuelELC(fuel)      electricity
;

SETS
         exist_h_t(h,tAll)                    household h exists at year tAll
         hourSequence(s,s)                    sequence of typical hours
         map_UseTech(use,tech)                mapping between uses and technologies of equipment
         map_UseTechProg(use,tech,techProg)   "mapping between uses,technologies and technological progress"
         map_UseTechFuel(use,tech,fuel)       fuels per use and equipment technology
         map_UseTechTransition(use,tech,tech) "mapping between uses, existing technologies and technologies replacing the existing"
         map_UseSHtech(use,tech,tech)         "mapping between uses other than SH, SH technology and technology for other uses"
         map_UseTechBU(use,tech,tech)         backup system technology per use and main system technology
         map_hTecht(h,use,tech,tAll)          "mapping between household, use, technology and year"
         map_Day(sAll,day)                    mapping of characterics hours and days
         map_CHPtech(chp,tech)                "mapping of CHP technologies to SH, WH technologies"
         map_CHPfuel(chp,fuel)                fuels per type of micro CHP unit
;

$macro tGTt(tt,tt2) tt.val >  tt2.val
$macro tGEt(tt,tt2) tt.val >= tt2.val
$macro tEQt(tt,tt2) tt.val  = tt2.val

tRunStart(tAll)             = no;
tRunEnd(tAll)               = no;
tRunStart("%horizonStart%") = yes;
tRunEnd("%horizonEnd%")     = yes;
tRun(tAll)                  = no;
tRun(tAll)$(tGEt(tAll,tRunStart) and tGEt(tRunEnd,tAll)) = yes;