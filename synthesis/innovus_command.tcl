setLibraryUnit -time 1ps

source ./Default.globals
init_design

# this is example tcl to make a flexible floorplan size

#set cellheight [expr 0.270 * 4 ]
#set cellhgrid  0.216

#set fpxdim [expr $cellhgrid * 400 ]
#set fpydim [expr $cellheight * 74 ]

#floorPlan -site coreSite -s $fpxdim $fpydim 0 0 0 0
#You might want to change floorplan according to your design
floorPlan -site coreSite -r 1 0.5 5 5 5 5 

#puts "Floorplan is $fpxdim by $fpydim"
#puts "Total area is [expr $fpxdim * $fpydim ] square um"
#puts "[expr $fpydim / $cellheight] standard cell rows tall"

# Innovus is not putting tracks on the bottom cell row. That causes problems
# since it won't route to them on proper tracks.

# This moves the core up one.
# Weirdly, it moves it up 1.008, but that seems to fix the track issue.
#changeFloorplan -coreToBottom 1.08

#add_tracks -honor_pitch 

#clearGlobalNets
#global net names are case sensitive.

#globalNetConnect VDD -type pgpin -pin vdd -inst * -module {}
#globalNetConnect VSS -type pgpin -pin vss -inst * -module {}
globalNetConnect VDD -type pgpin -pin VDD -inst * -module {}
globalNetConnect VSS -type pgpin -pin VSS -inst * -module {}
saveDesign Lab3_globalNet.enc

addWellTap -cell TAPCELL_ASAP7_75t_R -cellInterval 7.6 -inRowOffset 2 -prefix WELLTAP
saveDesign Lab3_wellTap2.enc

#####Power Planning 
#Note: You can add power rings: Commands to put power rings are given below in comments.

##Power rings
addRing -nets {VDD VSS } -around default_power_domain -center 1 -width 1.224 -spacing 0.5 -layer {left M3 right M3 bottom M2 top M2} 
saveDesign Lab3_power_ring2.enc

#Sprecial routing using M1
sroute -connect { blockPin padPin padRing corePin floatingStripe } -nets {VDD VSS } -layerChangeRange { M1 M3 } -blockPinTarget { nearestTarget } -padPinPortConnect { allPort oneGeom } -padPinTarget { nearestTarget } -corePinTarget { firstAfterRowEnd } -floatingStripeTarget { blockring padring ring stripe ringpin blockpin followpin } -allowJogging 1 -crossoverViaLayerRange { M1 Pad } -allowLayerChange 1 -blockPin useLef -targetViaLayerRange { M1 Pad }
saveDesign GCN_power_route.enc

#setAddStripeMode -stacked_via_bottom_layer M1 \
#    -stacked_via_top_layer M2

#sroute -connect { blockPin padPin padRing corePin floatingStripe } \
#    -layerChangeRange { M1 Pad } \
#    -blockPinTarget { nearestTarget } \
#    -padPinPortConnect { allPort oneGeom } \
#    -padPinTarget { nearestTarget } \
#    -corePinTarget { firstAfterRowEnd } \
#    -floatingStripeTarget { blockring padring ring stripe ringpin blockpin followpin } \
#    -allowJogging 1 \
#    -crossoverViaLayerRange { M1 Pad } \
#    -nets { VDD VSS } \
#    -allowLayerChange 1 \
#    -blockPin useLef \
#    -targetViaLayerRange { M1 }

#placement of pins


setPinAssignMode -pinEditInBatch true
editPin -fixedPin 1 -fixOverlap 1 -spreadDirection clockwise -edge 0 -layer 2 -spreadType side -pin {a[0] a[1] b[0] b[1] clk }
setPinAssignMode -pinEditInBatch false
getPinAssignMode -pinEditInBatch -quiet
setPinAssignMode -pinEditInBatch true
editPin -fixedPin 1 -fixOverlap 1 -spreadDirection clockwise -edge 2 -layer 2 -spreadType side -pin {sum[0] sum[1] cout }
setPinAssignMode -pinEditInBatch false

saveDesign Lab3_pinAssignment2.enc


# placement pre-clock cts goes here... place your standard cells
#### Place Design
setPlaceMode -place_global_timing_effort medium
setPlaceMode -place_global_reorder_scan false
setPlaceMode -place_global_cong_effort low
place_opt_design

saveDesign Lab3_placementOPT2.enc
# CTS

setNanoRouteMode -drouteMinimizeLithoEffectOnLayer {f t t t t t t t t t} \
    -routeTopRoutingLayer 7 -routeBottomRoutingLayer 1 \
    -routeWithViaInPin true 
#03052025
# set desired clock cells here...
set_ccopt_property buffer_cells {BUFx10_ASAP7_75t_R BUFx12_ASAP7_75t_R BUFx12f_ASAP7_75t_R BUFx16f_ASAP7_75t_R BUFx24_ASAP7_75t_R BUFx2_ASAP7_75t_R BUFx3_ASAP7_75t_R BUFx4_ASAP7_75t_R BUFx5_ASAP7_75t_R BUFx4f_ASAP7_75t_R BUFx6f_ASAP7_75t_R BUFx8_ASAP7_75t_R HB1xp67_ASAP7_75t_R HB2xp67_ASAP7_75t_R}

set_ccopt_property inverter_cells {INVx11_ASAP7_75t_R INVx13_ASAP7_75t_R INVx1_ASAP7_75t_R INVx2_ASAP7_75t_R INVx3_ASAP7_75t_R INVx4_ASAP7_75t_R INVx5_ASAP7_75t_R INVx6_ASAP7_75t_R INVx8_ASAP7_75t_R INVxp67_ASAP7_75t_R INVxp33_ASAP7_75t_R}

set_ccopt_property target_skew 30ps 
set_ccopt_property target_max_trans 100ps
set_ccopt_property -max_fanout 16
#setNanoRouteMode -routeTopRoutingLayer 5 -routeBottomRoutingLayer 2
#create_route_type -name ccopt_route_group -bottom_preferred_layer 4 -top_preferred_layer 5
#create_ccopt_clock_tree_spec
ccopt_design -outDir ./cts/
#####
saveDesign GCN_CTS.enc
# Report timing
timeDesign -postCTS -expandedViews -outDir ./cts/timing/
    
# Report clock trees to check area and other statistics
report_ccopt_clock_trees -filename ./cts/clock_trees.rpt
report_ccopt_skew_groups -filename ./cts/skew_groups.rpt

#Post CTS
optDesign -postCTS
optDesign -postCTS -hold
saveDesign Lab3_CTS2.clock.enc

#Nano routing
setNanoRouteMode -drouteMinimizeLithoEffectOnLayer {t t t t t t t t t t}
setNanoRouteMode -routeWithViaInPin true -routeDesignFixClockNets true -routeTopRoutingLayer 7
setNanoRouteMode -quiet -drouteFixAntenna 0
setNanoRouteMode -quiet -routeWithTimingDriven 1
setNanoRouteMode -quiet -drouteEndIteration default
setNanoRouteMode -quiet -routeWithTimingDriven true
setNanoRouteMode -quiet -routeWithSiDriven false
routeDesign -globalDetail
saveDesign Lab3_route2.enc
#Post Optimization
verifyConnectivity
verify_drc
editDeleteRoute
globalDefaultRoute

get_db current_design .markers -if {.subtype == Metal_Short} -foreach{
set box [get_db $object .bbox]
set layer_name [get_db $object .layer.name]
select_obj[get_db [dbQuery -area $box -layers $layer_name -objType wire] -if {.net.use != clock}]
editDelete -selected
}



timeDesign -postRoute -hold

timeDesign -postRoute

setAnalysisMode -analysisType onchipvariation

#timeDesign -postRoute

optDesign -postroute -hold
# all done--finish up with decap and finally filler
getFillerMode -quiet
addFiller -cell {FILLER_ASAP7_75t_R FILLERxp5_ASAP7_75t_R } -prefix FILLER_

saveDesign Lab3_post_opt2.enc
#Verify Geometry & Connectivity
verify_drc
verifyGeometry  -error 1000000 -warning 50
verifyConnectivity -type all -noAntenna -error 1000000 -warning 50
rcOut -spf adder_2bit.spf
rcOut -spef adder_2bit.spef
#Save final Design
#saveNetlist adder_2bit.apr.v
saveNetlist adder_2bit.apr.v -excludeLeafCell -excludeCellInst {FILLER_ASAP7_75t_R FILLERxp5_ASAP7_75t_R }
saveDesign Lab3_netlist2.final.enc

##StreamOutGds
streamOut ./output/adder_2bit.gds -mapFile /usr/local2/ASAP7/afs/asu.edu/class/e/e/e/eee525b/asap7/asap7PDK_e1p5/cdslib/asap7_TechLib_08/asap7_fromAPR.layermap -libname adder_2bit -units 4000 -mode ALL




