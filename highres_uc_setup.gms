option IntVarUp=0
$ONEPS

* f_response = 10 seconds
* reserve = 20 minutes

scalar f_res_time,res_time;
f_res_time=10./60.;
res_time=20.;

set balance_type /f_response, reserve/;

* needed for wind output reserve requirement

set wind(vre) / Windonshore, Windoffshore /;

$ontext

parameter gen_unitsize(non_vre);
gen_unitsize("NaturalgasOCGTnew")=50.;
gen_unitsize("Nuclear")=1650.;
gen_unitsize("NaturalgasCCGTwithCCSnewOT")=750.;


parameter gen_startupcost(non_vre);

gen_startupcost("NaturalgasOCGTnew")=3.1;
gen_startupcost("Nuclear")=195.;
gen_startupcost("NaturalgasCCGTwithCCSnewOT")=141.;

parameter gen_minup(non_vre);

*gen_minup("NaturalgasOCGTnew")=1;
gen_minup("Nuclear")=24;
gen_minup("NaturalgasCCGTwithCCSnewOT")=4;

parameter gen_mindown(non_vre);

*gen_mindown("NaturalgasOCGTnew")=1;
gen_mindown("Nuclear")=8;
gen_mindown("NaturalgasCCGTwithCCSnewOT")=4;

*set quick_start(non_vre);
*quick_start("NaturalgasOCGTnew")=YES;

gen_mingen("Nuclear")=0.5;
gen_mingen("NaturalgasOCGTnew")=0.2;
gen_mingen("NaturalgasCCGTwithCCSnewOT")=0.5;

$offtext

scalar unit_cap_lim_z / 50000. /;

scalar res_margin / 0.05 /;
scalar wind_margin / 0.14 /;
scalar f_res_margin / 0.05 /;

parameter max_res(non_vre,balance_type);

max_res(non_vre,"reserve")$(gen_uc_int(non_vre) or gen_uc_lin(non_vre))=gen_maxramp(non_vre)*res_time;
max_res(non_vre,"f_response")$(gen_uc_int(non_vre) or gen_uc_lin(non_vre))=gen_maxramp(non_vre)*f_res_time;

$ontext
max_res("Nuclear","f_response")=1.7;
max_res("NaturalgasCCGTwithCCSnewOT","f_response")=8.;
max_res("NaturalgasOCGTnew","f_response")=14.5;

* CCGT = 47.0 MW/min (=> (47/2)/500 = 0.05 rounded up), OCGT = 87 MW/min
* taken from https://www.sciencedirect.com/science/article/pii/S1364032117309206

$offtext

* rescale from MW to GW for better numerics (allegedly)
* also need to change var_H equation to include a /1E3 and remove
* var_freq_req scaling

gen_startupcost(non_vre)=gen_startupcost(non_vre)/MWtoGW;
unit_cap_lim_z=unit_cap_lim_z/MWtoGW;


parameter res_req(h);
res_req(h)=sum(z,demand(z,h))*res_margin;

*parameter f_res_req(h);
*f_res_req(h)=sum(z,demand(z,h))*f_res_margin;

*f_res_req(h)=1800.;


*************************


*set gen_uc(z,non_vre);
*gen_uc(z,non_vre)=(gen_lim(z,non_vre) and gen_unitsize(non_vre) > 0.);

alias(h,h_alias);

*************************

Positive variables

var_res(h,z,non_vre)
var_res_quick(h,z,non_vre)

var_f_res(h,z,non_vre)
var_f_res_quick(h,z,non_vre)

var_f_res_req(h)

var_tot_n_units_lin(z,non_vre)
var_new_n_units_lin(z,non_vre)
var_exist_n_units_lin(z,non_vre)
var_up_units_lin(h,z,non_vre)
var_down_units_lin(h,z,non_vre)
var_com_units_lin(h,z,non_vre)
;

Integer variables
var_tot_n_units(z,non_vre) Total units per zone
var_new_n_units(z,non_vre) Newly installed units per zone
var_exist_n_units(z,non_vre) Existing units per zone
var_up_units(h,z,non_vre) Non_VRE units started per hour and zone
var_down_units(h,z,non_vre) Non_VRE units shutdown per hour and zone
var_com_units(h,z,non_vre) Non_VRE committed units per hour and zone
;

* set integer upper limit for existing capacity being represented as units, based on:
* a) existing cap, floored to ensure it doesn't breach existing cap limit
* b) if no existing cap, set equal to 0

var_exist_n_units.UP(z,non_vre)$(gen_uc_int(non_vre) and gen_exist_pcap_z(z,non_vre,"UP"))=floor(gen_exist_pcap_z(z,non_vre,"UP")/gen_unitsize(non_vre));
var_exist_n_units.L(z,non_vre)$(gen_uc_int(non_vre) and gen_exist_pcap_z(z,non_vre,"UP"))=floor(gen_exist_pcap_z(z,non_vre,"UP")/gen_unitsize(non_vre));

var_exist_n_units.LO(z,non_vre)$(gen_uc_int(non_vre) and gen_exist_pcap_z(z,non_vre,"LO")) = floor(gen_exist_pcap_z(z,non_vre,"LO")/gen_unitsize(non_vre));
var_exist_n_units.FX(z,non_vre)$(gen_uc_int(non_vre) and gen_exist_pcap_z(z,non_vre,"FX")) = floor(gen_exist_pcap_z(z,non_vre,"FX")/gen_unitsize(non_vre));

var_exist_n_units.UP(z,non_vre)$(gen_uc_int(non_vre) and not sum(lt,gen_exist_pcap_z(z,non_vre,lt)))=0.;

* set integer upper limit for new capacity being represented as units, based on:
* a) total cap limit per zone
* b) some arbitrary number (unit_cap_lim_z)

var_tot_n_units.UP(z,non_vre)$(gen_uc_int(non_vre) and gen_lim(z,non_vre) and gen_lim_pcap_z(z,non_vre,'UP') < INF)=ceil(gen_lim_pcap_z(z,non_vre,'UP')/gen_unitsize(non_vre));
var_tot_n_units.UP(z,non_vre)$(gen_uc_int(non_vre) and gen_lim(z,non_vre) and gen_lim_pcap_z(z,non_vre,'UP') = INF)=ceil(unit_cap_lim_z/gen_unitsize(non_vre));

*var_n_units.UP(z,non_vre)$(gen_uc_int(non_vre) and gen_lim(z,non_vre))=ceil(50000/gen_unitsize(non_vre));
var_up_units.UP(h,z,non_vre)$(gen_uc_int(non_vre) and gen_lim(z,non_vre))=var_tot_n_units.UP(z,non_vre);
var_down_units.UP(h,z,non_vre)$(gen_uc_int(non_vre) and gen_lim(z,non_vre))=var_tot_n_units.UP(z,non_vre);
var_com_units.UP(h,z,non_vre)$(gen_uc_int(non_vre) and gen_lim(z,non_vre))=var_tot_n_units.UP(z,non_vre);

var_com_units.UP(h,z,non_vre)$(gen_uc_int(non_vre) and not gen_lim(z,non_vre))=0.;

Equations

* integer operability equations

eq_uc_tot_units
eq_uc_units
eq_uc_unit_state
eq_uc_cap
eq_uc_exist_cap
eq_uc_gen_max
eq_uc_gen_min
eq_uc_gen_minup
eq_uc_gen_mindown

* linear operability equations

eq_uc_tot_units_lin
eq_uc_units_lin
eq_uc_unit_state_lin
eq_uc_cap_lin
eq_uc_exist_cap_lin
eq_uc_gen_max_lin
eq_uc_gen_min_lin

* reserves/response

eq_uc_reserve_quickstart
eq_uc_reserve

eq_uc_response
* no quickstart frequency response at the moment
*eq_uc_response_quickstart

eq_uc_max_reserve
*eq_uc_max_reserve_lin

eq_uc_max_response
eq_uc_max_response_lin

;

eq_uc_tot_units(z,non_vre)$(gen_uc_int(non_vre) and gen_lim(z,non_vre)) .. var_tot_n_units(z,non_vre) =E= var_exist_n_units(z,non_vre)+var_new_n_units(z,non_vre);

eq_uc_cap(z,non_vre)$(gen_uc_int(non_vre) and gen_lim(z,non_vre)) .. var_new_pcap_z(z,non_vre) =E= var_new_n_units(z,non_vre)*gen_unitsize(non_vre);

eq_uc_exist_cap(z,non_vre)$(gen_uc_int(non_vre) and gen_lim(z,non_vre)) .. var_exist_pcap_z(z,non_vre) =E= var_exist_n_units(z,non_vre)*gen_unitsize(non_vre);


eq_uc_tot_units_lin(z,non_vre)$(gen_uc_lin(non_vre) and gen_lim(z,non_vre)) .. var_tot_n_units_lin(z,non_vre) =E= var_exist_n_units_lin(z,non_vre)+var_new_n_units_lin(z,non_vre);

eq_uc_cap_lin(z,non_vre)$(gen_uc_lin(non_vre) and gen_lim(z,non_vre)) .. var_new_pcap_z(z,non_vre) =E= var_new_n_units_lin(z,non_vre)*gen_unitsize(non_vre);

eq_uc_exist_cap_lin(z,non_vre)$(gen_uc_lin(non_vre) and gen_lim(z,non_vre)) .. var_exist_pcap_z(z,non_vre) =E= var_exist_n_units_lin(z,non_vre)*gen_unitsize(non_vre);


*eq_uc_cap_lin(z,non_vre)$(gen_uc_lin(non_vre) and gen_lim(z,non_vre)) .. var_new_pcap_z(z,non_vre) =E= var_n_units_lin(z,non_vre)*gen_unitsize(non_vre);

*eq_uc_exist_cap(z,non_vre)$(gen_uc_int(non_vre) and gen_lim(z,non_vre)) .. var_exist_cap_z(z,non_vre) =E= var_exist_n_units(z,non_vre)*gen_unitsize(non_vre);

*eq_uc_new_cap(z,non_vre)$(gen_uc_int(non_vre) and gen_lim(z,non_vre)) .. var_new_pcap_z(z,non_vre) =E= var_new_n_units(z,non_vre)*gen_unitsize(non_vre);

** Integer operability

eq_uc_units(h,z,non_vre)$(gen_uc_int(non_vre) and gen_lim(z,non_vre)) .. var_com_units(h,z,non_vre) =L= var_tot_n_units(z,non_vre);

eq_uc_unit_state(h,z,non_vre)$(gen_uc_int(non_vre) and gen_lim(z,non_vre)) ..  var_com_units(h,z,non_vre) =E= var_com_units(h-1,z,non_vre)+var_up_units(h,z,non_vre)-var_down_units(h,z,non_vre);

eq_uc_gen_max(h,z,non_vre)$(gen_uc_int(non_vre) and gen_lim(z,non_vre)) .. var_com_units(h,z,non_vre)*gen_unitsize(non_vre)*gen_af(non_vre) =G= var_gen(h,z,non_vre)+var_res(h,z,non_vre)+var_f_res(h,z,non_vre) ;

eq_uc_gen_min(h,z,non_vre)$(gen_uc_int(non_vre) and gen_lim(z,non_vre)) .. var_gen(h,z,non_vre) =G= var_com_units(h,z,non_vre)*gen_mingen(non_vre)*gen_unitsize(non_vre);

eq_uc_gen_minup(h,z,non_vre)$(gen_uc_int(non_vre) and gen_lim(z,non_vre) and (gen_minup(non_vre) > 1) and (ord(h) > 1)) .. sum(h_alias$(ord(h_alias) ge (ord(h) - gen_minup(non_vre)+1) and ord(h_alias) lt ord(h)),var_up_units(h_alias,z,non_vre)) =L= var_com_units(h,z,non_vre);

eq_uc_gen_mindown(h,z,non_vre)$(gen_uc_int(non_vre) and gen_lim(z,non_vre) and (gen_mindown(non_vre) > 1) and (ord(h) > 1)) .. sum(h_alias$(ord(h_alias) ge (ord(h) - gen_mindown(non_vre)+1) and ord(h_alias) lt ord(h)),var_down_units(h_alias,z,non_vre)) =L= var_tot_n_units(z,non_vre)-var_com_units(h,z,non_vre);


** Linear operability

eq_uc_units_lin(h,z,non_vre)$(gen_uc_lin(non_vre) and gen_lim(z,non_vre)) .. var_com_units_lin(h,z,non_vre) =L= var_tot_n_units_lin(z,non_vre);

eq_uc_unit_state_lin(h,z,non_vre)$(gen_uc_lin(non_vre) and gen_lim(z,non_vre)) ..  var_com_units_lin(h,z,non_vre) =E= var_com_units_lin(h-1,z,non_vre)+var_up_units_lin(h,z,non_vre)-var_down_units_lin(h,z,non_vre);

eq_uc_gen_max_lin(h,z,non_vre)$(gen_uc_lin(non_vre) and gen_lim(z,non_vre)) .. var_com_units_lin(h,z,non_vre)*gen_unitsize(non_vre)*gen_af(non_vre) =G= var_gen(h,z,non_vre)+var_res(h,z,non_vre)+var_f_res(h,z,non_vre) ;

eq_uc_gen_min_lin(h,z,non_vre)$(gen_uc_lin(non_vre) and gen_lim(z,non_vre)) .. var_gen(h,z,non_vre) =G= var_com_units_lin(h,z,non_vre)*gen_mingen(non_vre)*gen_unitsize(non_vre);




** Reserves

* Quickstart

eq_uc_reserve_quickstart(h,z,non_vre)$(gen_uc_lin(non_vre) and gen_lim(z,non_vre)) .. (var_tot_n_units_lin(z,non_vre)-var_com_units_lin(h,z,non_vre))*gen_unitsize(non_vre)*gen_af(non_vre) =G= var_res_quick(h,z,non_vre);

* Max reserve potential if needed - can be used to simulate different time scales over which reserve is offered

eq_uc_max_reserve(h,z,non_vre)$(gen_uc_int(non_vre) and gen_lim(z,non_vre)) .. var_res(h,z,non_vre) =L= var_com_units(h,z,non_vre)*max_res(non_vre,"reserve")*gen_af(non_vre);

*eq_uc_max_reserve_lin(h,z,non_vre)$(gen_uc_lin(non_vre) and gen_lim(z,non_vre)) .. var_res(h,z,non_vre) =L= var_com_units_lin(h,z,non_vre)*gen_unitsize(non_vre)*gen_af(non_vre)*max_res(non_vre,"reserve");

* Max response potential

eq_uc_max_response(h,z,non_vre)$(gen_uc_int(non_vre) and gen_lim(z,non_vre)) .. var_f_res(h,z,non_vre) =L= var_com_units(h,z,non_vre)*max_res(non_vre,"f_response")*gen_af(non_vre);

eq_uc_max_response_lin(h,z,non_vre)$(gen_uc_lin(non_vre) and gen_lim(z,non_vre)) .. var_f_res(h,z,non_vre) =L= var_com_units_lin(h,z,non_vre)*max_res(non_vre,"f_response")*gen_af(non_vre);

equations
eq_uc_H
;

Positive variables

var_H(h)
;

$ontext
parameter gen_uc_maxramp(non_vre);

gen_uc_maxramp("Nuclear")=100.;
gen_uc_maxramp("NaturalgasCCGTwithCCSnewOT")=100.;
gen_uc_maxramp("NaturalgasOCGTnew")=14.5;
$offtext


scalar f_0 / 50. /;
scalar f_min / 49.2 /;
scalar f_db / 0.015 /;
scalar p_loss / 1800. /;
scalar p_loss_inertia  / 5./;


eq_uc_H(h) .. var_H(h) =E= sum((z,non_vre)$(gen_uc_int(non_vre) and gen_lim(z,non_vre)),gen_inertia(non_vre)*var_com_units(h,z,non_vre)*(gen_unitsize(non_vre)*MWtoGW/1E3)/f_0)
                               +sum((z,non_vre)$(gen_uc_lin(non_vre) and gen_lim(z,non_vre)),gen_inertia(non_vre)*var_com_units_lin(h,z,non_vre)*(gen_unitsize(non_vre)*MWtoGW/1E3)/f_0);

set seg /1*8/;

parameter slope(seg)
/
1 -5.063
2 -1.688
3 -0.844
4 -0.506
5 -0.338
6 -0.241
7 -0.181
8 -0.141
/;

parameter intercept(seg)
/
1 15.188
2 8.438
3 5.906
4 4.556
5 3.713
6 3.134
7 2.712
8 2.391
/;

var_H.UP(h) = 9.;
var_H.LO(h) = 1.;

equations
eq_uc_freq_req
;

positive variable var_freq_req(h);

* GW to MW

eq_uc_freq_req(h,seg) .. var_freq_req(h) =G= (slope(seg)*var_H(h)+intercept(seg))*1E3/MWtoGW;

*1E3;



$ifThen "%storage%" == ON

$ontext

parameter store_max_res(s,balance_type);

store_max_res(s,"reserve")=1.0;

store_max_res("PumpedHydro","f_response")=0.5;
store_max_res("VRFB6","f_response")=1.0;
store_max_res("VRFB168","f_response")=1.0;

$offtext

Equations
eq_uc_store_res_level
eq_uc_store_res_max
eq_uc_store_f_res_max
;

eq_uc_store_res_level(s_lim(z,s),h) .. var_store_res(h,z,s)+var_store_f_res(h,z,s) =L= var_store_level(h,z,s);

eq_uc_store_res_max(h,s_lim(z,s)) .. var_store_res(h,z,s) =L= var_tot_store_pcap_z(z,s)*store_af(s)*store_max_res(s);

eq_uc_store_f_res_max(h,s_lim(z,s)) .. var_store_f_res(h,z,s) =L= var_tot_store_pcap_z(z,s)*store_af(s)*store_max_freq(s);

$endIf


* Main reserve equation

eq_uc_reserve(h) ..

* spinning

sum((z,non_vre)$(gen_lim(z,non_vre) and not gen_lin(non_vre)),var_res(h,z,non_vre))

* quick start

+sum((z,non_vre)$(gen_uc_lin(non_vre) and gen_lim(z,non_vre)),var_res_quick(h,z,non_vre))

* storage

$IF "%storage%" == ON +sum(s_lim(z,s),var_store_res(h,z,s))

*

-sum((z,vre)$(wind(vre)),var_gen(h,z,vre))*wind_margin

=G= res_req(h);

* Main response equation

eq_uc_response(h) ..

* spinning

sum((z,non_vre)$(gen_lim(z,non_vre) and not gen_lin(non_vre)),var_f_res(h,z,non_vre))

* quick start - no quick start for response

*+sum((z,non_vre)$(gen_uc_lin(non_vre) and gen_lim(z,non_vre)),var_res_quick(h,z,non_vre))

* storage

$IF "%storage%" == ON +sum(s_lim(z,s),var_store_f_res(h,z,s))

*

=G= var_freq_req(h);








