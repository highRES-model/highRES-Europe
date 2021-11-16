******************************************
* highres storage module
******************************************

$ONEPS
$ONEMPTY

* storage setup

* read in storage sets/data

set s
/
$INCLUDE %psys_scen%_store_set_all.dd
/;

parameter store_pcapex%model_yr%(s)      annualised power capex (£k per MW);
parameter store_ecapex%model_yr%(s)      annualised energy capex (£k per MWh);
parameter store_varom(s)                 variable O&M (£k per MWh) ;
parameter store_fom(s)                   fixed O&M (£k per MW per yr);
parameter store_eff_in(s)                fractional charge efficiency;
parameter store_eff_out(s)               fractional discharge efficiency;
parameter store_loss_per_hr(s)           fractional energy loss per hour (self discharge);
parameter store_p_to_e(s)                power to energy ratio;
parameter store_lim_pcap_z(z,s,lt)       power capacity limit by zone;
parameter store_exist_pcap_z(z,s,lt)     existing power capacity;
parameter store_lim_ecap_z(z,s,lt)       energy capacity limit by zone;
parameter store_exist_ecap_z(z,s,lt)     existing energy capacity;
parameter store_af(s)                    fractional availability factor;
parameter store_max_in(s)                max charge (MW);
parameter store_max_out(s)               max discharge (MW);
parameter store_max_res(s)               fractional maximum contribution to operating reserve;
parameter store_max_freq(s)              fractional maximum constribution to frequency response;
parameter store_e_unitsize(s)            energy storage capacity per unit if using fixed sized units;
parameter store_e_unitcapex(s)                                                                      ;

$INCLUDE %psys_scen%_store_parameters.dd

parameter store_p_capex(s);
parameter store_e_capex(s);

* only FOM for generator component of storage currently

store_p_capex(s)=store_pcapex%model_yr%(s)+store_fom(s);
store_e_capex(s)=store_ecapex%model_yr%(s);

$ontext
parameters store_fx_natcap(s);

$IF "%fx_natcap%" == YES $INCLUDE %esys_scen%_store_fx_natcap.dd
scalar
store_avail_factor
/0.9/;
$offtext

positive variables
var_store_level(h,z,s) Amount of electricity currently stored by hour and technology (MWh)
var_store(h,z,s) Electricity into storage by hour and technology (MW)
var_store_gen(h,z,s) Electricity generated from storage by hour and technology (MW)

var_new_store_pcap_z(z,s) Capacity of storage generator (MW)
var_new_store_pcap(s)
var_new_store_ecap_z(z,s)
var_new_store_ecap(s)

var_exist_store_pcap_z(z,s)
var_exist_store_pcap(s)
var_exist_store_ecap_z(z,s)
var_exist_store_ecap(s)

var_tot_store_pcap_z(z,s)
var_tot_store_pcap(s)
var_tot_store_ecap_z(z,s)
var_tot_store_ecap(s)
;


*** Storage equations ***

* existing storage power capacity

var_exist_store_pcap_z.UP(z,s)$(store_exist_pcap_z(z,s,"UP")) = store_exist_pcap_z(z,s,"UP");
var_exist_store_pcap_z.L(z,s)$(store_exist_pcap_z(z,s,"UP")) = store_exist_pcap_z(z,s,"UP");

var_exist_store_pcap_z.FX(z,s)$(store_exist_pcap_z(z,s,"FX")) = store_exist_pcap_z(z,s,"FX");

var_exist_store_pcap_z.FX(z,s)$(not var_exist_store_pcap_z.l(z,s)) = 0.0;

* existing storage energy capacity

var_exist_store_ecap_z.UP(z,s)$(store_exist_ecap_z(z,s,"UP")) = store_exist_ecap_z(z,s,"UP");
var_exist_store_ecap_z.L(z,s)$(store_exist_ecap_z(z,s,"UP")) = store_exist_ecap_z(z,s,"UP");

var_exist_store_ecap_z.FX(z,s)$(store_exist_ecap_z(z,s,"FX")) = store_exist_ecap_z(z,s,"FX");

var_exist_store_ecap_z.FX(z,s)$(not var_exist_store_ecap_z.l(z,s)) = 0.0;

* limits on total storage generation capacity

var_tot_store_pcap_z.UP(z,s)$(store_lim_pcap_z(z,s,'UP'))=store_lim_pcap_z(z,s,'UP');
var_tot_store_pcap_z.LO(z,s)$(store_lim_pcap_z(z,s,'LO'))=store_lim_pcap_z(z,s,'LO');
var_tot_store_pcap_z.FX(z,s)$(store_lim_pcap_z(z,s,'FX'))=store_lim_pcap_z(z,s,'FX');

* limits on total storage storage capacity

var_tot_store_ecap_z.UP(z,s)$(store_lim_ecap_z(z,s,'UP'))=store_lim_ecap_z(z,s,'UP');
var_tot_store_ecap_z.LO(z,s)$(store_lim_ecap_z(z,s,'LO'))=store_lim_ecap_z(z,s,'LO');
var_tot_store_ecap_z.FX(z,s)$(store_lim_ecap_z(z,s,'FX'))=store_lim_ecap_z(z,s,'FX');


*var_tot_store_gen_cap.FX(s)$(store_fx_natcap(s))=store_fx_natcap(s);

*var_store_level.FX(z,"0",s)=0;


set s_lim(z,s);
*s_lim(z,s) = YES;

* only create equations for zones/techs with capacity limits/existing capacity > 0
* TO CHECK -> since new cap + exist cap <= limit I think we only need limit to be included here

s_lim(z,s) = YES$(((sum(lt,store_lim_pcap_z(z,s,lt))+sum(lt,store_exist_pcap_z(z,s,lt)))>0.) or (sum(lt,store_lim_ecap_z(z,s,lt))+sum(lt,store_exist_ecap_z(z,s,lt)))>0.);

equations
eq_store_balance
eq_store_level
eq_store_gen_max
eq_store_charge_max
eq_store_ecap_max

eq_new_store_pcap
eq_exist_store_pcap
eq_tot_store_pcap_z
eq_tot_store_pcap

eq_new_store_ecap
eq_exist_store_ecap
eq_tot_store_ecap_z
eq_tot_store_ecap
;

* power capacity balance equations

eq_new_store_pcap(s) .. var_new_store_pcap(s) =E= sum(z,var_new_store_pcap_z(z,s));

eq_exist_store_pcap(s) .. var_exist_store_pcap(s) =E= sum(z,var_exist_store_pcap_z(z,s));;

eq_tot_store_pcap_z(z,s) .. var_new_store_pcap_z(z,s) + var_exist_store_pcap_z(z,s) =E= var_tot_store_pcap_z(z,s);

eq_tot_store_pcap(s) .. sum(z,var_tot_store_pcap_z(z,s)) =E= var_tot_store_pcap(s);

* energy capacity balance equations

eq_new_store_ecap(s) .. var_new_store_ecap(s) =E= sum(z,var_new_store_ecap_z(z,s));

eq_exist_store_ecap(s) .. var_exist_store_ecap(s) =E= sum(z,var_exist_store_ecap_z(z,s));;

eq_tot_store_ecap_z(z,s) .. var_new_store_ecap_z(z,s) + var_exist_store_ecap_z(z,s) =E= var_tot_store_ecap_z(z,s);

eq_tot_store_ecap(s) .. sum(z,var_tot_store_ecap_z(z,s)) =E= var_tot_store_ecap(s);


set hfirst(h),hlast(h);
hfirst(h) = yes$(ord(h) eq 1) ;
hlast(h) = yes$(card(h));


* right now there is no ramp for storage

eq_store_balance(h,s_lim(z,s)) ..

var_store_level(h,z,s) =E= var_store_level(h-1,z,s)*(1-store_loss_per_hr(s)) + var_store(h,z,s)*store_eff_in(s) - var_store_gen(h,z,s)*round(1/store_eff_out(s),3)

;

eq_store_level(s_lim(z,s),h) .. var_store_level(h,z,s) =L= var_tot_store_ecap_z(z,s);

* limit new storage energy capacity to be new storage power capacity multiplied by p to e ratio.
* there could be problems with existing capacity being partially decomissioned

eq_store_ecap_max(z,s)$(s_lim(z,s)) .. var_new_store_ecap_z(z,s) =E= var_new_store_pcap_z(z,s)*store_p_to_e(s);

eq_store_charge_max(s_lim(z,s),h) .. var_store(h,z,s) =L= var_tot_store_pcap_z(z,s)*store_af(s) ;

*equation eq_store_netzero_e;

*eq_store_netzero_e(h,z,s)$(s_lim(z,s) and hlast(h)) .. var_store_level(h,z,s) =G= var_new_store_ecap_z(z,s)*0.0 ;



$ifThen "%UC%" == ON

Positive variables
var_store_res(h,z,s)
var_store_f_res(h,z,s);

eq_store_gen_max(s_lim(z,s),h) ..
var_store_gen(h,z,s)+var_store_res(h,z,s)+var_store_f_res(h,z,s) =L= var_tot_store_pcap_z(z,s)*store_af(s) ;
*var_store_gen(h,z,s)+var_store_f_res(h,z,s)=L= var_tot_store_pcap_z(z,s)*store_af(s) ;

$else

eq_store_gen_max(s_lim(z,s),h) .. var_store_gen(h,z,s) =L= var_tot_store_pcap_z(z,s)*store_af(s) ;

$endIf



