$ONEPS

set hydro_res(g)
/
$INCLUDE %psys_scen%_gen_set_hydrores.dd
/;

parameter hydro_inflow(h,z,hydro_res);

$gdxin hydro_inflow_%weather_yr%.gdx
$load hydro_inflow


positive variables
var_hydro_level(h,z,hydro_res) Amount of electricity currently stored hydro_resd by hour and technology (MWh)
var_hydro_in(h,z,hydro_res) Electricity into storage by hour and technology (MW)
var_hydro_spill(h,z,hydro_res)
*var_hydro_res_gen(h,z,hydro_res) Electricity generated from storage by hour and technology (MW)

*var_new_hydro_res_pcap_z(z,hydro_res) Capacity of storage generator (MW)
*var_new_hydro_res_pcap(hydro_res)
var_new_hydro_ecap_z(z,hydro_res)
var_new_hydro_ecap(hydro_res)

*var_exist_hydro_res_pcap_z(z,hydro_res)
*var_exist_hydro_res_pcap(hydro_res)
var_exist_hydro_ecap_z(z,hydro_res)
var_exist_hydro_ecap(hydro_res)

*var_tot_hydro_res_pcap_z(z,hydro_res)
*var_tot_hydro_res_pcap(hydro_res)
var_tot_hydro_ecap_z(z,hydro_res)
var_tot_hydro_ecap(hydro_res)
;

*** Res hydro set up ***

* existing hydro_res energy capacity

var_exist_hydro_ecap_z.UP(z,hydro_res)$(gen_exist_ecap_z(z,hydro_res,"UP")) = gen_exist_ecap_z(z,hydro_res,"UP");
var_exist_hydro_ecap_z.L(z,hydro_res)$(gen_exist_ecap_z(z,hydro_res,"UP")) = gen_exist_ecap_z(z,hydro_res,"UP");

var_exist_hydro_ecap_z.FX(z,hydro_res)$(gen_exist_ecap_z(z,hydro_res,"FX")) = gen_exist_ecap_z(z,hydro_res,"FX");

var_exist_hydro_ecap_z.FX(z,hydro_res)$(not var_exist_hydro_ecap_z.l(z,hydro_res)) = 0.0;


* limits on total hydro_res hydro_res capacity

var_tot_hydro_ecap_z.UP(z,hydro_res)$(gen_lim_ecap_z(z,hydro_res,'UP'))=gen_lim_ecap_z(z,hydro_res,'UP');
var_tot_hydro_ecap_z.LO(z,hydro_res)$(gen_lim_ecap_z(z,hydro_res,'LO'))=gen_lim_ecap_z(z,hydro_res,'LO');
var_tot_hydro_ecap_z.FX(z,hydro_res)$(gen_lim_ecap_z(z,hydro_res,'FX'))=gen_lim_ecap_z(z,hydro_res,'FX');

*set hydro_lim(z,hydro_res);
*s_lim(z,hydro_res) = YES;

*hydro_lim(z,hydro_res) = ((sum(lt,gen_lim_pcap_z(z,hydro_res,lt))+sum(lt,gen_exist_pcap_z(z,hydro_res,lt)))>0.);
gen_lim(z,hydro_res)= ((sum(lt,gen_lim_pcap_z(z,hydro_res,lt))+sum(lt,gen_exist_pcap_z(z,hydro_res,lt)))>0.);

sets
hfirst(h) first hour
hlast(h) last hour
;

hfirst(h) = yes$(ord(h) eq 1) ;
hlast(h) = yes$(ord(h) eq card (h));

* how full are the reservoirs at the start and end (%)

scalar hydro_res_initial_fill /0.8/;

* minimum reservoir level

scalar hydro_res_min /0.5/;

* set hydro inflow

var_hydro_in.FX(h,z,hydro_res)$(gen_lim(z,hydro_res))=hydro_inflow(h,z,hydro_res);

* set minimum reservoir level to be 50%

var_hydro_level.LO(h,z,hydro_res)$(gen_lim(z,hydro_res))=var_exist_hydro_ecap_z.L(z,hydro_res)*hydro_res_min;

* set final reservoir level equal to starting level

var_hydro_level.LO(hlast,z,hydro_res)$(gen_lim(z,hydro_res))=var_exist_hydro_ecap_z.L(z,hydro_res)*hydro_res_initial_fill;

equations
eq_hydro_balance
eq_hydro_level
eq_hydro_gen_max
*eq_hydro_gen_min

* at the moment no new res hydro investment is allowed

*eq_hydro_ecap_max

eq_new_hydro_ecap
eq_exist_hydro_ecap
eq_tot_hydro_ecap_z
eq_tot_hydro_ecap

;

* energy capacity balance equations

eq_new_hydro_ecap(hydro_res) .. var_new_hydro_ecap(hydro_res) =E= sum(z,var_new_hydro_ecap_z(z,hydro_res));

eq_exist_hydro_ecap(hydro_res) .. var_exist_hydro_ecap(hydro_res) =E= sum(z,var_exist_hydro_ecap_z(z,hydro_res));;

eq_tot_hydro_ecap_z(z,hydro_res) .. var_new_hydro_ecap_z(z,hydro_res) + var_exist_hydro_ecap_z(z,hydro_res) =E= var_tot_hydro_ecap_z(z,hydro_res);

eq_tot_hydro_ecap(hydro_res) .. sum(z,var_tot_hydro_ecap_z(z,hydro_res)) =E= var_tot_hydro_ecap(hydro_res);

* operability

* no efficiency needed here because inflow is calibrated to annual generation figures

eq_hydro_balance(h,gen_lim(z,hydro_res)) ..

var_hydro_level(h,z,hydro_res) =E=

var_hydro_level(h-1,z,hydro_res) + var_hydro_in(h,z,hydro_res) - var_gen(h,z,hydro_res) - var_hydro_spill(h,z,hydro_res)

+ (var_exist_hydro_ecap_z(z,hydro_res)*hydro_res_initial_fill)$hfirst(h) ;

eq_hydro_level(h,gen_lim(z,hydro_res)) .. var_hydro_level(h,z,hydro_res) =L= var_tot_hydro_ecap_z(z,hydro_res);

eq_hydro_gen_max(h,gen_lim(z,hydro_res)) .. var_gen(h,z,hydro_res) =L= var_tot_pcap_z(z,hydro_res)*gen_af(hydro_res) ;

*eq_hydro_gen_min(h,gen_lim(z,hydro_res))$(ord(h)>1) .. var_gen(h,z,hydro_res) + var_hydro_spill(h,z,hydro_res) =G= gen_mingen(hydro_res)*var_tot_pcap_z(z,hydro_res);