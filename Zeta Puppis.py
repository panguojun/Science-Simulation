# 造父变星

import numpy as np
import matplotlib.pyplot as plt

# 定义初始参数
M = 10  # 恒星质量
t = 0  # 初始时间
dt = 1e6  # 时间步长
L = 1e4  # 初始光度
T = 1e4  # 初始温度
R = np.sqrt(L / (4 * np.pi * 5.67e-8 * T ** 4))  # 初始半径
X = 0.7  # 初始氢丰度
Y = 0.28  # 初始氦丰度
Z = 0.02  # 初始金属丰度

# 定义演化过程
while t < 1e9:
    # 计算质量损失
    if t < 1e7:
        Mloss = 0
    elif t < 1e8:
        Mloss = 0.1 * dt
    else:
        Mloss = 1 * dt

    # 计算新的质量
    M = M - Mloss

    # 计算新的核反应
    X = X - 0.01 * dt
    Y = Y + 0.01 * dt
    Z = Z + 0.01 * dt

    # 计算新的光度和温度
    L = 4 * np.pi * R ** 2 * 5.67e-8 * T ** 4
    T = T * (L / (4 * np.pi * R ** 2 * 5.67e-8)) ** 0.25

    # 计算新的半径
    R = np.sqrt(L / (4 * np.pi * 5.67e-8 * T ** 4))

    # 更新时间
    t = t + dt

    # 绘制演化过程
    plt.plot(t, L, 'r.')
    plt.plot(t, T, 'b.')
    plt.plot(t, R, 'g.')

# 绘制图像
plt.xlabel('时间')
plt.ylabel('光度/温度/半径')
plt.legend(['光度', '温度', '半径'])
plt.show()
