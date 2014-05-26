EventName = EventName or {}

------------------------------------
--**** 各个游戏界面的跳转事件 *******--

--转到主菜单界面
EventName.GoMainMenu	= "EventName.GoMainMenu"
--转到选择关卡界面
EventName.GoSelectMap	= "EventName.GoSelectMap"
--转到游戏界面  参数：章节，关数
EventName.GoGame 		= "EventName.GoGame"        


------------------------------------
--**** 游戏过程中的一些事件 *******--

--done 有怪物到达 参数：当前到达的怪物数量，允许逃跑的总量
EventName.EnemyArrived 	= "EventName.EnemyArrived"
--done 金币数量发生变化  参数：变化量，总量
EventName.GoldChanged 	= "EventName.GoldChanged"
--done 关卡完成
EventName.Succeed		= "EventName.Succeed"
--done 关卡失败
EventName.Failed		= "EventName.Failed"
--do 重试当前关卡
EventName.Retry 		= "EventName.Retry"
--done 点击了格子 参数：格子x,格子y，建造或升级类型
EventName.TileClicked	= "EventName.TileClicked" 
--do 创建建筑物
EventName.Build 		="EventName.Build"

------------------------------------
--**** 游戏状态栏的一些按钮事件 *******--

--do暂停游戏
EventName.Pause 		= "EventName.Pause"
--do继续游戏
EventName.Resume 		= "EventName.Resume"
--do加速
EventName.Speedup		= "EventName.Speedup"
--do减速
EventName.Speeddown		= "EventName.Speeddown"
