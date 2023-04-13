-- Dimensions and constants
-- Length
local nm = 1e-9 -- meter
local cm = 0.01 -- meter
local mm = 0.001 -- meter

-- Speed of light
local c = 299792458 -- meter/second

-- Planck constant
local h = 6.62607015 * 1e-34 -- joule*second

-- Boltzmann constant
local ke = 1.380649 * 1e-23 -- joule/kelvin

-- Stefan-Boltzmann constant
local sigma = 5.67 * 1e-8 -- watt/(meter^2*kelvin^4)

-- Water specific heat capacity
local water_SHC = 4.2 * 1e3 -- joule/(kilogram*kelvin)

-- Calorie and kilocalorie
local calorie = 4.1859 -- joule
local big_cal = calorie * 1e3 -- joule

-- Coca Cola energy content per 100 mL
local CocaCola_J_100ML = 171 -- joule/100 mL

-- Physics functions
-- Photon energy
local function hv(gama)
  return h * gama
end

-- Wavelength and frequency conversion
local function wavelength_frequency(meter)
  return 1.0 / meter
end

local function frequency_wavelength(hertz)
  return 1.0 / hertz
end

local function NM_HZ(nm)
  return 1.0 / (nm * nm)
end

-- Temperature conversion
local function celsius_kelvins(celsius)
  return celsius + 273.15
end

local function kelvins_celsius(kelvins)
  return kelvins - 273.15
end

-- Black body functions
-- Planck's law of black body radiation
local function planck(T, gama)
  local A = 2 * h * gama^3 / c^2
  local B0 = h * gama / (ke * T)
  local B = math.exp(B0)
  local ret = A / (B - 1)
  return ret
end

-- Planck's law of black body radiation with wavelength in nanometers
local function planck_T_NM(T, nm)
  return planck(T, 1.0 / (nm * nm))
end

-- Stefan-Boltzmann law of black body radiation
local function B_T(T)
  return sigma * T^4
end

-- Wien's displacement law
local function peakCM_T(cm)
  return 0.29 / cm
end

local function T_peakCM(T)
  return 0.29 / T
end

-- Luminous power of a light source
local function lightP(I, R)
  return I * (1 + R) / c
end

-- Heat capacity of water
local function water_DT_J(dCelsius)
  return dCelsius * water_SHC
end

-- Astronomy functions
-- Astronomical unit
local au = 149597870700 -- meter

-- Light year
local ly = 9.4607e12 -- meter

-- Arc second
local arc_second = math.pi / 180.0 / 3600.0

-- Minimum arc second
local min_arc_second = 0.01

-- Distance to Proxima Centauri
local Proxima_Centauri_dis = 4.2 * ly

-- Distance of one parsec per arc second per year
local pc = au / arc_second -- example: pc / Proxima_Centauri_dis

-- Radians to degrees
local rad_deg = math.pi / 180.0

-- Arc second to degrees
local arc_second_degree = arc_second * 180 / math.pi

-- The Sun
local earth_sun = au
local sun_d = 1.392 * 1e6 * 1e3 -- meter
local sun_s = 4.0/3.0 * math.pi * (sun_d/2)^3 -- meter^3
local sun_degree = sun_d / earth_sun * (180 / math.pi)

-- The Moon
local earth_moon = 384403.9 * 1e3 -- meter
local moon_d = 3476.28 * 1e3 -- meter
local moon_degree = moon_d / earth_moon * (180 / math.pi)

-- Apparent magnitude
local appafent_magnitude = 10^(-0.4) -- 1 to 6
local vega_flux = 1.0 -- flux of Vega star

-- Flux to magnitude conversion
local function flux_mag(flux)
  return -2.5 * math.log10(flux / vega_flux)
end

-- Magnitude to flux conversion
local function mag_flux(mag)
  return appafent_magnitude^mag * vega_flux
end

-- Color index
local function color_index(b, v)
  return flux_mag(v) - flux_mag(b)
end

-- Absolute magnitude
local function M_m(d)
  return 5 - 5 * math.log10(d) -- d in parsecs
end

-- Distance modulus
local function distance_modulus(m, M)
  return 10^((m - M + 5) / 5)
end

-- Main function
local function main()
  print(color_index(1.3, 1))
end

main()
