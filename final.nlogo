__includes [ "utilities.nls" ] ; uploading the map into netlogo and marking known locations on the map
extensions [ csv ]

;breeds for agents
breed [citizens citizen]
breed [NDMAs NDMA]
breed [SDMAs SDMA]
breed [DDMAs DDMA]
breed [KCs KC]
breed [PBCs PBC]
breed [NGOs NGO]
breed [IMDs IMD]
breed [KSEBs KSEB]
;mangroves as agents
breed [mangroves mangrove]
;jobs -other profession
breed [jobs job]
;dams
breed [dams dam]
;jobs -fisherfolk
breed [backwater_jobs backwater_job]
; as SDMA, DDMA and KC must go to communities but still remain at the locations, one agent is created at each of its locations
breed [sdma_officers sdma_officer]
breed [ddma_officers ddma_officer]
breed [kc_officers kc_officer]
breed [constructions construction] ; the constructions made by the private building corporation
breed [kseb_officers kseb_officer] ; mainly in contact with SDMA and since SDMA has more elements in the schedule, in the model KSEB_officer goes to SDMA
;relief centers
breed [r_centers r_center]

globals [
  ; variables for the map
  topleftx
  toplefty
  bottomrightx
  bottomrighty
  ;keeping track of time
  timenow ; hh:mm, reset after 23:50 -> 00:00
  minutenow ; minute counter, reset at 60
  hournow ; hour counter, reset at 24
  daynow ; day of the week, reset after 7 days
  weeknow ; week of the year, reset after 52 weeks
  yearnow ; end at a specific year
  workday ; day 1 to 5 of the week
  starttime ; starttime of a working day
  endtime ; endtime of working day
  ;mangrove locations
  mangrove_x
  mangrove_y
  backwater_x
  backwater_y
  ngo_x
  ngo_y
  job_x
  job_y
  kseb_x
  kseb_y
  sdma_x
  sdma_y
  ddma_x
  ddma_y
  kc_x
  kc_y
  mangrovelist
  powerlist
  location_chosen
  heavyrain
  relief_location
  target_walk_max
  initiative_member
  permission
  danger_zone
  ;KPIs
  economic_dimension ; transaction costs
  increment_energy ; increment in initiative energy
  current_number ; to retain the number of initiative_members before more individuals join
  social_capacity ; individual capacity as a result of initiatives
  transaction_cost
  relief
  vulnerability_info
  info_value ; representing the rest of the information dissemination excluding vulnerability mapping and forecast infomation
  forecast_info
  environmental_dimension
  technical_capacity
  opportunistic ; opportunistic or not
  power_to

]

patches-own [
  pcategory ; string holding the category of the location, default is 0
  pcolorPatch; string with the color to each type of path in the csv file #Added by group
  plocation
]

mangroves-own[
  mangrovelocation
]

dams-own [
  damlocation
]

NDMAs-own [
  worklocation_NDMA
  ;assumes that it has the required skillset
  ;assumes the power allocated is unchanged since the over arching body
]

SDMAs-own [
  worklocation_SDMA
  corruption
  willingness_risk
  public_priority
  urge_support
]

DDMAs-own [
  worklocation_DDMA
  corruption ; boolean property
  willingness_risk
  public_priority
  urge_support
]

KCs-own [
  worklocation_KC
  corruption ; boolean property
  willingness_risk
  public_priority
  urge_support
]

PBCs-own [
worklocation_PBC
]

constructions-own [
environmental_damage

]

KSEBs-own[
kseb_location
]

kseb_officers-own [
homelocation
profit_minded
target_dam
schedule
schedule-counter
target
target_walk
willingness_risk
]

IMDs-own[
worklocation_IMD
]

NGOs-own[
worklocation_NGO
interest_collab ; interest to collaborate with local initiative
]

jobs-own [
jobslocation
]

backwater_jobs-own [
worklocation_backwater
]

sdma_officers-own [
 homelocation
 skillset   ; the skillset possessed that contributes to better information collection from other agents
 corruption ; boolean property
 schedule
 schedule-counter
 target
 target_walk
 target_NDMA
 target_IMD
 target_KSEB
 target_DDMA
 willingness_risk
 public_priority
]

ddma_officers-own [
 homelocation
 skillset   ; the skillset possessed that contributes to better information collection from other agents
 corruption ; boolean property
 schedule;
 schedule-counter
 target
 target_walk
 target_SDMA
 target_KC
  willingness_risk
  public_priority
]

kc_officers-own [
 homelocation
 skillset   ; the skillset possessed that contributes to better information collection from other agents
 corruption ; boolean property
 schedule;
 schedule-counter
 target
 target_walk
 target_DDMA
 training
 willingness_risk
 public_priority
]
citizens-own [
  capacity_individual ; individual capacity to withstand the disaster
  is_above65 ; elderly or not
  homelocation ; home patch
  targetlocation
  is_fisherfolk ; fisherfolk or not
  schedule
  target_job
  target_walk
  schedule-counter
  target
  inf_socialproof ; influenced by social proofing
  capacity_from_initiative
  urge_continue
]
to setup
  clear-all
  loadData
  setupMap
  set initiative_member brown
  set starttime 1
  set endtime 6
;;; create mangrove locations
  ask n-of 4 (patches with [pcategory = "Mangrove"])[
    sprout-mangroves 1 [
      set color green
      set shape "leaf"
      set size 20
      set label who
      set label-color black
      ask patches in-radius 50 [ set pcolor 39 ] ]] ;demarcating the ecologically sensitive areas
;;; create job locations
  ask n-of 4 (patches with [pcategory = "Job"])[
    sprout-jobs 1 [
      set color magenta
      set shape "house"
      set size 20
      set label who
      set label-color black
      set jobslocation patch-here]]
;;; create NGO locations
  ask n-of 4 (patches with [pcategory = "NGO"])[
    sprout-NGOs 1 [
      set color brown
      set shape "house"
      set size 20
      set label who
      set label-color black ]]
;;; create backwater job location
   ask n-of 2 (patches with [pcategory = "Backwater"])[
    sprout-backwater_jobs 1 [
      set color blue
      set shape "square"
      set size 20
      set label who
      set label-color black
      set worklocation_backwater patch-here
      ask patches in-radius 50 [ set pcolor 39 ] ]] ;demarcating the ecologically sensitive areas
;;; create NDMA
  ask n-of 1 (patches with [pcolor = 9 ])[
  sprout-NDMAs 1 [
    set shape "house"
    set size 20
    set color violet
    set label who
    set label-color black
    set worklocation_NDMA patch-here]]
;;; create SDMA
   ask n-of 1 (patches with [pcolor = 9 ])[
   sprout-SDMAs 1 [
    set shape "house"
    set size 20
    set color orange
    set label who
    set label-color black
    set sdma_x xcor
    set sdma_y ycor
    set worklocation_SDMA patch-here]]
;;; create DDMA
   ask n-of 1 (patches with [pcolor = 9 ])[
   sprout-DDMAs 1 [
    set shape "house"
    set size 20
    set color blue
    set label who
    set label-color black
    set ddma_x xcor
    set ddma_y ycor
    set worklocation_DDMA patch-here]]
;;; create KC
   ask n-of 1 (patches with [pcolor = 9 ])[
   sprout-KCs 1 [
    set shape "house"
    set size 20
    set color grey
    set label who
    set label-color black
    set kc_x xcor
    set kc_y ycor
    set worklocation_KC patch-here]]
;;; create PBC
   ask n-of 1 (patches with [pcolor = 9 ])[
   sprout-PBCs 1 [
    set shape "house"
    set size 20
    set color black
    set label who
    set label-color black
    set worklocation_PBC patch-here ] ]
;;; create IMD
   ask n-of 1 (patches with [pcolor = 9 ])[
   sprout-IMDs 1 [
    set shape "house"
    set size 20
    set color yellow
    set label who
    set label-color black
    set worklocation_IMD patch-here]]
;;; create KSEB
   ask n-of 1 (patches with [pcategory = "KSEB"])[
    sprout-KSEBs 1 [
      set color pink
      set shape "house"
      set size 20
      set label who
      set label-color black
      set kseb_location patch-here  ]]
;;; create KSEB officer
  create-kseb_officers 1 [
  setxy kseb_x kseb_y
  set shape "person"
  set size 15
  set color pink
  set homelocation patch-here
  set target_dam min-one-of dams [distance myself] ]
;;; create sdma officer
  create-sdma_officers 1 [
  setxy sdma_x sdma_y
  set shape "person"
  set size 15
  set color orange
  set homelocation patch-here
  set target_NDMA min-one-of NDMAs [distance myself]
  set target_IMD min-one-of IMDs [distance myself]
  set target_KSEB min-one-of KSEBs [distance myself]
  set target_DDMA min-one-of DDMAs [distance myself] ]
;;;; create ddma officer
  create-ddma_officers 1 [
  setxy ddma_x ddma_y
  set shape "person"
  set size 15
  set color blue
  set homelocation patch-here
  set target_SDMA min-one-of SDMAs [distance myself]
  set target_KC min-one-of KCs [distance myself]]
;;;; create KC officer
  create-kc_officers 1 [
  setxy kc_x kc_y
  set shape "person"
  set size 15
  set color grey
  set homelocation patch-here
  set target_DDMA min-one-of DDMAs [distance myself]]
;;; create dam
  create-dams 1 [
  setxy 806 532
  set shape "square"
  set size 15
  set color red
  set damlocation patch-here]
;; create citizens
ask n-of Lever_Citizens (patches with [pcolor = 9 ])[
    sprout-citizens 1 [
    ;setxy random-xcor random-ycor
    set size 8
    set shape "person"
    set color green
    set homelocation patch-here
    ifelse random 100 < 4 ; 3% fisherfolk
     [ set is_fisherfolk 1
       set target_job min-one-of backwater_jobs [distance myself]]
     [set is_fisherfolk 0
      set target_job min-one-of jobs [distance myself]]
    if random 100 < 14 ; 13% elderly
          [set is_above65 1]]] ; local knowledge
 ask citizens [
    if is_above65 = 1 and is_fisherfolk = 1
        [set capacity_individual 10]
    if is_above65 = 0 and is_fisherfolk = 1
        [set capacity_individual 15]
    if is_above65 = 1 and is_fisherfolk = 0
        [set capacity_individual 20]
    if is_above65 = 0 and is_fisherfolk = 0
        [set capacity_individual 25]
  ]
;;; Power allocation
set powerlist []
ask SDMAs [
    set powerlist fput Lever_power_SDMA powerlist
  ]
ask DDMAs [
    set powerlist fput Lever_power_DDMA powerlist
  ]
ask KCs [
    set powerlist fput Lever_power_KC powerlist
  ]

if (item 0 powerlist > item 1 powerlist and item 0 powerlist > item 2 powerlist) or (item 1 powerlist = item 2 powerlist and item 1 powerlist < item 0 powerlist) or (item 2 powerlist = item 1 powerlist and item 2 powerlist < item 0 powerlist) ; decision maker : KMC
[set power_to 0
 ]
if (item 0 powerlist = item 1 powerlist and item 0 powerlist > item 2 powerlist) or (item 1 powerlist = item 0 powerlist and item 1 powerlist > item 2 powerlist) ; decision makers : KMC and DDMA
[set power_to 1
 ]
if (item 0 powerlist = item 2 powerlist and item 0 powerlist > item 1 powerlist) or (item 2 powerlist = item 0 powerlist and item 2 powerlist > item 1 powerlist) ; decision makers: KMC and SDMA
[set power_to 2
 ]
if (item 0 powerlist = item 1 powerlist and item 0 powerlist < item 2 powerlist) or (item 1 powerlist = item 0 powerlist and item 1 powerlist < item 2 powerlist) or (item 2 powerlist > item 1 powerlist and item 2 powerlist > item 0 powerlist ) ; decision maker : SDMA
[set power_to 3
  ]
if (item 0 powerlist = item 2 powerlist and item 0 powerlist < item 1 powerlist) or  (item 1 powerlist > item 0 powerlist and item 1 powerlist > item 2 powerlist) or (item 2 powerlist = item 0 powerlist and item 2 powerlist < item 1 powerlist) ; decision maker: DDMA
[set power_to 4
  ]
if (item 1 powerlist = item 2 powerlist and item 1 powerlist > item 0 powerlist) or (item 2 powerlist = item 1 powerlist and item 2 powerlist > item 0 powerlist) ; decision makers: DDMA and SDMA
[set power_to 5
  ]
if item 0 powerlist = item 1 powerlist = item 2 powerlist ; equal power
[set power_to 6
  ]

;;; Time
  set minutenow 0 ; minute counter, reset at 60
  set hournow 0 ; hour counter, reset at 24
  set daynow 1 ; day of the week, reset after 7 days
  set weeknow 1 ; week of the year, reset after 52 weeks
  set yearnow 1 ; end at year 4
  set workday 1

  reset-ticks
end

to go
;;;; initial settings for the different levels of the government
;;; budget setting :
; vulnerability mapping 5 units
; supporting initiatives 10 units
; training conducted by KMC 5 units
; providing skillset 5 units
; creating relief centers 10 units
; maintenance of relief centers 5 units
; maintenance of dams 5 units

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; monitor overall resilience;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;; social dimension : information sharing, local knowledge (information directly from the local communities) and capacity development via initiatives
set social_capacity round ((sum [capacity_from_initiative] of citizens) / count citizens)
; info value: social information - the information shared outside the technical activities

;;;;;;;;;;;;;;;; economic dimension
set economic_dimension transaction_cost

;;;;;;;;;;;;;;; technical dimension
; relief centers created
; vulnerability information: information collected during vulnerability mapping
; forecast information: representing the set up of the early warning system
; dam maintenance
set technical_capacity round ((sum [capacity_individual] of citizens) / count citizens)
;;;;;;;;;;;;;;;environmental dimension
set environmental_dimension max list round ((sum [environmental_damage] of constructions)) 0
;;;;;;;;;;;;;;; institutional dimension
; from MAIA conceptual model

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if daynow = 1 and hournow = 0 and minutenow = 0 [
ask SDMAs
    [ifelse random-float 1 < 0.6 [set corruption 1][set corruption 0]
    set willingness_risk random-float 1
    set public_priority random-float 1]
ask DDMAs
    [ifelse random-float 1 < 0.6 [set corruption 1][set corruption 0]
    set willingness_risk random-float 1
    set public_priority random-float 1]
ask KCs
    [ifelse random-float 1 < 0.6 [set corruption 1][set corruption 0]
    set willingness_risk random-float 1
    set public_priority random-float 1]
ask SDMA_officers
    [ifelse random-float 1 < 0.6 [set corruption 1][set corruption 0]
     set willingness_risk random-float 1
     set public_priority random-float 1
     set skillset random 11]
ask DDMA_officers
    [ifelse random-float 1 < 0.6 [set corruption 1][set corruption 0]
     set willingness_risk random-float 1
     set public_priority random-float 1
     set skillset random 11]
ask KC_officers
    [ifelse random-float 1 < 0.6 [set corruption 1][set corruption 0]
     set willingness_risk random-float 1
     set public_priority random-float 1
     set skillset random 11]
ask kseb_officers
    [ifelse random-float 1 < 0.6 [set profit_minded 1][set profit_minded 0]
    set willingness_risk random-float 1]

;;; model decides if there is flood
    set heavyrain random 11]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; SDMA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; scheduling
ask sdma_officers [
    if hournow + minutenow = 0 [
      set schedule []
      set schedule-counter 0
      set target []
      set target_walk []
      set target_walk_max []
      ;;; on workdays
      ;;;;; reflect phase : gathering information and sharing experiences, developing post disaster assessment
      ;;;;; resist phase: preparing the community to handle any upcoming disasters in a better way
    if weeknow < 31 or weeknow >= 40 and PBernoulli (1 / 5) and workday = 1 and hournow = 0 and minutenow = 0 [; reflect, resist and recovery phases
        set schedule fput target_IMD schedule
        set schedule fput target_KSEB schedule
        set schedule fput target_NDMA schedule
         ; assuming SDMA goes to NDMA before going to IMD or KSEB
        ]
      ;;; on weekends of resist phase - vulnerabililty mapping when SDMA with the highest power
      if power_to = 3
        [if weeknow >= 13 and weeknow < 31 and workday = 0 and PBernoulli (1 / 2) and hournow = 0 and minutenow = 0
         [if corruption = 0
         [ifelse skillset > thresh_skillset ; if high power and enough skillset, carries out vulnerability mapping
          [ set target_walk_max max-one-of patches [count citizens-here]
            set schedule fput target_walk_max schedule]
          [ set target_walk target_NDMA
            set schedule fput target_walk schedule]

        ]
         if corruption = 1
          [ifelse random-float 1 < willingness_risk * ( 1 - public_priority)
          [ set vulnerability_info vulnerability_info + info_effect "neg""medium"
            ask citizens [set capacity_individual capacity_individual - 1]
            set opportunistic opportunistic + 1

          ]
            [ifelse skillset > thresh_skillset  ; if high power and enough skillset, carries out vulnerability mapping
          [ set target_walk_max max-one-of patches [count citizens-here]
            set schedule fput target_walk_max schedule]
          [ set target_walk target_NDMA
            set schedule fput target_walk schedule]

        ]
          ]
      ]
      ]
     ;;; response phase with flood more frequency of visits
       if weeknow >= 31 and weeknow < 40 and heavyrain = 1 and PBernoulli ( 5 / 7 ) and hournow = 0 and minutenow = 0[
        set schedule fput target_DDMA schedule
        set schedule fput target_IMD schedule
        set schedule fput target_KSEB schedule
        set schedule fput target_NDMA schedule
       ]
      ;;; response phase without flood less frequency of visits - things are mostly under control
       if weeknow >= 31 and weeknow < 40 and heavyrain = 0 and PBernoulli (1 / 5) and workday = 1 and hournow = 0 and minutenow = 0[
        set schedule fput target_DDMA schedule
        set schedule fput target_IMD schedule
        set schedule fput target_KSEB schedule
        set schedule fput target_NDMA schedule
        ]
        set schedule lput homelocation schedule

      if item 0 schedule = target_NDMA
      [ifelse workday = 1
            [set info_value info_value + info_effect "pos""small"
             ]; if local knowledge is considered the most crucial NDMA receives a small part of the information as not directly in contact with communities
          [set skillset skillset + 1
             set transaction_cost transaction_cost + 1

        ]
      ]
      if item 0 schedule = target_walk_max
          [ask citizens-on target_walk_max
                [set capacity_individual capacity_individual + 1]
             ask SDMAs
                [set vulnerability_info vulnerability_info + info_effect "pos""medium"
                 set transaction_cost transaction_cost + 1

      ]]

      if length schedule > 1
      [if item 1 schedule != nobody
      [if item 1 schedule = target_KSEB
      [ifelse skillset > 6
        [set info_value info_value + info_effect "pos""high"
          ]
        [set info_value info_value + info_effect "pos" "small"
            ]]
       ]
      ]

     if length schedule > 2
     [if item 2 schedule != nobody
      [if item 2 schedule = target_IMD
      [ifelse skillset > thresh_skillset
              [set forecast_info forecast_info + info_effect "pos""high"
               set transaction_cost transaction_cost + 1

               ]  ; since interaction directly between government officials assuming low transaction cost - assume e-government communication
              [set forecast_info forecast_info + info_effect "pos""small"
               set transaction_cost transaction_cost + 1

            ]
           ]
        ]
    ]
      if length schedule > 3
      [if item 3 schedule != nobody
      [if item 3 schedule = target_DDMA ; passing the forecast information from IMD to DDMA
      [ifelse skillset > thresh_skillset
              [set forecast_info forecast_info + info_effect "pos""high"
               set transaction_cost transaction_cost + 1

            ]
              [set forecast_info forecast_info + info_effect "pos""small"
               set transaction_cost transaction_cost + 1

              ]]
    ]
    ]
    ]

;;; Execution
if hournow >= starttime [ ; execute schedule
      if hournow = starttime and minutenow = 0[
        if target = [][
          set target item schedule-counter schedule

        ]
      ]
      if hournow < endtime [
        move-turtles
        if distance target = 0[
          if (last schedule != target) [
            set schedule-counter schedule-counter + 1
            set target item schedule-counter schedule

          ]
        ]
      ]
        if hournow = endtime and minutenow = 0 [
        if (last schedule != target) [
          set schedule-counter schedule-counter + 1
          set target item schedule-counter schedule
        ]
      ]
        if hournow > endtime [
        if distance target != 0 [
          move-turtles

        ]
        ]
      ]
    ]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;; DDMA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;; schedule
ask ddma_officers [
    if hournow + minutenow = 0 [
      set schedule []
      set schedule-counter 0
      set target []
      set target_walk []
      set target_walk_max[]
      ;;; on workdays
      ;;;;; reflect phase : gathering information and sharing experiences, developing post disaster assessment
      ;;;;; resist phase: preparing the community to handle any upcoming disasters in a better way
        if workday = 1 and PBernoulli (1 / 5) and weeknow < 31 or weeknow >= 40 and hournow = 0 and minutenow = 0[; reflect, resist and recovery phases
        set schedule fput target_SDMA schedule ; assuming SDMA goes to NDMA before going to IMD or KSEB

        ]
      ;;; on weekends - vulnerabililty mapping when DDMA with the hgihest power
      if power_to = 4
        [if  weeknow >= 13 and weeknow < 31 and workday = 0 and PBernoulli (1 / 2) and hournow = 0 and minutenow = 0
        [if corruption = 0
        [ifelse skillset > thresh_skillset  ; if high power and enough skillset, carries out vulnerability mapping
          [ set target_walk_max max-one-of patches [count citizens-here]
            set schedule fput target_walk_max schedule]
          [ set target_walk target_SDMA
            set schedule fput target_walk schedule]

        ]
          if corruption = 1
          [ifelse random-float 1 < willingness_risk * ( 1 - public_priority)
          [ set vulnerability_info vulnerability_info + info_effect "neg""medium"
            ask citizens [set capacity_individual capacity_individual - 1]
            set opportunistic opportunistic + 1

          ]
          [ifelse skillset > thresh_skillset  ; if high power and enough skillset, carries out vulnerability mapping
          [ set target_walk_max max-one-of patches [count citizens-here]
            set schedule fput target_walk_max schedule]
          [ set target_walk target_SDMA
            set schedule fput target_walk schedule]
          ]
          ]

      ]
      ]

     ;;; response phase with flood more frequency of visits
       if weeknow >= 31 and weeknow < 40 and heavyrain = 1 and PBernoulli (3 / 5) and hournow = 0 and minutenow = 0[
        set schedule fput target_KC schedule
        set schedule fput target_SDMA schedule
        ]
      ;;; response phase without flood less frequency of visits
       if weeknow >= 31 and weeknow < 40 and heavyrain = 0 and PBernoulli (1 / 5) and hournow = 0 and minutenow = 0[
        set schedule fput target_KC schedule
        set schedule fput target_SDMA schedule
         ]
        set schedule lput homelocation schedule

      if item 0 schedule = target_SDMA
            [ifelse workday = 1
            [set info_value info_value + info_effect "pos""small"
             ]; if local knowledge is considered the most crucial NDMA receives a small part of the information as not directly in contact with communities
            [set skillset skillset + 1
             set transaction_cost transaction_cost + 1

              ]
      ]

      if item 0 schedule = target_walk_max
          [ask citizens-on target_walk_max
                [set capacity_individual capacity_individual + 1]
           ask DDMAs
                [set vulnerability_info vulnerability_info + info_effect "pos""medium"
                 set transaction_cost transaction_cost + 1

      ]]

      if length schedule > 1
      [if item 1 schedule != nobody
      [if item 1 schedule = target_KC ; share forecast info to KC
      [ifelse skillset > thresh_skillset
              [set forecast_info forecast_info + info_effect "pos""high"
               set transaction_cost transaction_cost + 1

            ]      ; information sharing between government authorities - assuming e-government
              [set forecast_info forecast_info + info_effect "pos""small"
               set transaction_cost transaction_cost + 1

          ]]
    ]
      ]
   ]

;;; Execution
if hournow >= starttime [ ; execute schedule
      if hournow = starttime and minutenow = 0[
        if target = [][
          set target item schedule-counter schedule

        ]
      ]
      if hournow < endtime [
        move-turtles

        if distance target = 0[
          if (last schedule != target) [
            set schedule-counter schedule-counter + 1
            set target item schedule-counter schedule

          ]
        ]
      ]
        if hournow = endtime and minutenow = 0 [
        if (last schedule != target) [
          set schedule-counter schedule-counter + 1
          set target item schedule-counter schedule
        ]
      ]
        if hournow > endtime [
        if distance target != 0 [
          move-turtles

        ]
        ]
      ]
    ]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;; PBCA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ask PBCs [
      ;; on workdays
if weeknow = 4 or weeknow = 8 or weeknow = 12 or weeknow = 16 or weeknow = 20 or weeknow = 24 or weeknow = 28 and daynow = 1 and hournow = 0 and minutenow = 0 [
        set location_chosen one-of patches with [ pcolor = 39]
        ifelse [pcolor] of location_chosen = 39
        [;;; with KC more power
if power_to = 0 ; decision maker : KMC
  [ask KCs
   [ ifelse corruption = 1 and random-float 1 < willingness_risk * (1 - public_priority) and count my-links = 0
              [set permission 1
               set opportunistic opportunistic + 1
                 ]
              [set permission 0

                  ]]]
if power_to = 1 ; decision makers : KMC and DDMA
  [ask KCs
          [ ifelse corruption = 1 and random-float 1 < willingness_risk * (1 - public_priority) and count my-links = 0
              [set permission 1
               set opportunistic opportunistic + 1
                      ]
              [ask DDMAs
              [ifelse corruption = 1 and random-float 1 < willingness_risk * (1 - public_priority) and count my-links = 0
                  [set permission 1
                    set opportunistic opportunistic + 1
                          ]
                  [set permission 0

                  ]]]]]
if power_to = 2 ; decision makers: KMC and SDMA
  [ask KCs
          [ ifelse corruption = 1 and random-float 1 < willingness_risk * (1 - public_priority) and count my-links = 0
              [set permission 1
               set opportunistic opportunistic + 1
                      ]
              [ask SDMAs
              [ifelse corruption = 1 and random-float 1 < willingness_risk * (1 - public_priority) and count my-links = 0
                  [set permission 1
                   set opportunistic opportunistic + 1
                          ]
                  [set permission 0

                  ]]]]]
if power_to = 5 ; decision maker : SDMA
  [ask SDMAs
   [ ifelse corruption = 1 and random-float 1 < willingness_risk * (1 - public_priority) and count my-links = 0
              [set permission 1
               set opportunistic opportunistic + 1
                      ]
              [set permission 0

                  ]]]
if power_to = 4 ; decision maker: DDMA
 [ask DDMAs
   [ ifelse corruption = 1 and random-float 1 < willingness_risk * (1 - public_priority) and count my-links = 0
              [set permission 1
               set opportunistic opportunistic + 1
                    ]
              [set permission 0

                  ]]]

;;; with DDMA more power
if power_to = 4 ; decision maker: DDMA
  [ask DDMAs
   [ ifelse corruption = 1 and random-float 1 < willingness_risk * (1 - public_priority) and count my-links = 0
              [set permission 1
               set opportunistic opportunistic + 1]
              [set permission 0
               ]]]
if power_to = 1 ; decision makers: KMC and DDMA
 [ask KCs
          [ ifelse corruption = 1 and random-float 1 < willingness_risk * (1 - public_priority) and count my-links = 0
              [set permission 1
               set opportunistic opportunistic + 1]
              [ask DDMAs
              [ifelse corruption = 1 and random-float 1 < willingness_risk * (1 - public_priority) and count my-links = 0
                  [set permission 1
                   set opportunistic opportunistic + 1]
                  [set permission 0
                   ]]]]]
if power_to = 5 ; decision makers: DDMA and SDMA
 [ask DDMAs
          [ ifelse corruption = 1 and random-float 1 < willingness_risk * (1 - public_priority) and count my-links = 0
              [set permission 1
               set opportunistic opportunistic + 1]
              [ask SDMAs
              [ifelse corruption = 1 and random-float 1 < willingness_risk * (1 - public_priority) and count my-links = 0
                  [set permission 1
                   set opportunistic opportunistic + 1]
                  [set permission 0
                   ]]]]]
if power_to = 3 ; decision maker: SDMA
   [ask SDMAs
   [ ifelse corruption = 1 and random-float 1 < willingness_risk * (1 - public_priority) and count my-links = 0
              [set permission 1
               set opportunistic opportunistic + 1]
              [set permission 0
               ]]]
if power_to = 0 ; decision maker: KMC
   [ask KCs
   [ ifelse corruption = 1 and random-float 1 < willingness_risk * (1 - public_priority) and count my-links = 0
              [set permission 1
               set opportunistic opportunistic + 1]
              [set permission 0
               ]]]

;;; with SDMA more power
if power_to = 3 ; decision maker: SDMA
  [ask SDMAs
   [ ifelse corruption = 1 and random-float 1 < willingness_risk * (1 - public_priority) and count my-links = 0
              [set permission 1
               set opportunistic opportunistic + 1]
              [set permission 0
                ]]]
if power_to = 5 ; decision makers: DDMA and SDMA
 [ask DDMAs
          [ ifelse corruption = 1 and random-float 1 < willingness_risk * (1 - public_priority) and count my-links = 0
              [set permission 1
               set opportunistic opportunistic + 1]
              [ask SDMAs
              [ifelse corruption = 1 and random-float 1 < willingness_risk * (1 - public_priority) and count my-links = 0
                  [set permission 1
                   set opportunistic opportunistic + 1]
                  [set permission 0
                   ]]]]]
if power_to = 2 ; decision makers: KMC and SDMA
 [ask KCs
          [ ifelse corruption = 1 and random-float 1 < willingness_risk * (1 - public_priority) and count my-links = 0
              [set permission 1
               set opportunistic opportunistic + 1]
              [ask SDMAs
              [ifelse corruption = 1 and random-float 1 < willingness_risk * (1 - public_priority) and count my-links = 0
                  [set permission 1
                   set opportunistic opportunistic + 1]
                  [set permission 0
                   ]]]]]
if power_to = 0 ; decision maker: KMC
    [ask KCs
   [ ifelse corruption = 1 and random-float 1 < willingness_risk * (1 - public_priority) and count my-links = 0
              [set permission 1
               set opportunistic opportunistic + 1]
              [set permission 0
               ]]]
if power_to = 4 ; decision maker: DDMA
  [ask DDMAs
   [ ifelse corruption = 1 and random-float 1 < willingness_risk * (1 - public_priority) and count my-links = 0
              [set permission 1
               set opportunistic opportunistic + 1]
              [set permission 0
               ]]]

;;; equal power for SDMA, DDMA and KC
if power_to = 6
 [ask KCs
          [ ifelse corruption = 1 and random-float 1 < willingness_risk * (1 - public_priority) and count my-links = 0
              [set permission 1
               set opportunistic opportunistic + 1]
              [ask DDMAs
              [ifelse corruption = 1 and random-float 1 < willingness_risk * (1 - public_priority) and count my-links = 0
                  [set permission 1
                   set opportunistic opportunistic + 1]
                  [ask SDMAs
                  [ifelse corruption = 1 and random-float 1 < willingness_risk * (1 - public_priority) and count my-links = 0
                      [set permission 1
                       set opportunistic opportunistic + 1]
                      [set permission 0
                       ]]]]]]]
 if permission = 1
                [construct
                  print "illegal"]
        ]

    [construct
        print "yes"]
      ]
  ]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;; KMC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; schedule
ask kc_officers [
    if hournow + minutenow = 0 [
      set schedule []
      set schedule-counter 0
      set target []
      set target_walk []
      ;;; on workdays
       if weeknow >= 1 and weeknow < 13 and workday = 1 and PBernoulli (1 / 5) and hournow = 0 and minutenow = 0 [
        set schedule fput target_DDMA schedule ; updates DDMA

        ]

       ;;; on weekends of resist phase when the power of KMC is higher than the power allocated to other agents
      if power_to = 0
        [ if  weeknow >= 13 and weeknow < 31 and workday = 0 and hournow = 0 and minutenow = 0 ; combining the vulnerability mapping
[if corruption = 0
        [ifelse skillset > thresh_skillset  ; if high power and enough skillset, carries out vulnerability mapping
          [ set target_walk_max max-one-of patches [count citizens-here]
            set schedule fput target_walk_max schedule]
          [ set target_walk target_DDMA
            set schedule fput target_walk schedule]

        ]
          if corruption = 1
          [ifelse random-float 1 < willingness_risk * ( 1 - public_priority)
          [ set vulnerability_info vulnerability_info + info_effect "neg""high"
            ask citizens [set capacity_individual capacity_individual - 1]
            set opportunistic opportunistic + 1

          ]
          [ifelse skillset > thresh_skillset  ; if high power and enough skillset, carries out vulnerability mapping
          [ set target_walk_max max-one-of patches [count citizens-here]
            set schedule fput target_walk_max schedule]
          [ set target_walk target_DDMA
            set schedule fput target_walk schedule]

          ]
          ]

      ]
      ]

      ;;;response phase with flood
       if weeknow >= 31 and weeknow < 40 and heavyrain = 1 and PBernoulli (5 / 7) and hournow = 0 and minutenow = 0[
        set schedule fput min-one-of r_centers [distance myself] schedule
        set schedule fput target_DDMA schedule ; updates DDMA
        ]
      ;;;response phase without flood
       if weeknow >= 31 and weeknow < 40 and heavyrain = 0 and PBernoulli (1 / 5) and workday = 1 and hournow = 0 and minutenow = 0[
        set schedule fput min-one-of r_centers [distance myself] schedule
        set schedule fput target_DDMA schedule ; updates SDMA
        ]

      set schedule lput homelocation schedule

      if item 0 schedule = target_DDMA
            [ifelse workday = 1
            [set info_value info_value + info_effect "pos""high"
             ]; if local knowledge is considered the most crucial NDMA receives a small part of the information as not directly in contact with communities
          [set skillset skillset + 1
             set transaction_cost transaction_cost + 1

              ]
      ]
      if item 0 schedule = target_walk_max
          [ask citizens-on target_walk_max
                [set capacity_individual capacity_individual + 1]
             ask KCs
                [set vulnerability_info vulnerability_info + info_effect "pos""high"
                 set transaction_cost transaction_cost + 1

      ]]

      if length schedule > 1
      [if item 1 schedule != nobody
      [if item 1 schedule = min-one-of r_centers [distance myself]
            [ask citizens
            [set capacity_individual capacity_individual + 1
            ]]
            set transaction_cost transaction_cost + 1

             ; r_center maintenance
     ]
    ]
   ]

;;; Execution
if hournow >= starttime [ ; execute schedule
      if hournow = starttime and minutenow = 0[
        if target = [][
          set target item schedule-counter schedule
        ]
      ]
      if hournow < endtime [
        move-turtles

          if distance target = 0 [
          if (last schedule != target) [
            set schedule-counter schedule-counter + 1
            set target item schedule-counter schedule
            ]
          ]
        ]
        if hournow = endtime and minutenow = 0 [
        if (last schedule != target) [
          set schedule-counter schedule-counter + 1
          set target item schedule-counter schedule
        ]
      ]
        if hournow > endtime [
        if distance target != 0 [
          move-turtles
        ]
        ]
      ]
    ]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;; citizens
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; schedule
ask citizens [

if hournow + minutenow = 0 [
    set schedule []
    set schedule-counter 0
    set target []
    set target_walk []
;;;; on working days
     if weeknow < 31 or weeknow >= 40  and workday = 1[
      set schedule fput target_job schedule

    ]
;; on weekends
     if weeknow < 31 or weeknow >= 40 and workday = 0 and hournow = 0 and minutenow = 0[
     set target_walk one-of citizens
     set schedule fput target_walk schedule
     set schedule lput homelocation schedule
    ]
;; move to relief centers during flood
    if weeknow >= 31 and weeknow < 40 and heavyrain = 1 [
     set schedule fput min-one-of r_centers [distance myself] schedule
     set capacity_individual capacity_individual + 5]

     set schedule lput homelocation schedule
    ]

;;; implement and execute the schedule
if hournow >= starttime  [ ; starting schedule at 8:00 am
      if hournow = starttime and minutenow = 0[
        if target = [] [
          set target item schedule-counter schedule
        ]
      ]
if hournow < endtime [
        move-turtles
        if distance target = 0 [
          if (last schedule) != target [
            set schedule-counter schedule-counter + 1
            set target item schedule-counter schedule
          ]
        ]
      ]
      if hournow = endtime and minutenow = 0 [
        set target item schedule-counter schedule
      ]
      if hournow > endtime [
      move-turtles
      ]
    ]
  ]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;; KSEB dam management
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; schedule
ask kseb_officers [
if hournow + minutenow = 0 [
    set schedule []
    set schedule-counter 0
    set target []
    set target_walk []
;;;; on working days
if weeknow >= 31 and weeknow < 40 and heavyrain = 1 and hournow = 0 and minutenow = 0 and PBernoulli (1 / 5)[
      if profit_minded = 1 [
          ask citizens
            [set capacity_individual capacity_individual - 1]

       ]
      if profit_minded = 0[
          set schedule fput target_dam schedule
          ask citizens
            [set capacity_individual capacity_individual + 1]

        ]
      ]

 set schedule lput homelocation schedule
    ]

;;; implement and execute the schedule
if hournow >= starttime  [ ; starting schedule at 8:00 am
      if hournow = starttime and minutenow = 0[
        if target = [] [
          set target item schedule-counter schedule
        ]
      ]
if hournow < endtime and target != nobody [
        move-turtles
        if distance target = 0 [
          if (last schedule) != target [
            set schedule-counter schedule-counter + 1
            set target item schedule-counter schedule
          ]
        ]
      ]
      if hournow = endtime and minutenow = 0 [
        set target item schedule-counter schedule
      ]
      if hournow > endtime [
      move-turtles
      ]
    ]
  ]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; creating relief centers

if weeknow = 14 and hournow = 0 and minutenow = 0 and daynow = 1
  [set relief_location patch 315 750
    relief_center
    set transaction_cost transaction_cost + 1


   ]
if weeknow = 18 and hournow = 0 and minutenow = 0 and daynow = 1
  [set relief_location patch 797 488
    relief_center
   set transaction_cost transaction_cost + 1

  ]
if weeknow = 22 and hournow = 0 and minutenow = 0 and daynow = 1
  [set relief_location patch 531 160
    relief_center
   set transaction_cost transaction_cost + 1

  ]
if weeknow = 26 and hournow = 0 and minutenow = 0 and daynow = 1
  [set relief_location patch 161 646
    relief_center
   set transaction_cost transaction_cost + 1


  ]

;;;,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,, vulnerability mapping when powers are equal
  if power_to = 1
    [if weeknow >= 13 and weeknow < 31 and workday = 0 and PBernoulli (1 / 2) and hournow = 0 and minutenow = 0
      [ ask kc_officers
        [ ifelse corruption = 0 or (corruption = 1 and random-float 1 > willingness_risk * (1 - public_priority))
          [ifelse skillset > thresh_skillset
          [ set target_walk_max max-one-of patches [count citizens-here]
            set schedule fput target_walk_max schedule
            ]
          [ set target_walk target_DDMA
            set schedule fput target_walk schedule]

          ]
          [set opportunistic opportunistic + 1]
        ]
        ask ddma_officers
        [ ifelse corruption = 0 or (corruption = 1 and random-float 1 > willingness_risk * (1 - public_priority))
          [ifelse skillset > thresh_skillset
          [ set target_walk_max max-one-of patches [count citizens-here]
            set schedule fput target_walk_max schedule
            ]
          [ set target_walk target_SDMA
            set schedule fput target_walk schedule]

          ]
          [set opportunistic opportunistic + 1]
        ]
      ]
  ]
      if power_to = 2
      [if weeknow >= 13 and weeknow < 31 and workday = 0 and PBernoulli (1 / 2) and hournow = 0 and minutenow = 0
      [ ask kc_officers
        [ ifelse corruption = 0 or (corruption = 1 and random-float 1 > willingness_risk * (1 - public_priority))
          [ifelse skillset > thresh_skillset
          [ set target_walk_max max-one-of patches [count citizens-here]
            set schedule fput target_walk_max schedule
          ]
          [ set target_walk target_DDMA
            set schedule fput target_walk schedule]

          ]
        [set opportunistic opportunistic + 1]
        ]
        ask sdma_officers
        [ ifelse corruption = 0 or (corruption = 1 and random-float 1 > willingness_risk * (1 - public_priority))
          [ifelse skillset > thresh_skillset
          [ set target_walk_max max-one-of patches [count citizens-here]
            set schedule fput target_walk_max schedule
          ]
          [ set target_walk target_NDMA
            set schedule fput target_walk schedule]

          ]
        [set opportunistic opportunistic + 1]
        ]
      ]
  ]
     if power_to = 5
     [if weeknow >= 13 and weeknow < 31 and workday = 0 and PBernoulli (1 / 2) and hournow = 0 and minutenow = 0
      [ ask ddma_officers
        [ ifelse corruption = 0 or (corruption = 1 and random-float 1 > willingness_risk * (1 - public_priority))
          [ifelse skillset > thresh_skillset
          [ set target_walk_max max-one-of patches [count citizens-here]
            set schedule fput target_walk_max schedule
          ]
          [ set target_walk target_SDMA
            set schedule fput target_walk schedule]

          ]
        [set opportunistic opportunistic + 1]
        ]
        ask sdma_officers
        [ ifelse corruption = 0 or (corruption = 1 and random-float 1 > willingness_risk * (1 - public_priority))
          [ifelse skillset > thresh_skillset
          [ set target_walk_max max-one-of patches [count citizens-here]
            set schedule fput target_walk_max schedule
          ]
          [ set target_walk target_NDMA
            set schedule fput target_walk schedule]

          ]
        [set opportunistic opportunistic + 1]
        ]
      ]
  ]
     if power_to = 6
     [if weeknow >= 13 and weeknow < 31 and workday = 0 and PBernoulli (1 / 2) and hournow = 0 and minutenow = 0
      [ ask ddma_officers
        [ ifelse corruption = 0 or (corruption = 1 and random-float 1 > willingness_risk * (1 - public_priority))
          [ifelse skillset > thresh_skillset
          [ set target_walk_max max-one-of patches [count citizens-here]
            set schedule fput target_walk_max schedule
          ]
          [ set target_walk target_SDMA
            set schedule fput target_walk schedule]

          ]
        [set opportunistic opportunistic + 1]
        ]
        ask sdma_officers
        [ ifelse corruption = 0 or (corruption = 1 and random-float 1 > willingness_risk * (1 - public_priority))
          [ifelse skillset > thresh_skillset
          [ set target_walk_max max-one-of patches [count citizens-here]
            set schedule fput target_walk_max schedule
          ]
          [ set target_walk target_NDMA
            set schedule fput target_walk schedule]

          ]
        [set opportunistic opportunistic + 1]
        ]
        ask kc_officers
        [ ifelse corruption = 0 or (corruption = 1 and random-float 1 > willingness_risk * (1 - public_priority))
          [ifelse skillset > thresh_skillset
          [ set target_walk_max max-one-of patches [count citizens-here]
            set schedule fput target_walk_max schedule
          ]
          [ set target_walk target_DDMA
            set schedule fput target_walk schedule]

          ]
          [set opportunistic opportunistic + 1]
        ]
      ]
    ]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Initiative creation based on homelocation and job location
 if environmental_dimension > 0
  [ask constructions with [environmental_damage > 0]
    [set danger_zone patches in-radius 150]
    ask citizens ;initiaitive test
    [ if member? homelocation danger_zone
      [set color initiative_member
       set capacity_from_initiative capacity_from_initiative + 1
       ]]
  ]

   if environmental_dimension > 0
  [ask constructions with [environmental_damage > 0]
    [set danger_zone patches in-radius 150]
    ask citizens ;initiaitive test
    [ if member? target_job danger_zone
      [set color initiative_member
       set capacity_from_initiative capacity_from_initiative + 1
       ]]
  ]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Expansion of initiative through "social proofing"
  if count citizens with [color = initiative_member] > 0 and workday = 1 and hournow = 0 and minutenow = 0 and count citizens with [color = initiative_member] <= 0.1 * Lever_Citizens
  [ ask citizens with [color = initiative_member]
    [ask citizens with [color != initiative_member] in-radius 100
  [ if random-float 1 < citizen_join
    [set inf_socialproof true]
    if inf_socialproof = true
    [create-link-with one-of citizens with[color = initiative_member] [set color cyan]
     set color initiative_member
     set capacity_from_initiative capacity_from_initiative + 1
     set increment_energy increment_energy + 0.5
      print "expansion"
      ]
      ]
    ]

    ask NGOs
    [if random-float 1 < 1
      [set interest_collab true] ]
    ask NGOs with [interest_collab = true and count my-links = 0]
    [create-link-with one-of citizens with[color = initiative_member] [set color green]
     set increment_energy increment_energy + 1 ; more energy offered by NGOs
    ]
  ]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Expansion attracts government support
  if random-float 1 < gov_join and count citizens with [color = initiative_member] > 0
  [ask KCs
    [ ifelse (corruption = 0 or (corruption = 1 and random-float 1 > willingness_risk * (1 - public_priority))) and count my-links = 0
      [create-link-with one-of citizens with [color = initiative_member] [set color green]
       set increment_energy increment_energy + 10

       if (environmental_dimension >= 5)
        [ask constructions [set environmental_damage environmental_damage - 5
                                                            ]]
       ]
      [if count my-links = 0
        [set opportunistic opportunistic + 1]]
  ]
  ask SDMAs
  [ ifelse (corruption = 0 or (corruption = 1 and random-float 1 > willingness_risk * (1 - public_priority))) and count my-links = 0
      [create-link-with one-of citizens with [color = initiative_member] [set color green]
       set increment_energy increment_energy + 6

      if (environmental_dimension >= 5) [ask constructions [set environmental_damage  environmental_damage - 5
                                                          print "SDMA did it"]]
      ]
      [if count my-links = 0
        [set opportunistic opportunistic + 1]]
  ]
  ask DDMAs
   [ ifelse (corruption = 0 or (corruption = 1 and random-float 1 > willingness_risk * (1 - public_priority))) and count my-links = 0
      [create-link-with one-of citizens with [color = initiative_member] [set color green]
       set increment_energy increment_energy + 8

        if environmental_dimension >= 5 [ask constructions [set environmental_damage environmental_damage - 5
                                                               print "DDMA did it"]]
    print "link with DDMA"]
    [if count my-links = 0
        [set opportunistic opportunistic + 1]]
  ]
  ]
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; KC training
  if weeknow >= 13 and weeknow < 31 and workday = 1 and PBernoulli (1 / 5) and hournow = 0 and minutenow = 0
  [ask KCs
      [if corruption = 0 or (corruption = 1 and random-float 1 < willingness_risk * (1 - public_priority))
      [ask kc_officers [if skillset < 7
      [ set skillset skillset + 1
       set transaction_cost transaction_cost + 1

        ]]
    ]
  ]
  ]

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; clear some links

  if weeknow = 52 and daynow = 7 and hournow = 0 and minutenow = 0
  [ask KCs
    [if count my-links > 0
      [set urge_support random-float 1
      if urge_support < gov_cont
      [ask my-links [die]
       ask citizens with [capacity_from_initiative > 0][set capacity_from_initiative capacity_from_initiative - 1]
        ]

    ]
  ]
  ask DDMAs
    [if count my-links > 0
      [set urge_support random-float 1
        if urge_support < gov_cont
        [ask my-links [die]
         ask citizens with [capacity_from_initiative > 0][set capacity_from_initiative capacity_from_initiative - 1]]

    ]
    ]
  ask SDMAs
    [if count my-links > 0
      [set urge_support random-float 1
        if urge_support < gov_cont
        [ask my-links [die]
         ask citizens with [capacity_from_initiative > 0][set capacity_from_initiative capacity_from_initiative - 1]]
      ]
    ]
    ask citizens with [color = initiative_member]
    [ set urge_continue random-float 1
      if urge_continue < citizen_cont
      [set color green
       if count my-links > 0
        [ask my-links [die]
        ask citizens with [capacity_from_initiative > 0][set capacity_from_initiative capacity_from_initiative - 1]]
      ]
    ]
  ]

  if weeknow = 52 and daynow = 7 and hournow = 10 and minutenow = 0
  [if count links = 0 and count citizens with [color = initiative_member] = 0
    [set increment_energy 0]
  ]


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; print phases in output
  if weeknow = 1 and daynow = 1 and hournow = 0 and minutenow = 0 [output-print "Reflect phase"]
  if weeknow = 13 and daynow = 1 and hournow = 0 and minutenow = 0 [output-print "Resist phase"]
  if weeknow = 31 and daynow = 1 and hournow = 0 and minutenow = 0 [output-print "Response phase"]
  if weeknow = 40 and daynow = 1 and hournow = 0 and minutenow = 0 [output-print "Recovery phase"]

if yearnow = 2 and weeknow = 52 and daynow = 7 and hournow = 11 and minutenow = 0 [
    clear-output
    stop]

timestep

end
to timestep
  ifelse minutenow > (60 - minute_step) [ ; minute counter, steps of 10, from 50 --> set 00
    set hournow hournow + 1
    set minutenow 0]
    [ set minutenow minutenow + minute_step]
  if hournow = 12 [
    set daynow daynow + 1
    set hournow 0]
  if daynow = 8 [
    set weeknow weeknow + 1
    set daynow 1]
  if weeknow = 53 [
    set yearnow yearnow + 1
    set weeknow 1]
  if yearnow = 3 [
    stop]
  ifelse daynow < 6 [ ; day 1 to 5 of the week
    set workday 1]
   [set workday 0]
  tick ; next time step
end

to move-turtles
      ifelse target != nobody [
       ifelse distance target < distance_target
        [ move-to target ]
        [ face target
          fd citizen_speed
          ]
        ]
      [
      set schedule lput target schedule
      set schedule remove nobody schedule]
end

to-report PBernoulli [ p ]
  report random-float 1 < p
end

;;;;;;;; sharing information increments the gneral information available,
;;;;;;;;however lack of information would have negative implications as well such as delay or difficulty to move forward with a formal/informal process.
;;;;;;;; the model will show this lack of information as a negative effect
to-report info_effect [ direction quality ] ; direction = pos/neg , quality = small/medium/high
  if direction = "pos" [
    (ifelse
      quality = "small" [ report 1 ]
      quality = "medium" [ report 2 ]
      quality = "high" [ report 3 ]
    )
  ]
  if direction = "neg" [
    (ifelse
      quality = "small" [ report -1 ]
      quality = "medium" [ report -2 ]
      quality = "high" [ report -3 ]
    )
  ]
end

to construct
  ask location_chosen [
    ifelse pcolor = 39
    [sprout-constructions 1[
      set shape "house"
      set size 20
      set color green
      set environmental_damage environmental_damage + 5
    ]]
    [sprout-constructions 1[
      set shape "house"
      set size 20
      set color green ]]
  ]
end

to relief_center
  ask relief_location [
    sprout-r_centers 1[
      set shape "star"
      set size 15
      set color orange
    ]
  ]
end

to-report patches-outside-radius [radius]
  let inrad patches in-radius radius
  report patches with [ not member? self inrad ]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
1033
804
-1
-1
1.0
1
10
1
1
1
0
0
0
1
0
814
0
784
1
1
1
ticks
30.0

SWITCH
104
185
208
218
verbose?
verbose?
1
1
-1000

SWITCH
105
149
208
182
debug?
debug?
0
1
-1000

BUTTON
144
68
207
101
NIL
setup\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
4
116
103
176
Lever_Citizens
212.0
1
0
Number

SLIDER
4
226
200
259
distance_target
distance_target
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
5
264
202
297
citizen_speed
citizen_speed
0
100
40.0
1
1
NIL
HORIZONTAL

BUTTON
144
105
207
138
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
2
18
64
63
NIL
yearnow
17
1
11

MONITOR
135
18
192
63
NIL
daynow
17
1
11

MONITOR
67
17
132
62
NIL
weeknow
17
1
11

MONITOR
3
68
65
113
NIL
hournow
17
1
11

MONITOR
68
67
141
112
NIL
minutenow
17
1
11

SLIDER
6
302
203
335
minute_step
minute_step
0
59
15.0
0.5
1
NIL
HORIZONTAL

INPUTBOX
2
380
208
440
Lever_power_SDMA
random 3 + 2
1
0
String

INPUTBOX
3
441
207
501
Lever_power_DDMA
random 3 + 2
1
0
String

INPUTBOX
97
503
191
563
Lever_power_KC
random 3 + 2
1
0
String

OUTPUT
7
342
202
376
11

MONITOR
3
178
88
223
NIL
heavyrain
17
1
11

PLOT
1037
130
1197
250
economic dimension
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot economic_dimension"

PLOT
1036
10
1196
130
social dimension
ticks
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot social_capacity"
"pen-1" 1.0 0 -955883 true "" "plot info_value"

PLOT
1036
254
1196
374
technical dimension
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot max list vulnerability_info 0"
"pen-1" 1.0 0 -7500403 true "" "plot forecast_info"
"pen-2" 1.0 0 -2674135 true "" "plot technical_capacity"

PLOT
1038
378
1198
498
env_dimension
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot environmental_dimension"

MONITOR
5
507
90
552
NIL
opportunistic
17
1
11

MONITOR
1104
531
1200
576
NIL
social_capacity
17
1
11

MONITOR
1193
659
1306
704
NIL
increment_energy
17
1
11

INPUTBOX
6
566
98
626
thresh_skillset
6.0
1
0
Number

INPUTBOX
10
636
96
696
citizen_join
0.6
1
0
Number

INPUTBOX
109
564
163
624
gov_join
0.4
1
0
Number

INPUTBOX
110
639
190
699
citizen_cont
0.4
1
0
Number

INPUTBOX
13
705
87
765
gov_cont
0.6
1
0
Number

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="final_sens_thresh_8 out 10" repetitions="2" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>info_value</metric>
    <metric>social_capacity</metric>
    <metric>economic_dimension</metric>
    <metric>vulnerability_info</metric>
    <metric>forecast_info</metric>
    <metric>technical_capacity</metric>
    <metric>environmental_dimension</metric>
    <metric>weeknow</metric>
    <metric>yearnow</metric>
    <enumeratedValueSet variable="thresh_skillset">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="citizen_cont">
      <value value="0.4"/>
      <value value="0.6"/>
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="gov_cont">
      <value value="0.2"/>
      <value value="0.4"/>
      <value value="0.6"/>
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="citizen_join">
      <value value="0.4"/>
      <value value="0.6"/>
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="gov_join">
      <value value="0.2"/>
      <value value="0.4"/>
      <value value="0.6"/>
      <value value="0.8"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
