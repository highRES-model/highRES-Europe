
*execute_unload "%outname%"

parameter o_gen_f_provision(h);
parameter o_store_f_provision(h);
parameter o_gen_res_provision(h);
parameter o_store_res_provision(h);
parameter o_gen_quick_res_provision(h);

*o_gen_f_provision(h)=sum((z,non_vre)$(gen_lim(z,non_vre) and gen_max_res(non_vre,"f_response") > 0.),var_f_res.l(h,z,non_vre));
*o_store_f_provision(h)=sum(s_lim(z,s)$(store_max_freq(s) > 0.),var_store_f_res.l(h,z,s));

*o_gen_res_provision(h)=sum((z,non_vre)$(gen_lim(z,non_vre) and gen_max_res(non_vre,"reserve") > 0.),var_res.l(h,z,non_vre));
*o_gen_quick_res_provision(h)=sum((z,non_vre)$(gen_lim(z,non_vre) and gen_quick(non_vre)),var_res_quick.l(h,z,non_vre));
*o_store_res_provision(h)=sum(s_lim(z,s)$(store_max_res(s) > 0.),var_store_res.l(h,z,s));


***************
*Costs
***************

*Variable Costs
parameter o_variableC;
o_variableC=
sum((gen_lim(z,non_vre),h),var_gen.L(h,z,non_vre)*gen_varom(non_vre))
+sum((vre_lim(vre,z,r),h),var_vre_gen_r.L(h,z,vre,r)*gen_varom(vre))
+sum((trans_links(z,z_alias,trans),h),var_trans_flow.l(h,z,z_alias,trans)*trans_varom(trans))


Parameter o_nonVREVarC;
o_nonVREVarC=sum((gen_lim(z,non_vre),h),var_gen.L(h,z,non_vre)*gen_varom(non_vre))

parameter o_VREVarC ;
o_VREVarC=sum((vre_lim(vre,z,r),h),var_vre_gen_r.L(h,z,vre,r)*gen_varom(vre))

parameter o_transVarC;
o_transVarC=sum((trans_links(z,z_alias,trans),h),var_trans_flow.L(h,z,z_alias,trans)*trans_varom(trans))


* Annualised fixed costs
parameter o_capitalC;
o_capitalC=sum(non_vre,var_new_pcap.L(non_vre)*gen_capex(non_vre))
+sum(vre,var_new_pcap.L(vre)*gen_capex(vre))
+sum(trans_links(z,z_alias,trans),var_trans_pcap.l(z,z_alias,trans)*trans_links_dist(z,z_alias,trans)*trans_capex(trans))
+sum(g,var_exist_pcap.l(g)*gen_fom(g))

parameter o_nonVRECapC;
o_nonVRECapC=sum(non_vre,var_new_pcap.L(non_vre)*gen_capex(non_vre))+sum(non_vre,var_exist_pcap.l(non_vre)*gen_fom(non_vre))

parameter o_VRECapC;
o_VRECapC= sum(vre,var_new_pcap.L(vre)*gen_capex(vre))+sum(vre,var_exist_pcap.l(vre)*gen_fom(vre))

parameter o_transCapc;
o_transCapc=sum(trans_links(z,z_alias,trans),var_trans_pcap.l(z,z_alias,trans)*trans_links_dist(z,z_alias,trans)*trans_capex(trans))

* store costs

*Variable store costs
parameter o_variablestoreC;
o_variablestoreC=sum((s_lim(z,s),h),var_store_gen.L(h,z,s)*store_varom(s))

*Capital store Costs
parameter o_capitalstoreC;
o_capitalstoreC=sum(s,var_new_store_pcap.L(s)*store_p_capex(s)+var_new_store_ecap.L(s)*store_e_capex(s))
+sum(s,var_exist_store_pcap.L(s)*store_fom(s))

*Total Capital Costs
parameter o_capitalC_tot;
o_capitalC_tot=o_capitalstoreC+o_capitalC

*Total Variable Costs
parameter o_variableC_tot;
o_variableC_tot=o_variablestoreC+o_variableC


***************
*Emissions
***************

parameter o_emissions(h,z,non_vre);
o_emissions(h,z,non_vre)=var_gen.L(h,z,non_vre)*gen_emisfac(non_vre) ;

parameter o_emissions_all;
o_emissions_all=Sum((h,z,non_vre), o_emissions(h,z,non_vre));




***************
*Transmission
***************

parameter o_trans_cap_sum(trans);
o_trans_cap_sum(trans)=sum((z,z_alias),var_trans_pcap.L(z,z_alias,trans))/2  ;





***************
*Capacities
***************

*parameter vre_cap_z(vre,z);
*vre_cap_z(vre,z)=sum(vre_lim(vre,z,r),var_vre_pcap_r.l(z,vre,r));

*parameter vre_cap_r(vre,r);
*vre_cap_r(vre,r)=sum(vre_lim(vre,z,r),var_vre_pcap_r.l(z,vre,r));

*parameter vre_cap_tot(vre);
*vre_cap_tot(vre)=sum(vre_lim(vre,z,r),var_vre_pcap_r.l(z,vre,r)) ;


***************
*Generation
***************

parameter o_non_vre_gen_tot(non_vre);
o_non_vre_gen_tot(non_vre)=sum((h,z),var_gen.l(h,z,non_vre));

parameter o_non_vre_gen_out(non_vre,h);
o_non_vre_gen_out(non_vre,h)= sum(z,var_gen.l(h,z,non_vre));

parameter o_vre_gen_out(vre,h);
o_vre_gen_out(vre,h)=sum((z,r),var_vre_gen_r.l(h,z,vre,r)$vre_lim(vre,z,r))

parameter o_vre_gen_tot(vre);
o_vre_gen_tot(vre)=sum(h,o_vre_gen_out(vre,h));


parameter o_gen(g,h);
o_gen(g,h)=sum(z,var_gen.l(h,z,g));

parameter o_gen_tot(g);
o_gen_tot(g)=sum(h,o_gen(g,h));


parameter o_pgen_tot_z(z);

$IF "%pen_gen%" == ON o_pgen_tot_z(z)=sum(h,var_pgen.l(h,z));


*parameter vre_cap(vre);
*vre_cap(vre)=sum((z,r),var_vre_pcap_r.l(z,vre,r));

***************
*Curtailment
***************

*parameter o_curtail_h(h);
*curtail(h)=sum((z,vre,r),var_vre_curtail.l(h,z,vre));

*sum of curtailment over all regions
*parameter o_curtail_h_vre(h,vre);
*curtail_z(h,vre)=sum((z,,var_vre_curtail.l(h,z,vre,r))


*sum of curtailment over all regions and hours
parameter o_curtail(vre);
o_curtail(vre)=sum((h,z,r),var_vre_curtail.l(h,z,vre,r))

parameter o_curtail_frac_vregen(vre);
o_curtail_frac_vregen(vre)=o_curtail(vre)/(o_curtail(vre)+o_gen_tot(vre));


***************
*Economics
***************


parameter o_eprice(z,h);
o_eprice(z,h)=eq_elc_balance.m(z,h);


*grossRet is the gross return fom power production (revenues - (variable)costs)

*gross Margins non VRE
parameter o_grossRet_non_vre(z,non_vre);
o_grossRet_non_vre(z,non_vre)=sum(h,((o_eprice(z,h)*var_gen.L(h,z,non_vre))- (var_gen.L(h,z,non_vre)*gen_varom(non_vre))))  ;


*gross Margins VRE
parameter o_grossRet_vre(z,vre,r);
o_grossRet_vre(z,vre,r)=sum(h,(o_eprice(z,h)*var_vre_gen_r.L(h,z,vre,r))- (var_vre_gen_r.L(h,z,vre,r)*gen_varom(vre)))


*gross Margins store
parameter o_grossRet_store(z,s);
o_grossRet_store(z,s)=sum(h,(o_eprice(z,h)*var_store_gen.L(h,z,s))- (var_store_gen.L(h,z,s)*store_varom(s)))



scalar o_gen_costs;
o_gen_costs=sum((h,z,non_vre),var_gen.l(h,z,non_vre)*gen_varom(non_vre))+sum((vre_lim(vre,z,r),h),var_vre_gen_r.l(h,z,vre,r)*gen_varom(vre));




*sums up over all zones and gives installed capacity per renewable
parameter o_vre_cap_z_sum(vre,r);
o_vre_cap_z_sum(vre,r)=sum(z,var_new_vre_pcap_r.L(z,vre,r)+var_exist_vre_pcap_r.L(z,vre,r));


parameter o_vre_cap_r_sum(z,vre) ;
o_vre_cap_r_sum(z,vre)=sum(r,var_new_vre_pcap_r.L(z,vre,r)+var_exist_vre_pcap_r.L(z,vre,r));


*sums up over all zones and gives installed capacity per generation type
parameter o_nvre_cap_z_sum(non_vre);
o_nvre_cap_z_sum(non_vre)=sum(z,var_tot_pcap_z.L(z,non_vre));


*sums up over all hours +regions and gives the generated electricity per renewable type
parameter o_vre_gen_sum_r(vre);
o_vre_gen_sum_r(vre)=sum((h,z,r),var_vre_gen_r.L(h,z,vre,r));


*sums up over all hours +zones and gives the generated electricity per renewable type
parameter o_vre_gen_sum_z(vre,r);
o_vre_gen_sum_z(vre,r)=sum((z,h),var_vre_gen_r.L(h,z,vre,r));


parameter o_vre_gen_sum_r_z(z,vre);
o_vre_gen_sum_r_z(z,vre)=sum((r,h),var_vre_gen_r.L(h,z,vre,r));


parameter o_vre_gen_sum_r_zone(h,z,vre);
o_vre_gen_sum_r_zone(h,z,vre)=sum((r),var_vre_gen_r.L(h,z,vre,r));



*sums over all regions and zones and gives the generated electricity per generation type
parameter o_vre_gen_sum_h(h,vre);
o_vre_gen_sum_h(h,vre)=sum((z,r),var_vre_gen_r.L(h,z,vre,r));


parameter o_gen_sum_zone(z,non_vre)  ;
o_gen_sum_zone(z,non_vre)=sum(h,var_gen.L(h,z,non_vre));


*sums up over all hours +zones and gives the generated electricity per generation type
parameter o_gen_sum_z(non_vre)  ;
o_gen_sum_z(non_vre)=sum((z,h),var_gen.L(h,z,non_vre));

*sums over all zones and gives the generated electricity per generation type
parameter o_gen_sum_h(h,non_vre)  ;
o_gen_sum_h(h,non_vre)=sum(z,var_gen.L(h,z,non_vre));


parameter o_store_gen_sum_h(h,s)  ;
o_store_gen_sum_h(h,s)=sum(z,var_store_gen.L(h,z,s));



*parameter var_trans_pcap_sum(z_alias);
*var_trans_pcap_sum(z_alias)=sum(z,var_trans_pcap.L(z,z_alias))  ;
*display var_trans_pcap_sum;

*sums over all hours and gives the electricity generated per zone and store technology
parameter o_store_gen_sum(z,s);
o_store_gen_sum(z,s)=sum(h,var_store_gen.L(h,z,s));


*sums over all hours and zones and gives the electricity generated per zone and store technology
parameter o_store_gen_all(s);
o_store_gen_all(s)=sum((z,h),var_store_gen.L(h,z,s));


*sums up over all hours +zones and gives the generated electricity per generation type
parameter o_nvre_gen_sum_z(non_vre)  ;
o_nvre_gen_sum_z(non_vre)=sum((z,h),var_gen.L(h,z,non_vre));


parameter o_vre_gen_sum_r(vre);
o_vre_gen_sum_r(vre)=sum((h,z,r),var_vre_gen_r.L(h,z,vre,r));

;

parameter o_Residual_D(z,h);
o_Residual_D(z,h)=demand(z,h)-sum(vre,o_vre_gen_sum_r_zone(h,z,vre));

$ontext
*Average electricity price
parameter price_mean(h);
price_mean(h)= sum((z,non_vre),(price(z,h)*var_gen.L(h,z,non_vre))/sum(vre,var_vre_gen_sum_r(vre)))


parameter price_mean(h);
price_mean(h)=
(sum((z,non_vre),(price(z,h)*var_gen.L(h,z,non_vre)))
+sum((z,vre),(price(z,h)*var_vre_gen_sum_r_zone(h,z,vre)))
+sum((z,s),(price(z,h)*var_store_gen.L(h,z,s))))
/(sum((z,vre),var_vre_gen_sum_r_zone(h,z,vre))+
sum((z,non_vre),var_gen.L(h,z,non_vre))
+sum((z,s),var_store_gen.L(h,z,s)));




WORKS: parameter price_mean(h);
price_mean(h)=
(sum((z,non_vre),(price(z,h)*var_gen.L(h,z,non_vre)))+sum((z,vre),(price(z,h)*var_vre_gen_sum_r_zone(h,z,vre))))
/(sum((z,vre),var_vre_gen_sum_r_zone(h,z,vre))+sum((z,non_vre),var_gen.L(h,z,non_vre)));
display price_mean;

parameter price_mean(h);
price_mean(h)=
(sum((z,non_vre),(price(z,h)*var_gen.L(h,z,non_vre)))
+sum((z,vre),(price(z,h)*var_vre_gen_sum_r_zone(h,z,vre)))
+sum((z,s),(price(z,h)*var_store_gen.L(h,z,s))
/((((sum((z,vre),var_vre_gen_sum_r_zone(h,z,vre))+sum((z,non_vre),var_gen.L(h,z,non_vre))+sum((z,s),var_store_gen.L(h,z,s)));
display price_mean;

parameter price_mean(h);
price_mean(h)=
(sum((z,non_vre),(price(z,h)*var_gen.L(h,z,non_vre)))
+sum((z,vre),(price(z,h)*var_vre_gen_sum_r_zone(h,z,vre)))
+sum((z,s),(price(z,h)*var_store_gen.L(h,z,s))
/(((sum((z,vre),var_vre_gen_sum_r_zone(h,z,vre))+sum((z,non_vre),var_gen.L(h,z,non_vre))+sum((z,s),var_store_gen.L(h,z,s)));
display price_mean;

$offtext

