$ONEPS

Sets

lt / UP, LO, FX /


r regions /
$BATINCLUDE %vre_restrict%_regions.dd
/

z zones /
$BATINCLUDE zones.dd
/

g /
$BATINCLUDE %psys_scen%_gen_set_all.dd
/
non_vre(g) /
$BATINCLUDE %psys_scen%_gen_set_nonvre.dd
/
vre(g) /
$BATINCLUDE %psys_scen%_gen_set_vre.dd
/

;

$INCLUDE %weather_yr%_temporal.dd

alias(z,z_alias) ;

Sets

trans transmission techs /
$INCLUDE trans_set_all.dd
/

trans_links(z,z_alias,trans) transmission links /
$INCLUDE trans_links.dd
/

;

parameter gen_capex%model_yr%(g);
parameter gen_varom(g);
parameter gen_fom(g);
parameter gen_fuelcost%model_yr%(g);
parameter gen_mingen(g);
parameter gen_emisfac(g);
parameter gen_maxramp(g);
parameter gen_af(g);
parameter gen_peakaf(g);
parameter gen_cap2area(g);
parameter gen_lim_pcap_z(z,g,lt);
parameter gen_lim_ecap_z(z,g,lt);
parameter gen_exist_pcap_z(z,g,lt);
parameter gen_exist_ecap_z(z,g,lt);
parameter gen_fx_natcap(g);

parameter gen_unitsize(non_vre);
parameter gen_startupcost(non_vre);
parameter gen_minup(non_vre);
parameter gen_mindown(non_vre);
parameter gen_inertia(non_vre);

parameter trans_links_cap(z,z_alias,trans);
parameter trans_links_dist(z,z_alias,trans);
parameter trans_loss(trans);
parameter trans_varom(trans);
parameter trans_capex(trans);

parameter area(vre,z,r);
parameter vre_gen(h,vre,r);

parameter demand(z,h);

scalar co2_budget;


$INCLUDE %psys_scen%_gen_parameters.dd
$INCLUDE trans_parameters.dd
$INCLUDE %esys_scen%_co2_budget.dd

* need to switch between agg and not for areas currently

$INCLUDE vre_areas_%weather_yr%_%vre_restrict%.dd
*$BATINCLUDE vre_%weather_yr%_agg_new_%area_scen%.dd
$INCLUDE %esys_scen%_norescale_demand_%dem_yr%.dd

$gdxin vre_%weather_yr%_%vre_restrict%.gdx
$load vre_gen

$IF %fx_natcap% == "YES" $INCLUDE %esys_scen%_gen_fx_natcap.dd

parameter gen_capex(g);
parameter gen_fuelcost(g);

gen_capex(g)=gen_capex%model_yr%(g);
gen_fuelcost(g)=gen_fuelcost%model_yr%(g);


parameter exist_vre_cap_r(vre,z,r);

*$BATINCLUDE vre_per_zone_2016.dd

