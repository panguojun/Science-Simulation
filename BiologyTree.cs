using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System.Linq;

using UnityEngine;
using System.Collections.Generic;

public class BiologyTree : MonoBehaviour {

	public List<Dictionary<string, string>> shells = new List<Dictionary<string, string>>()
	{
		new Dictionary<string, string>()
		{
			{"name", "黄金螺"},
			{"image", "黄金螺图片路径"},
			{"description", "黄金螺是一种常见的海洋软体动物，壳体呈螺旋状，外观美观，是一种受欢迎的收藏品。"},
		},
		new Dictionary<string, string>()
		{
			{"name", "玫瑰贝"},
			{"image", "玫瑰贝图片路径"},
			{"description", "玫瑰贝是一种珍贵的贝类，壳体呈扇形，外观美丽，常用于制作珠宝和工艺品。"},
		},
		new Dictionary<string, string>()
		{
			{"name", "海螺"},
			{"image", "海螺图片路径"},
			{"description", "海螺是一种海洋生物，壳体呈圆锥形或螺旋形，外观多彩多姿，是一种受欢迎的海产品。"},
		},
		new Dictionary<string, string>()
		{
			{"name", "珍珠贝"},
			{"image", "珍珠贝图片路径"},
			{"description", "珍珠贝是一种产生珍珠的贝类，壳体呈圆形或扇形，外观精美，是一种受欢迎的珠宝原料。"},
		},
		new Dictionary<string, string>()
		{
			{"name", "扇贝"},
			{"image", "扇贝图片路径"},
			{"description", "扇贝是一种常见的海洋贝类，壳体呈扇形，外观美丽，肉质鲜美，是一种受欢迎的食品。"},
		},
		new Dictionary<string, string>()
		{
			{"name", "蛤蜊"},
			{"image", "蛤蜊图片路径"},
			{"description", "蛤蜊是一种海洋贝类，壳体呈扇形，外观普通，但肉质鲜美，是一种受欢迎的食品。"},
		},
	};
	public int rows = 3; // 行数
	public int cols = 3; // 列数
	public float buttonWidth = 100; // 按钮宽度
	public float buttonHeight = 100; // 按钮高度
	int curindex = -1;
	void OnGUI()
	{
		// 计算按钮间隔和起始位置
		float spaceX = (Screen.width - cols * buttonWidth) / (cols + 1);
		float spaceY = (Screen.height - rows * buttonHeight) / (rows + 1);
		float posX = spaceX;
		float posY = spaceY;

		// 循环创建按钮
		for (int i = 0; i < rows; i++)
		{
			for (int j = 0; j < cols; j++)
			{
				int index = i * cols + j;
				if (index >= shells.Count) // 贝壳信息不足，退出循环
					break;

				// 创建按钮
				Rect buttonRect = new Rect(posX, posY, buttonWidth, buttonHeight);
				if (GUI.Button(buttonRect, shells[index]["name"]))
				{
					// 点击按钮，展示贝壳的细节信息
					curindex = index;
				}

				// 更新位置
				posX += buttonWidth + spaceX;
			}
			posX = spaceX;
			posY += buttonHeight + spaceY;
		}
		if(curindex!=-1)
			ShowShellDetails(shells[curindex]);
	}

	void ShowShellDetails(Dictionary<string, string> shell)
	{
		// 创建一个窗口
		Rect windowRect = new Rect(Screen.width / 2 - 150, Screen.height / 2 - 150, 300, 300);

		windowRect = GUI.Window(0, windowRect, (id) =>
			{
				// 在窗口中展示贝壳信息
				GUI.Label(new Rect(10, 30, 280, 30), shell["name"]);
				GUI.DrawTexture(new Rect(10, 70, 100, 100), Resources.Load<Texture>(shell["image"]));
				GUI.Label(new Rect(120, 70, 170, 150), shell["description"]);

				// 添加一个关闭按钮
				if (GUI.Button(new Rect(130, 240, 40, 30), "关闭"))
				{
					// 点击关闭按钮，关闭窗口
					GUI.FocusControl(null);
					curindex = -1;
				}

				GUI.DragWindow();
			}, shell["name"]);
	}
}