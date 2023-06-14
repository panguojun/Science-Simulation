/*
 * 科学 JavaScript 库
 * 
 * 该库包含了天文学、物理学、热力学和化学相关的常量和函数。
 */

const science = {
	/*
	* 学科：天文学
	*
	* astronomy 命名空间包含了天文学相关的常量和函数。
	*/
	astronomy : {
	// 天文单位：地球到太阳的平均距离
	au: 149597870700,
	// 光年
	ly: 9.4607e12,
	// 角秒
	arc_second: Math.PI / 180.0 / 3600.0,
	// 最小角秒
	min_arc_second: 0.01,
	// 距离到半人马座比邻星的距离
	Proxima_Centauri_dis: 4.2 * this.ly,
	// 每角秒每年的一秒差距
	pc: this.au / this.arc_second,
	// 弧度到度数的转换
	rad_deg: Math.PI / 180.0,
	// 角秒到度数的转换
	arc_second_degree: this.arc_second * 180 / Math.PI,
	// 太阳
	earth_sun: this.au,
	sun_d: 1.392 * 1e6 * 1e3, // 太阳直径（米）
	sun_s: 4.0 / 3.0 * Math.PI * (this.sun_d / 2) ** 3, // 太阳体积（立方米）
	sun_degree: this.sun_d / this.earth_sun * (180 / Math.PI), // 太阳角直径（度数）
	// 月球
	earth_moon: 384403.9 * 1e3, // 月球到地球的平均距离（米）
	moon_d: 3476.28 * 1e3, // 月球直径（米）
	moon_degree: this.moon_d / this.earth_moon * (180 / Math.PI), // 月球角直径（度数）
	// 表观星等
	appafent_magnitude: 10 ** (-0.4),
	vega_flux: 1.0,
	// 光通量到星等的转换
	flux_mag(flux) {
	  return -2.5 * Math.log10(flux / this.vega_flux);
	},
	// 星等到光通量的转换
	mag_flux(mag) {
	  return this.appafent_magnitude ** mag * this.vega_flux;
	},
	// 颜色指数
	color_index(b, v) {
	  return this.flux_mag(v) - this.flux_mag(b);
	},
	// 绝对星等
	M_m(d) {
	  return 5 - 5 * Math.log10(d); // d为秒差距
	},
	// 距离模数
	distance_modulus(m, M) {
	  return 10 ** ((m - M + 5) / 5);
	}
	},

	/*
	* 学科：物理学
	*
	* physics 命名空间包含了物理学相关的常量和函数。
	*/
	physics: {
	// 光速
	c: 299792458, // 米/秒
	// 普朗克常数
	h: 6.62607015 * 1e-34, // 焦耳*秒
	// 玻尔兹曼常数
	ke: 1.380649 * 1e-23, // 焦耳/开尔文
	// 斯特藩-玻尔兹曼常数
	sigma: 5.67 * 1e-8, // 瓦特/(米^2*开尔文^4)
	// 水的比热容
	water_SHC: 4.2 * 1e3, // 焦耳/(千克*开尔文)
	// 卡路里和大卡
	calorie: 4.1859, // 焦耳
	big_cal: this.calorie * 1e3, // 焦耳
	// 可口可乐每100毫升的能量含量
	CocaCola_J_100ML: 171, // 焦耳/100毫升
	// 光子能量
	hv(gama) {
	  return this.h * gama;
	},
	// 波长和频率转换
	wavelength_frequency(meter) {
	  return 1.0 / meter;
	},
	frequency_wavelength(hertz) {
	  return 1.0 / hertz;
	},
	NM_HZ(nm) {
	  return 1.0 / (nm * nm);
	},
	// 温度转换
	celsius_kelvins(celsius) {
	  return celsius + 273.15;
	},
	kelvins_celsius(kelvins) {
	  return kelvins - 273.15;
	},
	// 黑体辐射普朗克定律
	planck(T, gama) {
	  const A = 2 * this.h * gama ** 3 / this.c ** 2;
	  const B0 = this.h * gama / (this.ke * T);
	  const B = Math.exp(B0);
	  const ret = A / (B - 1);
	  return ret;
	},
	// 黑体辐射普朗克定律（波长单位为纳米）
	planck_T_NM(T, nm) {
	  return this.planck(T, 1.0 / (nm * nm));
	},
	// 斯特藩-玻尔兹曼定律
	B_T(T) {
	  return this.sigma * T ** 4;
	},
	// 维恩位移定律
	peakCM_T(cm) {
	  return 0.29 / cm;
	},
	T_peakCM(T) {
	  return 0.29 / T;
	},
	// 光源的光功率
	lightP(I, R) {
	  return I * (1 + R) / this.c;
	},
	// 水的热容
	water_DT_J(dCelsius) {
	  return dCelsius * this.water_SHC;
	}
	},

	/*
	* 学科：热力学
	*
	* thermodynamics 命名空间包含了热力学相关的常量和函数。
	*/
	thermodynamics: {
	// 水的比热容
	water_SHC: 4.2 * 1e3, // 焦耳/(千克*开尔文)
	// 卡路里和大卡
	calorie: 4.1859, // 焦耳
	big_cal: this.calorie * 1e3, // 焦耳
	// 可口可乐每100毫升的能量含量
	CocaCola_J_100ML: 171, // 焦耳/100毫升
	// 水的热容
	water_DT_J(dCelsius) {
	  return dCelsius * this.water_SHC;
	}
	},
  
	/*
	 * 学科：化学
	 *
	 * chemistry 命名空间包含了化学相关的常量和函数。
	 */
	chemistry: {
	  // 元素周期表
	  periodicTable: {
		H: {
		  atomicNumber: 1,
		  atomicWeight: 1.00784,
		  symbol: 'H',
		  name: 'Hydrogen',
		  electronConfiguration: '1s1',
		  group: 'Nonmetal',
		  period: 1
		},
		He: {
		  atomicNumber: 2,
		  atomicWeight: 4.0026,
		  symbol: 'He',
		  name: 'Helium',
		  electronConfiguration: '1s2',
		  group: 'Noble gas',
		  period: 1
		},
		Li: {
		  atomicNumber: 3,
		  atomicWeight: 6.94,
		  symbol: 'Li',
		  name: 'Lithium',
		  electronConfiguration: '1s2 2s1',
		  group: 'Alkali metal',
		  period: 2
		},
		// 其他元素...
	  },
	  // 摩尔质量
	  molarMass(substance) {
		let mass = 0;
		for (const element of substance) {
		  mass += this.periodicTable[element].atomicWeight;
		}
		return mass;
	  },
	  // 摩尔浓度
	  molarConcentration(moles, volume) {
		return moles / volume;
	  },
	  // 摩尔比例
	  molarRatio(substance1, substance2) {
		const mass1 = this.molarMass(substance1);
		const mass2 = this.molarMass(substance2);
		return mass1 / mass2;
	  }
	}
};

/*
 * 主函数
 *
 * 在此处调用科学库的函数进行测试。
 */
function main() {
  console.log(science.astronomy.color_index(1.3, 1));
  console.log(science.physics.planck(5000, 500));
  console.log(science.thermodynamics.water_DT_J(10));
  console.log(science.chemistry.molarMass(['H', 'O', 'H']));
  console.log(science.chemistry.molarConcentration(0.1, 0.5));
  console.log(science.chemistry.molarRatio(['H', 'O'], ['C', 'O', 'H']));
}

main();