# check_viscosity.R
# script to compare (dynamic) viscosity from CHNOSZ with
# viscosity from miniREFPROP.exe
# also check if need to worry about impact of pressure on viscosity
# Jim Lutz "Wed Jun 13 10:41:09 2018"

# set packages & etc
source("setup.R")

# work with CHNOSZ
# http://chnosz.net//
if(!require(CHNOSZ)){install.packages("CHNOSZ")}
library(CHNOSZ)

# water
# Dynamic viscosity (g cm^-1 s^-1) in poise, (= 0.1 Pa s in SI)
water.SUPCRT92(property='visc', T = 298.15, P = 1)
#          visc
# 1 0.008904924

# density (kg m^3)
water.SUPCRT92(property='rho', T = 298.15, P = 1)
#        rho
# 1 997.0614

# Reynolds number
# Re = ρ * u * D / μ
# ρ is the density of the fluid (kg/m3)
# u is the mean velocity of the fluid (m/s)
# D is the inside diameter of the pipe (m)
# μ is the dynamic viscosity of the fluid (Pa·s = N·s/m2 = kg/(m·s))

# set up paths to working directories
source("setup_wd.R")

# read water_from_miniREFPROP.csv
# need to put names, units, etc before data and data names
DT_miniREFPROP <- 
  fread(file = paste0(wd_data, "water_from_miniREFPROP.csv"),
        skip = 2,
      verbose = TRUE)

# see what came through
str(DT_miniREFPROP)

# make a nominal pressure
DT_miniREFPROP[, Pnom := P]
DT_miniREFPROP[P<1, Pnom := 0]

# look at viscosity vs temp by pressure
ggplot(data=DT_miniREFPROP[!is.na(T)], aes(x=T, y= μ, color=as.factor(Pnom)))+
  geom_line() # +
  # ggtitle( paste0('nominal vs calculated flow by test.segment in ', bfname) )+
  # scale_x_continuous(name = "calculated flow (GPM)", limits = c(0,5))+ 
  # scale_y_continuous(name = "nominal flow (GPM)",limits = c(0,5))+
  # geom_abline(slope = 1, intercept = 0)

# look at viscosity vs pressure by (some) temperatures
ggplot(data=DT_miniREFPROP[T %in% seq(40,180,20)], aes(x=P, y= μ, color=as.factor(T)))+
  geom_line()
# it's very flat, can ignore pressure impacts on viscosity

# look at density vs temp by pressure
ggplot(data=DT_miniREFPROP[!is.na(T)], aes(x=T, y= D, color=as.factor(Pnom)))+
  geom_line() 
# minor impact of pressure

# see if it's same from CHNOSZ
# generate same data table from CHNOSZ
DT_CHNOSZ <-
merge(data.table(P=seq(0,150,25), dummy='1'), 
      data.table(T=(40:180), dummy='1'), 
      all=TRUE, allow.cartesian = TRUE)
DT_CHNOSZ[,dummy:=NULL]

# add temperatures in Kelvin
DT_CHNOSZ[ , T.K := (T-32)/1.8 + 273.15]

# add pressures in bar 
# from PSI gauge + 14.69595 to convert to PSI absolute     
# * Pa/PSI  /  Pa/bar
DT_CHNOSZ[ , P.bar := ( (P + 14.69595) * 6894.757 ) / 100000 ]

# now calc viscosity (g cm^-1 s^-1 = 0.1 * pascal second (Pa · s))
DT_CHNOSZ[, mu.poise := water.SUPCRT92(property='visc', T=T.K, P=P.bar )]

# convert viscosity from poise 
# to Pa-s then to lbm/ft-s
DT_CHNOSZ[, mu.lbm_ft_s := mu.poise / 10 / 1.488164 ]

# add density 
DT_CHNOSZ[, rho.kg_m_3 := water.SUPCRT92(property='rho', T=T.K, P=P.bar )]

# convert density from kg/m^3 (* kg/lbm * m^3/in^3 * 12in*12in*12in)  to lbm/ft^3 
DT_CHNOSZ[, rho.lbm_ft_3 := rho.kg_m_3 / 4.5359237E-01 * 1.6387064E-05 * (12*12*12)]

DT_CHNOSZ[,list( rho.kg_m_3, rho.lbm_ft_3)]
qplot(data = DT_CHNOSZ, rho.kg_m_3, rho.lbm_ft_3 )
# looks like it should now

qplot(data = DT_CHNOSZ, rho.kg_m_3 )
DT_CHNOSZ[rho.kg_m_3<100]
DT_CHNOSZ[P==0 & T>100]


# merge & plot
names(DT_CHNOSZ)
names(DT_miniREFPROP)
DT_water <-
merge(DT_miniREFPROP[!is.na(T)], DT_CHNOSZ,
      by.x = c('Pnom', 'T'),
      by.y = c('P', 'T'),
      all=TRUE)

names(DT_water)

# compare viscosity
DT_water[,list(μ, mu.lbm_ft_s)]
# CHNOSZ about .000001 too high

# look at viscosity vs temp at one pressure 
ggplot(data=DT_water[P==75], aes(x=T, y= μ) )+
  geom_line() +
  geom_line( aes(x=T, y=mu.lbm_ft_s), color='red')
# can't tell them apart

# look at difference in viscosity as percent of miniREFPROP values
ggplot(data=DT_water[P==75], aes(x=T, y= (μ - mu.lbm_ft_s)) )+
  geom_line() +
  scale_y_continuous(name = "difference in viscosity",
                     limits = c(-0.000001, 0)
                     )
# CHNOSZ values about .0000003 too high

# compare density
DT_water[,list(D, rho.kg_m_3, rho.lbm_ft_3)]
DT_water[,list(D, rho.lbm_ft_3, D-rho.lbm_ft_3)]
# CHNOSZ about 0.001 lbm/ft^3 too high

# look at density vs temp at one pressure 
ggplot(data=DT_water[P==75], aes(x=T, y= D) )+
  geom_line() +
  geom_line( aes(x=T, y=rho.lbm_ft_3), color='red')
# can't tell them apart

# look at difference in density as percent of miniREFPROP values
ggplot(data=DT_water, 
       aes(x=T, y= (D - rho.lbm_ft_3), color=as.factor(Pnom)) )+
  geom_line() +
  scale_y_continuous(name = "difference in density (miniREFPROP - CHNOsZ)")
# not perfect, but not too bad, .001 out ~ 60

# compare density miniREFPROP & CHNOSZ by Pnom
DT_water[,list(diff.rho     = mean(D-rho.lbm_ft_3),
               max.diff.rho = max(D-rho.lbm_ft_3),
               min.diff.rho = min(D-rho.lbm_ft_3)),
         by=Pnom]


# calculate and compare kinematic viscosity



